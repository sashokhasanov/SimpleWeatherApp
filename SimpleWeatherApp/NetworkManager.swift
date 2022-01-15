//
//  NetworkManager.swift
//  SimpleWeatherApp
//
//  Created by Сашок on 14.01.2022.
//

import UIKit

class NetworkManager {
    
    static let shared = NetworkManager()
    
    private let apiKey = "e44c551160dc50f8423bc7d7db2805a5"
    
    private init() {}
    
    func fetchWeatherData(completionHandler: @escaping (WeatherInfo?) -> Void) {
        guard let weatherUrl = makeQueryUrl() else { return }
        
        URLSession.shared.dataTask(with: weatherUrl) { data, _, _ in
            guard let data = data else { return }
            sleep(5)
            let weatherInfo = try? JSONDecoder().decode(WeatherInfo.self, from: data)
            completionHandler(weatherInfo)
        }.resume()
    }
    
    func fetchWeatherIcon(with id: String, completionHandler: @escaping (UIImage?) -> Void) {
        guard let iconUrl = makeIconUrl(for: id) else { return }
        
        URLSession.shared.dataTask(with: iconUrl) { data, _, _ in
            guard let data = data else { return }
            sleep(2)
            let icon = UIImage(data: data)
            completionHandler(icon)
        }.resume()
    }
    
    private func makeQueryUrl() -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5/weather"
        components.queryItems = [
            URLQueryItem(name: "q", value: "Moscow"),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "lang", value: "ru"),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        
        return components.url
    }
    
    private func makeIconUrl(for iconId: String) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "openweathermap.org"
        components.path = "/img/wn/\(iconId)@2x.png"

        return components.url
    }
}
