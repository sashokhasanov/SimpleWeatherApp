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
    private var weatherInfo: WeatherInfo?
    
    private var lastLocation: CLLocation? {
        didSet {
            beginRefreshing()
            updateCurrentCity()
            updateWeather()
        }
    }
    
    let locationUpdateTimeInterval: TimeInterval = 600

    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(MainInfoTableViewCell.nib(), forCellReuseIdentifier: MainInfoTableViewCell.reuseId)
        tableView.register(ForecastTableViewCell.nib(), forCellReuseIdentifier: ForecastTableViewCell.reuseId)
        tableView.register(DailyForecastTableViewCell.nib(), forCellReuseIdentifier: DailyForecastTableViewCell.reuseId)
        
        setupRefreshControl()
        setupLocation()
    }
    
    // MARK: - Private methods
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(updateWeatherInteractive), for: .valueChanged)
    }
    
    private func setupLocation() {
        locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            locationManager.requestLocation()
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
    
    @objc private func updateWeatherInteractive() {
        
        guard let location = lastLocation, location.timestamp.distance(to: Date()) < locationUpdateTimeInterval else {
            locationManager.requestLocation()
            return
        }
        
        updateWeather()
    }
    
    private func updateWeather() {
        guard let location = lastLocation else { return }
        
        WeatherService.shared.getWeatherData(latitude: location.coordinate.latitude,
                                             longtitude: location.coordinate.longitude) { result in
            DispatchQueue.main.async {
                self.endRefreshing()
            }
            
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
        guard !refreshControl.isRefreshing else { return }
        
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
        case dailyForecast = 2
        
        var title: String {
            switch self {
            case .main:
                return ""
            case .forecast:
                return "Почасовой прогноз"
            case .dailyForecast:
                return "Прогноз на 7 дней"
            }
        }
        
        var cellReuseId: String {
            switch self {
            case .main:
                return MainInfoTableViewCell.reuseId
            case .forecast:
                return ForecastTableViewCell.reuseId
            case .dailyForecast:
                return DailyForecastTableViewCell.reuseId
            }
        }
        
        var rowsRequired: Int {
            switch self {
            case .main:
                return 1
            case .forecast:
                return 1
            case .dailyForecast:
                return 7
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
        
        guard let weatherSection = WeatherSection(rawValue: section) else {
            fatalError("Unknown weather section type")
        }
        
        return weatherSection.rowsRequired
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
        } else if let dailyForecastCell = cell as? DailyForecastTableViewCell {
            dailyForecastCell.configure(with: weatherInfo?.daily?[indexPath.row], timeZoneOffset: weatherInfo?.timezoneOffset)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let weatherSection = WeatherSection(rawValue: indexPath.section) else {
            fatalError("Unknown weather section type")
        }
        
        switch weatherSection {
        case .forecast:
            return ForecastTableViewCell.requiredHeight
        default:
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        guard let sectionType = WeatherSection(rawValue: section) else {
            return nil
        }

        return sectionType.title
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        50
    }
}

// MARK: - Location manager delegate
extension WeatherTableViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        lastLocation = location
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}
