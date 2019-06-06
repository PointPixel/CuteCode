//
//  ViewController.swift
//  WiproWeather
//
//  Created by Iain Frame on 11/02/2019.
//  Copyright © 2019 PointPixel. All rights reserved.
//

import UIKit

/// ForecastViewController
/// - Standard view controller with tableview for listing 5 days of weather
class ForecastViewController: UIViewController {

    @IBOutlet weak var forecastTableView: UITableView!
    @IBOutlet weak var messageLabel: UILabel!

    let forecastDataSource: ForecastDataSource = ForecastDataSource()
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.forecastDataSource.updateTarget = self
        self.forecastTableView.dataSource = self.forecastDataSource
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.forecastDataSource.populateData()
    }
}

extension ForecastViewController: ForecastDataSourceUpdateable {
    func forecastDataDidUpdate() {
        DispatchQueue.main.async {
            self.forecastTableView.isHidden = false
            self.forecastTableView.reloadData()
        }
    }
    
    func forecastDataDidError(message: String) {
        DispatchQueue.main.async {
            self.messageLabel.text = message
            self.forecastTableView.isHidden = true
        }
    }
    
}
