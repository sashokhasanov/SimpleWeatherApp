//
//  ForecastCollectionViewCell.swift
//  SimpleWeatherApp
//
//  Created by Сашок on 16.02.2022.
//

import UIKit

class ForecastCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    // MARK: - Internal properties
    static let reuseId = "ForecastCollectionViewCell"
    
    // MARK: - Private properties
    private var iconId: String? {
        didSet {
            updateWeaterIcon()
        }
    }

    // MARK: - Internal methods
    static func nib() -> UINib {
        UINib(nibName: reuseId, bundle: nil)
    }
    
    func configure(with forecastItem: Current, timeZoneOffset: Int) {
        timeLabel.text =
            getHourFromTimestamp(forecastItem.dt ?? 0, offset: timeZoneOffset)

        temperatureLabel.text = String(format: "%0.f°C", forecastItem.temp ?? 0)
        
        iconId = forecastItem.weather?.first?.icon
    }
    
    // MARK: - Private methods
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
        
        ImageService.shared.getIcon(with: iconId) { result in
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
