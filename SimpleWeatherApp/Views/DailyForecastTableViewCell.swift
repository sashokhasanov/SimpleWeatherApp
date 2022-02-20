//
//  DailyForecastTableViewCell.swift
//  SimpleWeatherApp
//
//  Created by Сашок on 20.02.2022.
//

import UIKit

class DailyForecastTableViewCell: UITableViewCell {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    
    private var iconId: String? {
        didSet {
            updateWeaterIcon()
        }
    }
    
    // MARK: - Internal properties
    static let reuseId = "DailyForecastTableViewCell"
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    static func nib() -> UINib {
        UINib(nibName: reuseId, bundle: nil)
    }
    
    func configure(with daily: Daily?, timeZoneOffset: Int) {
        
        dayLabel.text = getDayFromTimestamp(daily?.dt ?? 0, offset: timeZoneOffset)
        
        temperatureLabel.text = String(format: "%0.f°C", daily?.temp?.day ?? 0)
        
        iconId = daily?.weather?.first?.icon
    }
    
    private func getDayFromTimestamp(_ timestamp: Int, offset timezoneOffset: Int) -> String {
        let date = Date(timeIntervalSince1970: Double(timestamp))
        
        let formatter = DateFormatter()
        formatter.dateFormat = "E dd.MM.yy"
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