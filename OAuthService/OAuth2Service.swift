//
//  OAuthService.swift
//  ImageFeed
//
//  Created by Mike Somov on 20.02.2025.
//

import Foundation

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    private let baseURL = "https://unsplash.com/oauth/token"
    private let storage = OAuth2TokenStorage()
    private init() {}
    
    enum OAuthError: Error {
        case invalidRequest
        case networkError(Error)
        case invalidHttpResponse
        case invalidStatusCode(Int)
        case invalidData
        case decodingFailed(Error)
    }
    
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
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, OAuthError>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(.invalidRequest))
            print("Incorrect token request")
            return
        }
        print("Sending request: \(request)")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.networkError(error)))
                    print("Network error:", error.localizedDescription)
                }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidHttpResponse))
                    print("Error: Incorrect HTTP response")
                }
                return
            }
            
            print("Server response code:", httpResponse.statusCode)
            
            guard (200..<300).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidStatusCode(httpResponse.statusCode)))
                    print("Invalid status code \(httpResponse.statusCode)")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidData))
                    print("No data")
                }
                return
            }
            
            print("Server response:", String(data: data, encoding: .utf8) ?? "No data")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("jsonString: \(jsonString)")
            } else {
                print("Error: invalid JSON")
            }
            do {
                let decoder = JSONDecoder()
                print("JSON data recieved:", String(data: data, encoding: .utf8) ?? "No data")
                print("Uncoded JSON:", String(data: data, encoding: .utf8) ?? "No data")
                
                let responseBody = try decoder.decode(OAuth2TokenResponseBody.self, from: data)
                
                print("Token successfully received", responseBody.accessToken)
                self.storage.token = responseBody.accessToken
                
                DispatchQueue.main.async {
                    completion(.success(responseBody.accessToken))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.decodingFailed(error)))
                    print("JSON decoding error", error.localizedDescription)
                }
            }
        }
        task.resume()
    }
}
