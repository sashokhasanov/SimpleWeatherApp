//
//  ForecastTableViewCell.swift
//  SimpleWeatherApp
//
//  Created by Сашок on 17.02.2022.
//

import UIKit

class HourlyForecastTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Internal properties
    static let reuseId = "HourlyForecastTableViewCell"
    
    static var requiredHeight: CGFloat {
        forecastCellSize.height + contentInsets.top + contentInsets.bottom
    }
    
    // MARK: - Private properties
    private static let forecastCellSize = CGSize(width: 70, height: 120)
    private static let contentInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    private static let numberOfItems = 12
    
    private var forecast: [Current]?
    private var timezoneOffest: Int?
    
    // MARK: - Override methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.register(HourlyForecastCollectionViewCell.nib(),
                                forCellWithReuseIdentifier: HourlyForecastCollectionViewCell.reuseId)

        collectionView.delegate = self
        collectionView.dataSource = self
    }

    static func nib() -> UINib {
        UINib(nibName: reuseId, bundle: nil)
    }
    
    func configure(with forecast: [Current]?, timezoneOffset: Int?) {
        self.forecast = forecast
        self.timezoneOffest = timezoneOffset
        collectionView.reloadData()
    }
}

// MARK: - Collection view data source
extension HourlyForecastTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        min(HourlyForecastTableViewCell.numberOfItems, forecast?.count ?? 0)
    }
}

// MARK: - Collection view delegate
extension HourlyForecastTableViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourlyForecastCollectionViewCell.reuseId, for: indexPath)
        
        if let forecastCell = cell as? HourlyForecastCollectionViewCell {
            forecastCell.configure(with: forecast?[indexPath.item], timeZoneOffset: timezoneOffest)
        }
        
        return cell
    }
}

// MARK: - Collection view delegate flow layout
extension HourlyForecastTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        HourlyForecastTableViewCell.forecastCellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        HourlyForecastTableViewCell.contentInsets
    }
}
