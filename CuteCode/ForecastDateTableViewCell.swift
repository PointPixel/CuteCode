//
//  ForecastFractionTableViewCell.swift
//  WiproWeather
//
//  Created by Iain Frame on 12/02/2019.
//  Copyright © 2019 PointPixel. All rights reserved.
//

import UIKit

class ForecastDateTableViewCell: UITableViewCell {
    
    @IBOutlet weak var forecastCollectionView: UICollectionView!
    
    private var dayDataSource: ForecastDayDataSource?
    
    func bindForecastFractions(fractions: [ForecastFraction]) {
        self.dayDataSource =  ForecastDayDataSource(fractions: fractions)
        self.forecastCollectionView.dataSource = self.dayDataSource
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
