//
//  ForecastRequest.swift
//  WiproWeather
//
//  Created by Iain Frame on 11/02/2019.
//  Copyright © 2019 PointPixel. All rights reserved.
//

import Foundation

class ForecastRequest {
    private let apiKey: String = "25c89615e07fcce3c58ebe611fcb89d4"
    private let baseUrlString: String = "https://api.openweathermap.org/data/2.5/forecast"
    private let url: String
    
    init?(cityId: String) {
        //TODO: Add guard condition around the city id format to ensure its valid
        self.url = baseUrlString + "?id=" + cityId + "&APPID=" + self.apiKey
    }
    
    func loadForecast(success: @escaping (Forecast) -> Void, failure: @escaping (String) -> Void) {
        NetworkManager.shared.get(urlString: self.url,
                            successfulCodes: [200],
                       businessFailureCodes: [404]) { (result: RequestResultObject<Forecast>) in
                        switch result {
                        case .success(let forecast):
                            success(forecast)
                        //TODO: Improve error handling with stronger typed Error entity
                        case .businessFailure(let statusCode):
                            failure("Couldn't find the forecast due to \(String(describing: statusCode))")
                        case .parsingFailure(let message):
                            failure("It appears there was a failure in parsing \(message)")
                        case .transportFailure(let error):
                            failure("Somethings gone a bit arwy with networking \(error)")
                        case .completeFailure(let message):
                            failure("An unexpected error has occurred \(message ?? "")")
                        }
                        
        }

    }
}
