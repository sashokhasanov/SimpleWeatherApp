//
//  CollectionViewCell.swift
//  SimpleWeatherApp
//
//  Created by Сашок on 17.01.2022.
//

import UIKit

class WeatherForecastCell: UICollectionViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    private var iconId: String? {
        didSet {
            updateWeaterIcon()
        }
    }
    
    func configure(with forecastItem: Current, timeZoneOffset: Int) {
        timeLabel.text =
            getHourFromTimestamp(forecastItem.dt ?? 0, offset: timeZoneOffset)

        temperatureLabel.text = String(format: "%0.f°C", forecastItem.temp ?? 0)
        
        iconId = forecastItem.weather?.first?.icon
        updateWeaterIcon()
    }
    
    private func getHourFromTimestamp(_ timestamp: Int, offset timezoneOffset: Int) -> String {
        let date = Date(timeIntervalSince1970: Double(timestamp))
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        formatter.timeZone = TimeZone(secondsFromGMT: timezoneOffset)
        
        return formatter.string(from: date)
    }
    
    private func updateWeaterIcon() {
        guard let iconId = iconId else {
            return
        }
        
        weatherIcon.startFadeAnimation()
        
        ImageManager.shared.getIcon(with: iconId) { result in
            DispatchQueue.main.async {
                self.weatherIcon.stopFadeAnimation()
            }
            
            switch result {
            case .success(let icon):
                if iconId == self.iconId {
                    self.weatherIcon.image = icon
                }
            case .failure(let error):
                // TODO log error
                print(error)
            }
        }
    }
}
