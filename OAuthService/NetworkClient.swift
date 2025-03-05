//
//  NetworkClient.swift
//  ImageFeed
//
//  Created by Mike Somov on 20.02.2025.
//

import Foundation

final class NetworkClient {
    
    // MARK: - Private methods

    private func data(request: URLRequest, handler: @escaping (Result<Data, Error>) -> Void) {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                handler(result)
            }
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                print("URL request error: \(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.dataNotFound))
                print("Invalid HTTP response")
                return
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                print("HTTP error: \(httpResponse.statusCode)")
                return
            }
            guard let data = data else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.dataNotFound))
                print("Data not found")
                return
            }
            fulfillCompletionOnTheMainThread(.success(data))
        }
        task.resume()
    }
}

// MARK: - Extensions

extension URLSession {
    func objectTask<T: Decodable>(for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask {
        let task = dataTask(with: request) { data, response, error in
            if let error = error {
                print("Server response error: \(error.localizedDescription)")
                completion(.failure(NetworkError.urlRequestError(error)))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.invalidResponse))
                print("Invalid HTTP response")
                return
            }
            guard let data = data else {
                print("No data received")
                completion(.failure(NetworkError.dataNotFound))
                return
            }
            do {
                let decoder = JSONDecoder()
                let object = try decoder.decode(T.self, from: data)
                completion(.success(object))
            } catch {
                print ("Decoding error: \(error)")
                completion(.failure(NetworkError.decodingError(error)))
            }
        }
        task.resume()
        return task
    }
}

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case dataNotFound
    case decodingError(Error)
    case invalidResponse
}
