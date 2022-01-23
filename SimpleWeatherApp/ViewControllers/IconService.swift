//
//  ImageCache.swift
//  SimpleWeatherApp
//
//  Created by Сашок on 23.01.2022.
//

import UIKit

class IconService {
    
    static let shared = IconService()
    
    private let imageCache = NSCache<NSString, UIImage>()
    
    func getIcon(with iconId: String, completion: @escaping(Result<UIImage, NetworkError>) -> Void) {
        
        if let cachedImage = imageCache.object(forKey: iconId as NSString) {
            completion(.success(cachedImage))
        }
        
        NetworkManager.shared.fetchWeatherIcon(with: iconId) { result in
            switch result {
            case .success(let data):
                guard let icon = UIImage(data: data) else { return }
                self.imageCache.setObject(icon, forKey: iconId as NSString)
                completion(.success(icon))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private init() {}
}
