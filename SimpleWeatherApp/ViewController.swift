//
//  ViewController.swift
//  SimpleWeatherApp
//
//  Created by Сашок on 14.01.2022.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var mainInfoView: UIStackView!
    @IBOutlet weak var cityLabel: UILabel!
    
    // MARK: - Private properties
    private let locationManager = CLLocationManager()
    
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

            DispatchQueue.main.async {
                if let iconId = weatherInfo.weather?[0].icon {
                    self.updateWeaterIcon(for: iconId)
                }
                self.cityLabel.isHidden = false
                self.cityLabel.text = weatherInfo.name
                
                self.temperatureLabel.text = String(format: "%0.f°C", weatherInfo.main?.temp ?? 0)
                self.feelsLikeLabel.text = String(format: "Ощущается как %0.f°C", weatherInfo.main?.feelsLike ?? 0)

                let description = weatherInfo.weather?[0].weatherDescription ?? ""
                self.descriptionLabel.text = description.prefix(1).capitalized + description.dropFirst()
            }
        }
    }
    
    private func updateWeaterIcon(for iconId: String) {
        startAnimate(view: iconView)
        
        NetworkManager.shared.fetchWeatherIcon(with: iconId) { icon in
            DispatchQueue.main.async {
                self.stopAnimateView(view: self.iconView)
            }
            
            guard let icon = icon else { return }

            DispatchQueue.main.async {
                self.iconView.image = icon
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

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        updateWeather(latitude: locValue.latitude, longtiture: locValue.longitude)
    }
}
