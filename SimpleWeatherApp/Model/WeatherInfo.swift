//
//  WeatherInfo.swift
//  SimpleWeatherApp
//
//  Created by Сашок on 14.01.2022.
//

import Foundation

// MARK: - WeatherInfo
struct WeatherInfo: Codable {
    let coordinates: Coordinates?
    let weather: [Weather]?
    let main: Main?
    let wind: Wind?
    let name: String?
    
    enum CodingKeys: String, CodingKey {
        case coordinates = "coord"
        case weather
        case main
        case wind
        case name
    }
}

// MARK: - Coordinates
struct Coordinates: Codable {
    let longtitude: Double?
    let latitude: Double?
    
    enum CodingKeys: String, CodingKey {
        case longtitude = "lon"
        case latitude = "lat"
    }
}

// MARK: - Main
struct Main: Codable {
    let temp: Double?
    let feelsLike: Double?
    let tempMin: Double?
    let tempMax: Double?
    let pressure: Int?
    let humidity: Int?

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case humidity
    }
}

// MARK: - Weather
struct Weather: Codable {
    let id: Int?
    let main: String?
    let weatherDescription: String?
    let icon: String?

    enum CodingKeys: String, CodingKey {
        case id
        case main
        case weatherDescription = "description"
        case icon
    }
}

// MARK: - Wind
struct Wind: Codable {
    let speed: Double?
    let deg: Int?
    let gust: Double?
}
