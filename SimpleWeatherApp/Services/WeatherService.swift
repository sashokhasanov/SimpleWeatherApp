//
//  WeatherService.swift
//  SimpleWeatherApp
//
//  Created by Сашок on 24.01.2022.
//

import Foundation

class WeatherService {
    static let shared = WeatherService()
    
    private lazy var apiKey: String = {
        
        guard let filePath = Bundle.main.path(forResource: "OpenWeatherMap-Info", ofType: "plist") else {
            fatalError("Couldn't find file 'OpenWeatherMap-Info.plist'.")
        }
        
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "API_KEY") as? String else {
            fatalError("Couldn't find key 'API_KEY' in 'OpenWeatherMap-Info.plist'.")
        }
        
        if (value.starts(with: "_")) {
            fatalError("Register as a developer at OpenWeatherMap: https://openweathermap.org/api/one-call-api")
        }
        
        return value
    }()
    
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
