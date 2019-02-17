//
//  ForecastModel.swift
//  WiproWeather
//
//  Created by Iain Frame on 11/02/2019.
//  Copyright © 2019 PointPixel. All rights reserved.
//

import Foundation

///Forecast Model object
/// - Represents a list of forecast fractions from multiple days forecasts
struct Forecast: Decodable {
    let cod: String
    let message: Double
    let cnt: Int
    let list: [ForecastFraction]
}
