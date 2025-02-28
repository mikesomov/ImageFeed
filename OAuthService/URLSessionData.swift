//
//  URLSessionData.swift
//  ImageFeed
//
//  Created by Mike Somov on 20.02.2025.
//

import Foundation

// MARK: - Enums

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

// MARK: - Extensions

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        return task
    }
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let decodingData = try decoder.decode(T.self, from: data)
                    completion(.success(decodingData))
                } catch {
                    print("[URLSession.objectTask()]: decoding error. Object: \(T.self). Error: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("[URLSession.objectTask()]: error creating URLSessionTask. Object: \(T.self). Error: \(error)")
                completion(.failure(error))
            }
        }
        return task
    }
}
