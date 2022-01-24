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
        mainInfoView.startFadeAnimation()

        WeatherService.shared.getWeatherData(latitude: latitude, longtitude: longtiture) { result in

            self.mainInfoView.stopFadeAnimation()
            
            switch result {
            case .failure(let error):
                // TODO log error
                print(error)
            case .success(let weatherInfo):
                self.weatherInfo = weatherInfo
                
                self.updateCurrentWeatherView()
                self.forecastView.reloadSections(IndexSet(integersIn: 0...0))
            }
        }
    }

    private func updateCurrentWeatherView() {
        guard let weatherInfo = weatherInfo else { return }
        
        updateWeaterIcon()
        
        temperatureLabel.text = String(format: "%0.f°C", weatherInfo.current?.temp ?? 0)
        feelsLikeLabel.text = String(format: "Ощущается как %0.f°C", weatherInfo.current?.feelsLike ?? 0)

        let description = weatherInfo.current?.weather?.first?.weatherDescription ?? ""
        descriptionLabel.text = description.prefix(1).capitalized + description.dropFirst()
    }
    
    private func updateWeaterIcon() {
        guard let iconId = weatherInfo?.current?.weather?.first?.icon else {
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
    
    func updateCurrentCity(with location: CLLocation) {
        LocationService.shared.getCity(from: location) { result in
            switch result{
            case .success(let placemark):
                DispatchQueue.main.async {
                    self.cityLabel.isHidden = false
                    self.cityLabel.text = placemark.locality
                }
            case .failure(let error):
                // TODO log error
                print(error)
            }
        }
    }
}

extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        if needUpdateWeather(with: location) {
            lastLocation = location
            
            updateCurrentCity(with: location)
            updateWeather(latitude: location.coordinate.latitude,
                          longtiture: location.coordinate.longitude)
        }
    }
    
    func needUpdateWeather(with location: CLLocation) -> Bool {
        guard let lastLocation = lastLocation else { return true }
        
        let distanceSignificantlyChanged = location.distance(from: lastLocation) > 1000
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
        
        if let forecastCell = cell as? WeatherForecastCell, let current = weatherInfo?.hourly?[indexPath.item] {
            forecastCell.configure(with: current, timeZoneOffset: weatherInfo?.timezoneOffset ?? 0)
        }
        
        return cell
    }
}
