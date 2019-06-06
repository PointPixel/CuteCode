//
//  ForecastDataSource.swift
//  WiproWeather
//
//  Created by Iain Frame on 12/02/2019.
//  Copyright © 2019 PointPixel. All rights reserved.
//

import UIKit

/// ForecastDataSourceUpdateable
/// - Indicates to implementing class that ForecastDataSource has either succeeded or failed
protocol ForecastDataSourceUpdateable {
    func forecastDataDidUpdate() -> Void
    func forecastDataDidError(message: String) -> Void
}

/// ForecastDataSource
/// - Offers tableview data source and requests necessary data for forecasts from data layer
class ForecastDataSource: NSObject, UITableViewDataSource {
    
    var forecastDates: [Date]?
    var forecast: Forecast?
    var updateTarget: ForecastDataSourceUpdateable?
    private let oneDayInHours: TimeInterval = 86400.0
    
    // MARK: Data loading
    func populateData() {
        let glasgowCityId: String = "2648579"
        let forecastRequest = ForecastRequest(cityId: glasgowCityId)
        
        forecastRequest?.loadForecast(success: { (forecast) in
            self.forecast = forecast
            self.forecastDates = self.extractUniqueForecastDates(forecast: forecast)
            self.updateTarget?.forecastDataDidUpdate()
        }, failure: { (message) in
            self.updateTarget?.forecastDataDidError(message: message)
        })
    }
    
    //TODO - Move this to the data layer - data organiser type class
    func extractUniqueForecastDates(forecast: Forecast) -> [Date] {
        let forecastDates = forecast.list.compactMap {$0.forecastDate}
        let formattedDates = forecastDates.compactMap { (date) -> Date? in
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: date)
            components.hour = 0
            components.minute = 0
            components.second = 0
            return calendar.date(from: components)!
        }
        let uniqueDates: Set<Date> = Set<Date>(formattedDates)
        return uniqueDates.sorted(by: <)
    }
    
    //TODO - Move this to the data layer - data organiser for querying the forecast object
    /// Extracts the forecast fractions for requested date
    func extractDayForecast(forecast: Forecast, requiredDate: Date) -> [ForecastFraction] {
        let fractions = forecast.list.filter { (fraction) -> Bool in
            //Determine the fraction datetime lies within the request day
            return fraction.forecastDate.timeIntervalSince1970 - requiredDate.timeIntervalSince1970 > 0 && fraction.forecastDate.timeIntervalSince1970 - requiredDate.timeIntervalSince1970 <= self.oneDayInHours
        }
        return fractions
    }
    
    // MARK: Table View Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.forecastDates?.count ?? 5 //Limiting to 5 days worth of forecast so each section will represent a day
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "simple-weather-cell", for: indexPath) as? ForecastDateTableViewCell {
            if let uniqueDate = self.forecastDates?[indexPath.section], let forecast = self.forecast {
                let daysForecast = self.extractDayForecast(forecast: forecast, requiredDate: uniqueDate)
                cell.bindForecastFractions(fractions: daysForecast)
                return cell
            }
            
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let dates = self.forecastDates {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yy-MM-dd"
            return dateFormatter.string(from: dates[section])
        } else {
            return ""
        }
    }
}
