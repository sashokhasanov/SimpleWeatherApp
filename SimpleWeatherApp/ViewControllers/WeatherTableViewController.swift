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
            updateCurrentCity()
            updateWeather()
        }
    }

    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(MainInfoTableViewCell.nib(), forCellReuseIdentifier: MainInfoTableViewCell.reuseId)
        tableView.register(HourlyForecastTableViewCell.nib(), forCellReuseIdentifier: HourlyForecastTableViewCell.reuseId)
        tableView.register(DailyForecastTableViewCell.nib(), forCellReuseIdentifier: DailyForecastTableViewCell.reuseId)
        
        setupRefreshControl()
        setupLocation()
    }

    // MARK: - Private methods
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(updateWeather), for: .valueChanged)
    }
    
    private func setupLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            
            locationManager.requestWhenInUseAuthorization()
            
            if locationManager.authorizationStatus != .notDetermined {
                locationManager.requestLocation()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.showAlert(title: "Опаньки 😥",
                          message: "Кажется, на устройстве отключены сервисы геолокации.\nВключите их и перезапустите приложение.")
            }
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
                print(error)
            }
        }
    }

    @objc private func updateWeather() {
        guard let location = lastLocation else {
            locationManager.requestLocation()
            return
        }
        
        WeatherService.shared.getWeatherData(latitude: location.coordinate.latitude,
                                             longtitude: location.coordinate.longitude) { result in
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
            }
            
            switch result {
            case .failure(let error):
                print(error)
            case .success(let weatherInfo):
                DispatchQueue.main.async {
                    self.weatherInfo = weatherInfo
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ок", style: .default)
        alertController.addAction(alertAction)
        present(alertController, animated: true)
    }
}

// MARK: - Private enum that defines table sections
extension WeatherTableViewController {

    private enum WeatherSection: Int, CaseIterable {
        case main = 0
        case hourlyForecast = 1
        case dailyForecast = 2
        
        var title: String {
            switch self {
            case .main:
                return ""
            case .hourlyForecast:
                return "Почасовой прогноз"
            case .dailyForecast:
                return "Прогноз на 7 дней"
            }
        }
        
        var cellReuseId: String {
            switch self {
            case .main:
                return MainInfoTableViewCell.reuseId
            case .hourlyForecast:
                return HourlyForecastTableViewCell.reuseId
            case .dailyForecast:
                return DailyForecastTableViewCell.reuseId
            }
        }
        
        var rowsRequired: Int {
            switch self {
            case .main:
                return 1
            case .hourlyForecast:
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
        } else if let forecastCell = cell as? HourlyForecastTableViewCell {
            forecastCell.configure(with: weatherInfo?.hourly, timezoneOffset: weatherInfo?.timezoneOffset)
        } else if let dailyForecastCell = cell as? DailyForecastTableViewCell {
            dailyForecastCell.configure(with: weatherInfo?.daily?[indexPath.row], timeZoneOffset: weatherInfo?.timezoneOffset)
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        guard let sectionType = WeatherSection(rawValue: section) else {
            return nil
        }

        return sectionType.title
    }
}

// MARK: - Table view delegate
extension WeatherTableViewController {

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let weatherSection = WeatherSection(rawValue: indexPath.section) else {
            fatalError("Unknown weather section type")
        }
        
        switch weatherSection {
        case .hourlyForecast:
            return HourlyForecastTableViewCell.requiredHeight
        default:
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        50
    }
}

// MARK: - Location manager delegate
extension WeatherTableViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        // need this check because CLLocationManager.requestLocation()
        // may cause multiple updates instead of one
        if lastLocation == nil {
            lastLocation = location
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        DispatchQueue.main.async {
            self.refreshControl?.endRefreshing()
        }
        
        if let error = error as? CLError {
            switch error.code {
            case CLError.Code.locationUnknown:
                showAlert(title: "Опаньки 😥",
                          message: "Не удалось определить геопозицию. Попробуйте еще раз.")
            case CLError.Code.denied:
                showAlert(title: "Опаньки 😥",
                          message: "Пожалуйста, разрешите приложению доступ к геопозиции.")
            default:
                print("Location manager error: \(error.localizedDescription)")
            }
            
        } else {
            print(error.localizedDescription)
        }
    }
}
