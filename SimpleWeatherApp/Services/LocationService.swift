//
//  ImageService.swift
//  SimpleWeatherApp
//
//  Created by Сашок on 23.01.2022.
//

import Foundation
import CoreLocation

class LocationService {
    static let shared = LocationService()
    
    func getCity(from location: CLLocation, completion: @escaping (Result<CLPlacemark, Error>) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                completion(.failure(error))
                return
            }
                
            guard let placemark = placemarks?.first else {
                completion(.failure(CLError(.locationUnknown)))
                return
            }
                
            completion(.success(placemark))
        }
    }
    
    private init() {}
}
