//
//  ImageManager.swift
//  SimpleWeatherApp
//
//  Created by Сашок on 23.01.2022.
//

import UIKit

class ImageService {
    static let shared = ImageService()
    
    private let imageCache = NSCache<NSString, UIImage>()
    
    private init() {}
    
    func getIcon(with iconId: String, completion: @escaping(Result<UIImage, NetworkError>) -> Void) {
        
        if let cachedImage = imageCache.object(forKey: iconId as NSString) {
            completion(.success(cachedImage))
            return
        }
        
        guard let iconUrl = makeIconRequestUrl(for: iconId) else { return }
        
        NetworkManager.shared.fetchData(from: iconUrl) { result in
            // TODO remove before release
            sleep(2)
            
            switch result {
            case .success(let data):
                guard let icon = UIImage(data: data) else { return }
                self.imageCache.setObject(icon, forKey: iconId as NSString)
                
                DispatchQueue.main.async {
                    completion(.success(icon))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func makeIconRequestUrl(for iconId: String) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "openweathermap.org"
        components.path = "/img/wn/\(iconId)@2x.png"

        return components.url
    }
}
