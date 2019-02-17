//
//  File.swift
//  WiproWeather
//
//  Created by Iain Frame on 11/02/2019.
//  Copyright © 2019 PointPixel. All rights reserved.
//

import Foundation

///Forecast fraction
/// - Represents a 3h view of one days weather
struct ForecastFraction: Decodable {
    
    struct Main: Decodable {
        let temperature: Double
        let minimumTemperature: Double
        let maximumTemperature: Double
        let pressure: Double
        let seaLevel: Double
        let groundLevel: Double
        let humidity: Int
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: MainKeys.self)
            
            self.temperature = try container.decode(Double.self, forKey: .temperature)
            self.minimumTemperature = try container.decode(Double.self, forKey: .minimumTemperature)
            self.maximumTemperature = try container.decode(Double.self, forKey: .maximumTemperature)
            self.pressure = try container.decode(Double.self, forKey: .pressure)
            self.seaLevel = try container.decode(Double.self, forKey: .seaLevel)
            self.groundLevel = try container.decode(Double.self, forKey: .groundLevel)
            self.humidity = try container.decode(Int.self, forKey: .humidity)
        }
        
        enum MainKeys: String, CodingKey {
            case temperature = "temp"
            case minimumTemperature = "temp_min"
            case maximumTemperature = "temp_max"
            case pressure = "pressure"
            case seaLevel = "sea_level"
            case groundLevel = "grnd_level"
            case humidity = "humidity"
        }
    }
    
    struct Overview: Decodable {
        let main: String
        let description: String
        let icon: String
    }
    
    struct Wind: Decodable {
        let speed: Double
        let direction: Double
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: WindKeys.self)
            
            self.speed = try container.decode(Double.self, forKey: .speed)
            self.direction = try container.decode(Double.self, forKey: .direction)
        }
        
        enum WindKeys: String, CodingKey {
            case speed = "speed"
            case direction = "deg"
        }
    }
    
    struct Rain: Decodable {
        let amount: Double?
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: RainKeys.self)
            
            self.amount = try container.decodeIfPresent(Double.self, forKey: .amount)
        }
        
        enum RainKeys: String, CodingKey {
            case amount = "3h"
        }
    }
    
    let forecastDate: Date
    let main: Main
    let overview: [Overview]
    let wind: Wind
    let rain: Rain
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ForecastKeys.self)
        
        let dateString = try container.decode(String.self, forKey: .forecastDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.forecastDate = dateFormatter.date(from: dateString) ?? Date()
        
        self.main = try container.decode(Main.self, forKey: .main)
        self.overview = try container.decode([Overview].self, forKey: .overview)
        self.wind = try container.decode(Wind.self, forKey: .wind)
        self.rain = try container.decode(Rain.self, forKey: .rain)
    }
    
    enum ForecastKeys: String, CodingKey {
        case forecastDate = "dt_txt"
        case main = "main"
        case overview = "weather"
        case wind = "wind"
        case rain = "rain"
    }
}
