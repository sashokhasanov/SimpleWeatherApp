//
//  WeatherInfo.swift
//  SimpleWeatherApp
//
//  Created by Сашок on 14.01.2022.
//

import Foundation

// MARK: - WeatherInfo
struct WeatherInfo: Decodable {
    
    let longtitude: Double?
    let latitude: Double?
    let timezone: String?
    let timezoneOffset: Int?
    let current: Current?
    let hourly: [Current]?
    let daily: [Daily]?

    enum CodingKeys: String, CodingKey {
        case longtitude = "lon"
        case latitude = "lat"
        case timezone
        case timezoneOffset = "timezone_offset"
        case current
        case hourly
        case daily
    }
}

// MARK: - Current
struct Current: Decodable {
    let dt: Int?
    let temp: Double?
    let feelsLike: Double?
    let pressure: Int?
    let humidity: Int?
    let clouds: Int?
    let visibility: Int?
    let windSpeed: Double?
    let windDeg: Int?
    let windGust: Double?
    let weather: [Weather]?

    enum CodingKeys: String, CodingKey {
        case dt, temp
        case feelsLike = "feels_like"
        case pressure, humidity
        case clouds, visibility
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case windGust = "wind_gust"
        case weather
    }
}

// MARK: - Current
struct Daily: Decodable {
    let dt: Int?
    let sunrise: Int?
    let sunset: Int?
    let moonrise: Int?
    let moonset: Int?
    let moonPhase: Double?
    let temp: DailyTemp?
    let feelsLike: DailyFeelsLike?
    let pressure: Int?
    let humidity: Int?
    let windSpeed: Double?
    let windDeg: Int?
    let weather: [Weather]?
    let clouds: Int?

    enum CodingKeys: String, CodingKey {
        case dt
        case sunrise
        case sunset
        case moonrise
        case moonset
        case moonPhase = "moon_phase"
        case temp
        case feelsLike = "feels_like"
        case pressure
        case humidity
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case weather
        case clouds
    }
}

// MARK: - DailyFeelsLike
struct DailyFeelsLike: Decodable {
    let day: Double?
    let night: Double?
    let eve: Double?
    let morn: Double?
}

// MARK: - DailyTemp
struct DailyTemp: Decodable {
    let day: Double?
    let min: Double?
    let max: Double?
    let night: Double?
    let eve: Double?
    let morn: Double?
}

// MARK: - Weather
struct Weather: Decodable {
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
