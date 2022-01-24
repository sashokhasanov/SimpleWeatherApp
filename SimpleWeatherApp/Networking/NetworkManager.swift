//
//  NetworkManager.swift
//  SimpleWeatherApp
//
//  Created by Сашок on 14.01.2022.
//

import Foundation

enum NetworkError: Error {
    case transportError(Error)
    case noData
    case serverError(statusCode: Int)
    case decodingError(Error)
}

class NetworkManager {
    static let shared = NetworkManager()

    private init() {}
    
    func fetchData(from url: URL, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.transportError(error)))
                return
            }
            
            if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                completion(.failure(.serverError(statusCode: response.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            completion(.success(data))
        }.resume()
    }
}

