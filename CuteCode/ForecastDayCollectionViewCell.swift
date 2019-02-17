//
//  ForecastDayCollectionViewCell.swift
//  CuteCode
//
//  Created by Iain Frame on 17/02/2019.
//  Copyright © 2019 PointPixel. All rights reserved.
//

import UIKit

class ForecastDayCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func applyIcon(fraction: ForecastFraction) {
        if let weatherIcon = fraction.overview.first?.icon, let url = URL(string: "https://openweathermap.org/img/w/\(weatherIcon).png") {
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    let data: Data = try Data(contentsOf: url)
                    let img = UIImage(data: data)
                    DispatchQueue.main.async {
                        self.imageView.image = img
                    }
                } catch {
                    //TODO: Assign a default image from the bundle
                }
            }
        }
    }
}
