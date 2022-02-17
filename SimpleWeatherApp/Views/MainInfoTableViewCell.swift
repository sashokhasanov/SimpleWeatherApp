//
//  MainInfoTableViewCell.swift
//  SimpleWeatherApp
//
//  Created by Сашок on 16.02.2022.
//

import UIKit

class MainInfoTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    
    static let reuseId = "MainInfoTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    static func nib() -> UINib {
        UINib(nibName: reuseId, bundle: nil)
    }
    
    func configure(with currentWeather: Current?) {
        
        updateWeaterIcon(iconId: currentWeather?.weather?.first?.icon)
        
        temperatureLabel.text = String(format: "%0.f°C", currentWeather?.temp ?? 0)
        feelsLikeLabel.text = String(format: "Ощущается как %0.f°C", currentWeather?.feelsLike ?? 0)

        let description = currentWeather?.weather?.first?.weatherDescription ?? ""
        descriptionLabel.text = description.prefix(1).capitalized + description.dropFirst()
    }
    
    private func updateWeaterIcon(iconId: String?) {
        guard let iconId = iconId else {
            iconView.image = UIImage(named: "WeatherPlaceholder")
            return
        }
        
        iconView.startFadeAnimation()
        
        ImageService.shared.getIcon(with: iconId) { result in
            DispatchQueue.main.async {
                self.iconView.stopFadeAnimation()
            }
            
            switch result {
            case .success(let icon):
                self.iconView.image = icon
            case .failure(let error):
                // TODO log error
                print(error)
            }
        }
    }
    
}