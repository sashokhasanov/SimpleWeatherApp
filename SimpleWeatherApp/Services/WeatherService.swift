//
//  WeatherService.swift
//  SimpleWeatherApp
//
//  Created by Сашок on 24.01.2022.
//

import Foundation

class WeatherService {
    static let shared = WeatherService()
    
    private let apiKey = "e44c551160dc50f8423bc7d7db2805a5"
    
    private init() {}
    
    func getWeatherData(latitude: Double, longtitude: Double, completion: @escaping (Result<WeatherInfo, NetworkError>) -> Void) {
        guard let weatherUrl = makeWeatherRequestUrl(latitude, longtitude) else { return }
        
        NetworkManager.shared.fetchData(from: weatherUrl) { result in
            
            // TODO remove before release
            sleep(5)
            
            switch result {
            case .success(let data):
                do {
                    let weatherInfo = try JSONDecoder().decode(WeatherInfo.self, from: data)
                    
                    DispatchQueue.main.async {
                        completion(.success(weatherInfo))
                    }
                } catch {
                    completion(.failure(.decodingError(error)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func makeWeatherRequestUrl(_ latitude: Double, _ longtitude: Double) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5/onecall"
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longtitude)),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "lang", value: "ru"),
            URLQueryItem(name: "exclude", value: "minutely,alert"),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        
        return components.url
    }
}
