//
//  WiproWeatherTests.swift
//  WiproWeatherTests
//
//  Created by Iain Frame on 11/02/2019.
//  Copyright © 2019 PointPixel. All rights reserved.
//

import XCTest
@testable import WiproWeather

class WiproWeatherTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testValidForecastFraction() {
        let fileName: String = "ForecastFraction"
        if let jsonFileUrl = Bundle(for: WiproWeatherTests.self).url(forResource: fileName, withExtension: "json"){
            do {
                let fileData = try Data(contentsOf: jsonFileUrl)
                if let expectedJsonObject = try JSONSerialization.jsonObject(with: fileData, options: .allowFragments) as? [String:Any] {
                    
                    
                    guard let dateTimeString: String = expectedJsonObject["dt_txt"] as? String else {
                        XCTFail("Unable to parse date from file \(fileName)")
                        return
                    }
                    
                    guard let weatherObject: [[String : Any]] = expectedJsonObject["weather"] as? [[String : Any]],
                        let expectedWeatherDescription: String = weatherObject.first?["description"] as? String else {
                        XCTFail("Unable to parse weather description from file \(fileName)")
                        return
                    }
                    
                    let jsonDecoder = JSONDecoder()
                    let forecastFraction = try jsonDecoder.decode(ForecastFraction.self, from: fileData)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let expectedDate = dateFormatter.date(from: dateTimeString)
                    
                    XCTAssert(forecastFraction.forecastDate == expectedDate)
                    XCTAssert(forecastFraction.overview.first?.description == expectedWeatherDescription)
                    
                } else {
                    XCTFail("Unable to parse sample json file \(fileName)")
                }
            } catch {
                XCTFail("Failed loading json file \(fileName) with error \(error)")
            }
        } else {
            XCTFail("Unable to locate sample file \(fileName)")
        }
    }

    func testForecastFractionNoRain() {
        let fileName: String = "ForecastFractionNoRain"
        if let jsonFileUrl = Bundle(for: WiproWeatherTests.self).url(forResource: fileName, withExtension: "json"){
            do {
                let fileData = try Data(contentsOf: jsonFileUrl)
                if let _ = try JSONSerialization.jsonObject(with: fileData, options: .allowFragments) as? [String:Any] {
                
                    let jsonDecoder = JSONDecoder()
                    let forecastFraction = try jsonDecoder.decode(ForecastFraction.self, from: fileData)
                    
                    XCTAssertNil(forecastFraction.rain.amount)
                    
                } else {
                    XCTFail("Unable to parse sample json file \(fileName)")
                }
            } catch {
                XCTFail("Failed loading json file \(fileName) with error \(error)")
            }
        } else {
            XCTFail("Unable to locate sample file \(fileName)")
        }
    }
    
    func testMultipleForecastFractions() {
        let fileName: String = "MultipleForecastFractions"
        if let jsonFileUrl = Bundle(for: WiproWeatherTests.self).url(forResource: fileName, withExtension: "json"){
            do {
                let fileData = try Data(contentsOf: jsonFileUrl)
                if let expectedJsonObject = try JSONSerialization.jsonObject(with: fileData, options: .allowFragments) as? [String:Any] {
                    
                    if let fractionList = expectedJsonObject["list"] as? [[String : Any]] {
                        let jsonDecoder = JSONDecoder()
                        let forecast: Forecast = try jsonDecoder.decode(Forecast.self, from: fileData)
                        XCTAssert(forecast.cnt == fractionList.count)
                    } else {
                        XCTFail("Unable to parse multiple fractions from \(fileName)")
                    }
                    
                } else {
                    XCTFail("Unable to parse sample json file \(fileName)")
                }
            } catch {
                XCTFail("Failed loading json file \(fileName) with error \(error)")
            }
        } else {
            XCTFail("Unable to locate sample file \(fileName)")
        }
    }

}
