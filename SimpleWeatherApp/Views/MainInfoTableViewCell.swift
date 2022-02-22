//
//  MainInfoTableViewCell.swift
//  SimpleWeatherApp
//
//  Created by Сашок on 16.02.2022.
//

import UIKit

class MainInfoTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    
    // MARK: - Internal properties
    static let reuseId = "MainInfoTableViewCell"

    // MARK: - Internal methods
    static func nib() -> UINib {
        UINib(nibName: reuseId, bundle: nil)
    }
    
    func configure(with currentWeather: Current?) {
        guard let currentWeather = currentWeather else { return }
        
        contentView.isHidden = false;
        
        updateWeaterIcon(iconId: currentWeather.weather?.first?.icon)
        
        temperatureLabel.text = String(format: "%0.f°C", currentWeather.temp ?? 0)
        feelsLikeLabel.text = String(format: "Ощущается как %0.f°C", currentWeather.feelsLike ?? 0)
        descriptionLabel.text = configureDescription(currentWeather.weather?.first?.weatherDescription ?? "")
    }
    
    // MARK: - Private methods
    private func updateWeaterIcon(iconId: String?) {
        guard let iconId = iconId else {
            weatherIcon.image = UIImage(named: "WeatherPlaceholder")
            return
        }

        ImageService.shared.getIcon(with: iconId) { result in
            switch result {
            case .success(let icon):
                DispatchQueue.main.async {
                    self.weatherIcon.image = icon
                }
            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    self.weatherIcon.image = UIImage(named: "WeatherPlaceholder")
                }
            }
        }
    }
    
    private func configureDescription(_ description: String) -> String {
        guard !description.isEmpty else { return description }
        
        return description.prefix(1).capitalized + description.dropFirst()
    }
}
