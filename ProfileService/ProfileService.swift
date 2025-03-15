//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Mike Somov on 01.03.2025.
//

import Foundation

final class ProfileService {
    
    // MARK: - Public properties
    
    var token: String?
    var username: String?
    static let shared = ProfileService()
    private(set) var profile: Profile? = nil

    
    // MARK: - Private properties
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    // MARK: - Initializers

    private init () {}
    
    // MARK: - Structs
    
    struct ProfileResult: Decodable {
        let id: String?
        let username: String
        let firstName: String
        let lastName: String
        let loginName: String?
        let bio: String?
        
        enum CodingKeys: String, CodingKey {
            case id, username, bio
            case firstName = "first_name"
            case lastName = "last_name"
            case loginName = "login_name"
        }
    }
    
    struct Profile: Decodable {
        let username: String
        let firstName: String
        let lastName: String
        var name: String {
            return firstName + " " + lastName
        }
        var loginName: String {
            return "@" + username
        }
        let bio: String
    }
    
    // MARK: - Public methods
    
    func cleanProfileData() {
        profile = nil
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
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
        guard let request = createUrlRequestPublicInfo(authToken: token) else {
            print("Failed to create URLRequest")
            completion(.failure(ProfileServiceError.urlEncodingError))
            return
        }
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let profile = Profile (
                        username: response.username,
                        firstName: response.firstName,
                        lastName: response.lastName,
                        bio: response.bio ?? "")
                    self.username = profile.username
                    completion(.success(profile))
                case .failure(let error):
                    print("Error: \(error)")
                    completion(.failure(error))
                }
                self.task = nil
                self.token = nil
            }
        }
        self.token = token
        task.resume()
    }
    
    // MARK: - Private methods
    
    private func createUrlRequestPublicInfo(authToken: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.get.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        return request
    }
}

// MARK: - Enums

enum ProfileServiceError: Error {
    case urlEncodingError
    case serverResponseError(Error)
    case noDataError
    case invalidRequest
    case decodingError
}

enum HttpMethods: String {
    case get = "GET"
    case post = "POST"
}
