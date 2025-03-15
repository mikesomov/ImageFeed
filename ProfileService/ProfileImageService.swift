//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Mike Somov on 01.03.2025.
//

import Foundation

final class ProfileImageService {
    
    // MARK: - Public properties
    
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name ("ProfileImageServiceDidChangeNotification")
    
    // MARK: - Private properties
    
    private let urlSession = URLSession.shared
    private let profileService = ProfileService.shared
    private var imageUrl: URL?
    private var task: URLSessionTask?
    
    // MARK: - Initializers
    
    private init () {}
    
    // MARK: - Structs
    
    struct ProfileImageSizes: Codable {
        let small: String?
        let medium: String?
        let large: String?
    }
    
    struct ProfileImage: Codable {
        let profileImage: ProfileImageSizes
        
        enum CodingKeys: String, CodingKey {
            case profileImage = "profile_image"
            
        }
    }
    
    // MARK: Public methods
    
    func cleanProfilePhoto() {
        imageUrl = nil
    }
    
    func fetchProfileImage(_ token: String, completion: @escaping (Result<ProfileImage, Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil {
            if token != OAuth2TokenStorage().token {
                task?.cancel()
            } else {
                completion(.failure(ProfileServiceError.invalidRequest))
                return
            }
        } else {
            if token == OAuth2TokenStorage().token {
                completion(.failure(ProfileServiceError.invalidRequest))
            }
        }
        
        guard let request = createUrlRequestPrivateInfo(authToken: token) else {
            print("Failed to create URLRequest (Image)")
            completion(.failure(ProfileServiceError.urlEncodingError))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileImage, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("Response data: \(response)")
                    completion(.success(response))
                    NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: self, userInfo: ["profileImage": response])
                case .failure(let error):
                    print("Error: \(error)")
                    completion(.failure(error))
                }
                self.task = nil
            }
        }
        task.resume()
    }
    
    // MARK: - Private methods
    
    private func createUrlRequestPrivateInfo(authToken: String) -> URLRequest? {
        guard let username = profileService.username else {
            print("Username is nil")
            return nil
        }
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            print("Invalid URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.get.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        return request
    }
}
