//
//  WeatherTableViewController.swift
//  SimpleWeatherApp
//
//  Created by Сашок on 16.02.2022.
//

import UIKit
import CoreLocation

class WeatherTableViewController: UITableViewController {

    // MARK: - Private properties
    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocation?
    private var weatherInfo: WeatherInfo?

    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(MainInfoTableViewCell.nib(), forCellReuseIdentifier: MainInfoTableViewCell.reuseId)
        tableView.register(ForecastTableViewCell.nib(), forCellReuseIdentifier: ForecastTableViewCell.reuseId)
        
        setupRefreshControl()
        setupLocation()
    }
    
    // MARK: - Private methods
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(updateWeather), for: .valueChanged)
    }
    
    private func setupLocation() {
        locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func updateCurrentCity() {
        
        guard let location = lastLocation else { return }
        
        LocationService.shared.getCity(from: location) { result in
            switch result{
            case .success(let placemark):
                DispatchQueue.main.async {
                    self.navigationItem.title = placemark.locality
                }
            case .failure(let error):
                // TODO log error
                print(error)
            }
        }
    }
    
    @objc private func updateWeather() {
        guard let location = lastLocation else { return }
        
        WeatherService.shared.getWeatherData(latitude: location.coordinate.latitude,
                                             longtitude: location.coordinate.longitude) { result in
            self.endRefreshing()
            
            switch result {
            case .failure(let error):
                // TODO log error
                print(error)
            case .success(let weatherInfo):
                self.weatherInfo = weatherInfo
                self.tableView.reloadData()
            }
        }
    }

    private func beginRefreshing() {
        guard let refreshControl = refreshControl else { return }
        
        let verticalOffset = tableView.contentOffset.y - refreshControl.frame.size.height
        
        refreshControl.beginRefreshing()
        tableView.setContentOffset(CGPoint(x: 0, y: verticalOffset), animated: true)
    }
    
    private func endRefreshing() {
        refreshControl?.endRefreshing()
    }
    
    private enum WeatherSection: Int, CaseIterable {
        case main = 0
        case forecast = 1
        
        var title: String {
            switch self {
            case .main:
                return ""
            case .forecast:
                return "Почасовой прогноз"
            }
        }
        
        var cellReuseId: String {
            switch self {
            case .main:
                return MainInfoTableViewCell.reuseId
            case .forecast:
                return ForecastTableViewCell.reuseId
            }
        }
    }
}

// MARK: - Table view data source
extension WeatherTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return WeatherSection.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let weatherSection = WeatherSection(rawValue: indexPath.section) else {
            fatalError("Unknown weather section type")
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: weatherSection.cellReuseId, for: indexPath)
        
        if let mainInfoCell = cell as? MainInfoTableViewCell {
            mainInfoCell.configure(with: weatherInfo?.current)
        } else if let forecastCell = cell as? ForecastTableViewCell {
            forecastCell.configure(with: weatherInfo?.hourly, timezoneOffset: weatherInfo?.timezoneOffset)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0
        {
            return UITableView.automaticDimension
        }
        return 140
        
//        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        guard let sectionType = WeatherSection(rawValue: section) else {
            return nil
        }
        
        return sectionType.title
    }
}

// MARK: - Location manager delegate
extension WeatherTableViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        if needUpdateWeather(with: location) {
            lastLocation = location
            
            beginRefreshing()
            updateCurrentCity()
            updateWeather()
        }
    }
    
    func needUpdateWeather(with location: CLLocation) -> Bool {
        guard let lastLocation = lastLocation else { return true }
        
        let distanceSignificantlyChanged = location.distance(from: lastLocation) > 1000
        let significantTimePassed = lastLocation.timestamp.distance(to: location.timestamp) > 60
        
        return distanceSignificantlyChanged || significantTimePassed
    }
}
