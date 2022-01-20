//
//  ViewController.swift
//  SimpleWeatherApp
//
//  Created by Сашок on 14.01.2022.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var mainInfoView: UIStackView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var forecastView: UICollectionView!
    
    // MARK: - Private properties
    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocation?
    
    private var weatherInfo: WeatherInfo?
    
    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocation()
    }
    
    // MARK: - Private methods
    private func setupLocation() {
        locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    private func updateWeather(latitude: Double, longtiture: Double) {
        cityLabel.isHidden = true
        startAnimate(view: mainInfoView)

        NetworkManager.shared.fetchWeatherData(latitude: latitude, longtitude: longtiture) { weatherInfo in

            DispatchQueue.main.async {
                self.stopAnimateView(view: self.mainInfoView)
            }
        
            guard let weatherInfo = weatherInfo else { return }
            self.weatherInfo = weatherInfo

            DispatchQueue.main.async {
                self.updateCurrentWeatherView()
                self.forecastView.reloadData()
            }
        }
    }
    
    
    private func updateCurrentWeatherView() {
        guard let weatherInfo = weatherInfo else { return }
        
        if let iconId = weatherInfo.current?.weather?[0].icon {
            self.updateWeaterIcon(with: iconId, for: self.iconView)
        }
//                self.cityLabel.isHidden = false
//                self.cityLabel.text = weatherInfo.name
        
        self.temperatureLabel.text = String(format: "%0.f°C", weatherInfo.current?.temp ?? 0)
        self.feelsLikeLabel.text = String(format: "Ощущается как %0.f°C", weatherInfo.current?.feelsLike ?? 0)

        let description = weatherInfo.current?.weather?[0].weatherDescription ?? ""
        self.descriptionLabel.text = description.prefix(1).capitalized + description.dropFirst()

    }
    
    
    private func updateWeaterIcon(with iconId: String, for imageView: UIImageView) {
        startAnimate(view: iconView)
        
        NetworkManager.shared.fetchWeatherIcon(with: iconId) { data in
            
            DispatchQueue.main.async {
                self.stopAnimateView(view: self.iconView)
            }
            
            guard let data = data, let icon = UIImage(data: data) else { return }

            DispatchQueue.main.async {
                imageView.image = icon
            }
        }
    }
    
    private func startAnimate(view: UIView) {
        UIView.animate(withDuration: 0.85, delay: 0, options: [.repeat, .autoreverse] ) {
            view.alpha = 0
        }
    }
    
    private func stopAnimateView(view: UIView) {
        view.layer.removeAllAnimations()
        view.alpha = 1
    }
}

extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else { return }
        
        if needUpdateWeather(with: location) {
            lastLocation = location
            
            updateWeather(latitude: location.coordinate.latitude,
                          longtiture: location.coordinate.longitude)
        }
    }
    
    func needUpdateWeather(with location: CLLocation) -> Bool {
        guard let lastLocation = lastLocation else { return true }
        
        let distanceSignificantlyChanged = location.distance(from: lastLocation) > 500
        let significantTimePassed = lastLocation.timestamp.distance(to: location.timestamp) > 60
        
        return distanceSignificantlyChanged || significantTimePassed
    }
}

extension WeatherViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        min(12, weatherInfo?.hourly?.count ?? 0)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "forecastCell", for: indexPath)
        
        configureCell(cell, with: weatherInfo?.hourly?[indexPath.item])
        
        return cell
    }
    
    func configureCell(_ cell: UICollectionViewCell, with forecastItem: Current?) {
        guard let forecastCell = cell as? CollectionViewCell else { return }
        guard let forecastItem = forecastItem else { return }
    
        let date = Date(timeIntervalSince1970: Double(forecastItem.dt ?? 0))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        formatter.timeZone = TimeZone(secondsFromGMT: weatherInfo?.timezoneOffset ?? 0)

        forecastCell.timeLabel.text = formatter.string(from: date)

        forecastCell.temperatureLabel.text = String(format: "%0.f°C", forecastItem.temp ?? 0)
        
        if let iconId = forecastItem.weather?[0].icon {
            self.updateWeaterIcon(with: iconId, for: forecastCell.weatherIcon)
        }
    }
}


