//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Mike Somov on 11.03.2025.
//

import UIKit


final class ImagesListService {
    
    // MARK: - Public properties
    
    static let didChangeNotification = Notification.Name(rawValue: "ImageListServiceDidChange")
    static let shared = ImagesListService()
    
    // MARK: - Private properties
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var currentTask: URLSessionTask?
    private var dataTask: URLSessionTask?
    
    private lazy var iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
    
    // MARK: - Public methods
    
    func fetchPhotos(completion: @escaping ([Photo]) -> Void) {
        guard currentTask == nil else {
            return
        }
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        if nextPage == 1 {
            photos.removeAll()
        }
        
        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(nextPage)") else {
            print("Error: INvalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = OAuth2TokenStorage().token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        currentTask = URLSession.shared.dataTask(with: request) {
            [weak self] data,
            response,
            error in
            guard let self = self else { return }
            self.currentTask = nil
            
            if let error = error {
                print("Error fetching photos: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("Error No data recieved")
                return
            }
            do {
                let photoResults = try JSONDecoder().decode([PhotoResult].self, from: data)
                let newPhotos = photoResults.map { photoResult in
                    Photo(
                        id: photoResult.id,
                        size: CGSize(width: photoResult.width, height: photoResult.height),
                        createdAt: self.date(from: photoResult.createdAt),
                        welcomeDescription: photoResult.description,
                        thumbImageURL: photoResult.urls.thumb,
                        largeImageURL: photoResult.urls.full,
                        isLiked: photoResult.isLiked
                    )
                }
                
                let uniqueNewPhotos = newPhotos.filter { newPhoto in
                    !self.photos.contains {$0.id == newPhoto.id }
                }
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: uniqueNewPhotos)
                    self.lastLoadedPage = nextPage
                    
                    print("\(uniqueNewPhotos.count) new photos loaded. Total photos amount is: \(self.photos.count)")
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }
        
        currentTask?.resume()
    }
    
    func changeLike(
        photoId: String, isLike: Bool,
        _ completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard !photoId.isEmpty else {
            print("Error: photoId is empty")
            return
        }
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like")
        else {
            print("Error: Invalid URL for photo ID: \(photoId)")
            return
        }
        print("URL successfully created: \(url)")
        
        guard currentTask == nil else {
            print("A task is already in progress.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        
        if let token = OAuth2TokenStorage().token {
            request.setValue(
                "Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Error: Authorization token is missing")
            return
        }
        if let existingTask = dataTask {
            existingTask.cancel()
        }
        let dataTask = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            guard let self = self else { return }
            self.currentTask = nil
            if let error = error {
                print("Error changing like: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    print("Like status updated successfully")
                    completion(.success(()))
                } else {
                    let statusCodeError = NSError(
                        domain: "ImageFeed", code: httpResponse.statusCode,
                        userInfo: [
                            NSLocalizedDescriptionKey:
                                "Server returned unexpected status code"
                        ])
                    print("Unexpected status code: \(httpResponse.statusCode)")
                    completion(.failure(statusCodeError))
                }
            } else {
                let unknownError = NSError(
                    domain: "ImageFeed", code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unknown error occurred"
                    ])
                print("Unknown error occurred while changing like")
                completion(.failure(unknownError))
            }
        }
        dataTask.resume()
        self.dataTask = dataTask
    }
    
    func cleanImagesList() {
        photos = []
        lastLoadedPage = nil
    }
    
    // MARK: - Private methods
    
    private func date(from dateStrinng: String?) -> Date? {
        guard let dateString = dateStrinng else { return nil }
        return iso8601Formatter.date(from: dateString)
    }
}
