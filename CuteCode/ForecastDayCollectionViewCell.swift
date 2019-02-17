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
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    
    func applyWeatherFraction(fraction: ForecastFraction) {
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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        timeLabel.text = dateFormatter.string(from: fraction.forecastDate)
        let celciusFormat = String.init(format: "%0.2f˚C", fraction.main.temperature - 273.15)
        tempLabel.text = celciusFormat
    }
}
