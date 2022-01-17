//
//  NetworkManager.swift
//  SimpleWeatherApp
//
//  Created by Сашок on 14.01.2022.
//

import Foundation

class NetworkManager {
    
    static let shared = NetworkManager()
    
    private let apiKey = "e44c551160dc50f8423bc7d7db2805a5"
    
    private init() {}
    
    func fetchWeatherData(latitude: Double, longtitude: Double, completionHandler: @escaping (WeatherInfo?) -> Void) {
        guard let weatherUrl = makeWeatherRquestUrl(latitude, longtitude) else { return }
        
        URLSession.shared.dataTask(with: weatherUrl) { data, _, error in
            guard let data = data else {
                // TODO log error
                print(error ?? "Unknown error")
                return
            }
            
            // TODO remove before release
            sleep(5)
            
            let weatherInfo = try? JSONDecoder().decode(WeatherInfo.self, from: data)
            completionHandler(weatherInfo)
        }.resume()
    }
    
    func fetchWeatherIcon(with id: String, completionHandler: @escaping (Data?) -> Void) {
        guard let iconUrl = makeIconRequestUrl(for: id) else { return }
        
        URLSession.shared.dataTask(with: iconUrl) { data, _, error in
            guard let data = data else {
                // TODO log error
                print(error ?? "Unknown error")
                return
            }
            
            // TODO remove before release
            sleep(2)
            
            completionHandler(data)
        }.resume()
    }
    
    private func makeWeatherRquestUrl(_ latitude: Double, _ longtitude: Double) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5/weather"
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longtitude)),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "lang", value: "ru"),
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
