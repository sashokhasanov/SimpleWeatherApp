//
//  ViewController.swift
//  SimpleWeatherApp
//
//  Created by Сашок on 14.01.2022.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func buttonPressed(_ sender: UIButton) {
        
        guard let url = makeQueryUrl() else { return }
        
        
        
        URLSession.shared.weatherInfoTask(with: url) { weatherInfo, response, error in
            guard let weatherInfo = weatherInfo else { return }
            
            print(weatherInfo.name)
            
        }.resume()
    }
    
    private let apiKey = "e44c551160dc50f8423bc7d7db2805a5"
    
    func makeQueryUrl() -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5/weather"
        components.queryItems = [
            URLQueryItem(name: "q", value: "Moscow"),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "lang", value: "ru"),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        
        return components.url
    }
}

