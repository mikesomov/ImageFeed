//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Mike Somov on 20.02.2025.
//

import Foundation

final class OAuth2Service {
    
    // MARK: - Public properties
    
    static let shared = OAuth2Service()
    
    // MARK: - Private properties
    
    private var task: URLSessionTask?
    private var lastCode: String?
    private let urlSession = URLSession.shared
    
    private let baseURL = "https://unsplash.com/oauth/token"
    private let storage = OAuth2TokenStorage()
    
    // MARK: - Initializers

    private init() {}
    
    // MARK: - Public methods
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            fatalError("Invalid base URL")
        }
        
        var components = URLComponents()
        components.scheme = baseURL.scheme
        components.host = baseURL.host
        components.path = "/oauth/token"
        
        components.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        guard let url = components.url else {
            fatalError("Failed to construct URL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil {
            if lastCode != code {
                task?.cancel()
            } else {
                completion(.failure(OAuthError.invalidRequest))
                return
            }
        } else {
            if lastCode == code {
                completion(.failure(OAuthError.invalidRequest))
                return
            }
        }
        
        lastCode = code
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("Failed to create URLRequest")
            completion(.failure(OAuthError.urlEncodingError))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuth2TokenResponseBody, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.storage.token = response.accessToken
                    completion(.success(response.accessToken))
                case .failure(let error):
                    print("Error: \(error)")
                    completion(.failure(error))
                }
            }
            self.task = nil
            self.lastCode = nil
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - Enums
    
    enum OAuthError: Error {
        case urlEncodingError
        case serverREsponseError
        case invalidRequest
        case noData
        case networkError(Error)
        case invalidHttpResponse
        case invalidStatusCode(Int)
        case invalidData
        case decodingFailed(Error)
    }
}
