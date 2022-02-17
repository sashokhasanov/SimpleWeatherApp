//
//  ForecastTableViewCell.swift
//  SimpleWeatherApp
//
//  Created by Сашок on 17.02.2022.
//

import UIKit

class ForecastTableViewCell: UITableViewCell {
    
    static let reuseId = "ForecastTableViewCell"
    
    private let numberOfItems = 12
    private var forecast: [Current]?
    private var timezoneOffest: Int?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.register(ForecastCollectionViewCell.nib(),
                                forCellWithReuseIdentifier: ForecastCollectionViewCell.reuseId)

        collectionView.delegate = self
        collectionView.dataSource = self
    }

    static func nib() -> UINib {
        UINib(nibName: reuseId, bundle: nil)
    }
    
    func configure(with forecastData: [Current]?, timezoneOffset: Int?) {
        forecast = forecastData
        collectionView.reloadData()
    }
}

extension ForecastTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        min(numberOfItems, forecast?.count ?? 0)
//        12
    }
}

extension ForecastTableViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ForecastCollectionViewCell.reuseId, for: indexPath)
        
        if let forecastCell = cell as? ForecastCollectionViewCell, let current = forecast?[indexPath.item] {
            forecastCell.configure(with: current, timeZoneOffset: timezoneOffest ?? 0)
        }
        
        return cell
    }
}

extension ForecastTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 70, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
}
