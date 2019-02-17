//
//  ForecastDayDataSource.swift
//  CuteCode
//
//  Created by Iain Frame on 17/02/2019.
//  Copyright © 2019 PointPixel. All rights reserved.
//

import UIKit

class ForecastDayDataSource: NSObject, UICollectionViewDataSource {
    
    var forecastFractions: [ForecastFraction]
    
    init(fractions: [ForecastFraction]) {
        self.forecastFractions = fractions
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.forecastFractions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "forecast-fraction-cell", for: indexPath) as? ForecastDayCollectionViewCell {
            cell.applyIcon(fraction: self.forecastFractions[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
    
    
    
}
