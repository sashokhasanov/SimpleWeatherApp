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

        NetworkManager.shared.fetchWeatherData(latitude: latitude, longtitude: longtiture) { result in
            DispatchQueue.main.async {
                self.stopAnimateView(view: self.mainInfoView)
            }
            
            switch result {
            case .failure(let error):
                // TODO log error
                print(error)
            case .success(let weatherInfo):
                self.weatherInfo = weatherInfo
                
                DispatchQueue.main.async {
                    self.updateCurrentWeatherView()
                    self.forecastView.reloadSections(IndexSet(integersIn: 0...0))
                }
            }
        }
    }

    private func updateCurrentWeatherView() {
        guard let weatherInfo = weatherInfo else { return }
        
        if let iconId = weatherInfo.current?.weather?[0].icon {
            self.updateWeaterIcon(with: iconId, for: self.iconView)
        }
        
        // TODO city label
//                self.cityLabel.isHidden = false
//                self.cityLabel.text = weatherInfo.name
        
        self.temperatureLabel.text = String(format: "%0.f°C", weatherInfo.current?.temp ?? 0)
        self.feelsLikeLabel.text = String(format: "Ощущается как %0.f°C", weatherInfo.current?.feelsLike ?? 0)

        let description = weatherInfo.current?.weather?[0].weatherDescription ?? ""
        self.descriptionLabel.text = description.prefix(1).capitalized + description.dropFirst()

    }
    
    private func updateWeaterIcon(with iconId: String, for imageView: UIImageView) {
        startAnimate(view: imageView)
        
        DispatchQueue.global().async {
            let data = NetworkManager.shared.fetchWeatherIcon(with: iconId)
            
            DispatchQueue.main.async {
                self.stopAnimateView(view: imageView)
            }
            
            guard let data = data else { return }

            DispatchQueue.main.async {
                imageView.image = UIImage(data: data)
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
            
            getPlace(for: location) { placemark in
                guard let placemark = placemark else {
                    return
                }

                DispatchQueue.main.async {
                    self.cityLabel.isHidden = false
                    self.cityLabel.text = placemark.locality
                }
            }
            
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
    
    
    func getPlace(for location: CLLocation, completion: @escaping (CLPlacemark?) -> Void) {
            
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
                
            guard error == nil else {
                print(error!.localizedDescription)
                completion(nil)
                return
            }
                
            guard let placemark = placemarks?[0] else {
                print("*** Error in \(#function): placemark is nil")
                completion(nil)
                return
            }
                
            completion(placemark)
        }
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
    
    private func configureCell(_ cell: UICollectionViewCell, with forecastItem: Current?) {
        guard let forecastCell = cell as? CollectionViewCell else { return }
        guard let forecastItem = forecastItem else { return }
    
        forecastCell.timeLabel.text =
            getHourFromTimestamp(forecastItem.dt ?? 0, offset: weatherInfo?.timezoneOffset ?? 0)

        forecastCell.temperatureLabel.text = String(format: "%0.f°C", forecastItem.temp ?? 0)
        
        if let iconId = forecastItem.weather?[0].icon {
            updateWeaterIcon(with: iconId, for: forecastCell.weatherIcon)
        }
    }
    
    private func getHourFromTimestamp(_ timestamp: Int, offset timezoneOffset: Int) -> String {
        let date = Date(timeIntervalSince1970: Double(timestamp))
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        formatter.timeZone = TimeZone(secondsFromGMT: timezoneOffset)
        
        return formatter.string(from: date)
    }
}


