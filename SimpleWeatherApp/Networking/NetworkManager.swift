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
    
    private let apiKey = "e44c551160dc50f8423bc7d7db2805a5"
    
    private init() {}
    
    func fetchWeatherData(latitude: Double, longtitude: Double, completionHandler: @escaping (Result<WeatherInfo, NetworkError>) -> Void) {
        guard let weatherUrl = makeWeatherRquestUrl(latitude, longtitude) else { return }
        
        URLSession.shared.dataTask(with: weatherUrl) { data, response, error in
            if let error = error {
                completionHandler(.failure(.transportError(error)))
                return
            }
            
            if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                completionHandler(.failure(.serverError(statusCode: response.statusCode)))
                return
            }
            
            guard let data = data else {
                completionHandler(.failure(.noData))
                return
            }
            
            // TODO remove before release
            sleep(5)
            
            do {
                let weatherInfo = try JSONDecoder().decode(WeatherInfo.self, from: data)
                
                DispatchQueue.main.async {
                    completionHandler(.success(weatherInfo))
                }
            } catch {
                completionHandler(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    func fetchWeatherIcon(with id: String, completionHandler: @escaping (Result<Data, NetworkError>) -> Void) {
        guard let iconUrl = makeIconRequestUrl(for: id) else { return }
        
        URLSession.shared.dataTask(with: iconUrl) { data, response, error in
            if let error = error {
                completionHandler(.failure(.transportError(error)))
                return
            }
            
            if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                completionHandler(.failure(.serverError(statusCode: response.statusCode)))
                return
            }
            
            guard let data = data else {
                completionHandler(.failure(.noData))
                return
            }
            
            // TODO remove before release
            sleep(2)
            
            DispatchQueue.main.async {
                completionHandler(.success(data))
            }
        }.resume()
    }
    
    private func makeWeatherRquestUrl(_ latitude: Double, _ longtitude: Double) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5/onecall"
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longtitude)),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "lang", value: "ru"),
            URLQueryItem(name: "exclude", value: "daily,minutely,alert"),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        
        return components.url
    }
    
    private func makeIconRequestUrl(for iconId: String) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "openweathermap.org"
        components.path = "/img/wn/\(iconId)@2x.png"

        return components.url
    }
}

