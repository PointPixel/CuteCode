//
//  ForecastNetworkManager.swift
//  WiproWeather
//
//  Created by Iain Frame on 11/02/2019.
//  Copyright © 2019 PointPixel. All rights reserved.
//

import Foundation

///RequestResultObject
/// - Possible outcomes of a network request using decodable
enum RequestResultObject<T: Decodable> {
    case success(T)
    case businessFailure(Int?)
    case transportFailure(Error)
    case parsingFailure(String)
    case completeFailure(String?)
}

class NetworkManager {
    
    static let shared: NetworkManager = {
        let networkManager = NetworkManager()
        return networkManager
    }()
    
    private let urlSession: URLSession
    private let requestTimeout: TimeInterval = 30.0
    
    private init() {
        let configuration = URLSessionConfiguration.ephemeral //Choosing to avoid any file system footprint
        configuration.allowsCellularAccess = true
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.tlsMinimumSupportedProtocol = .tlsProtocol12
        configuration.timeoutIntervalForRequest = 30
        
        self.urlSession = URLSession(configuration: configuration)
    }
    
    func get<T>(urlString: String,
                successfulCodes: [Int],
                businessFailureCodes: [Int],
                completion: @escaping (RequestResultObject<T>) -> Void) where T : Decodable {
        if let url: URL = URL(string: urlString) {
            let request: URLRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: self.requestTimeout)
            let dataTask = urlSession.dataTask(with: request) { (data, response, error) in
                
                if let error = error {
                    completion(.transportFailure(error))
                    return
                }
                
                guard let httpResponse: HTTPURLResponse = response as? HTTPURLResponse,
                    successfulCodes.contains(httpResponse.statusCode) else {
                        
                        completion(.businessFailure((response as? HTTPURLResponse)?.statusCode ?? 0))
                        return
                }
                
                if let contentType: String = httpResponse.allHeaderFields["Content-Type"] as? String,
                    contentType == "application/json; charset=utf-8", let responseData: Data = data {
                    do {
                        let jsonDecoder = JSONDecoder()
                        let entity: T = try jsonDecoder.decode(T.self, from: responseData)
                        completion(.success(entity))
                        return
                    } catch {
                        completion(.parsingFailure("There was an error reading your data. \(error)"))
                    }
                }
            }
            dataTask.resume()
        }
    }
}
