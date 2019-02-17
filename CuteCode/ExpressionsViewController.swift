//
//  ViewController.swift
//  expressions
//
//  Created by Iain Frame on 12/02/2019.
//  Copyright © 2019 PointPixel. All rights reserved.
//

import UIKit

class ExpressionsViewController: UIViewController {

    @IBOutlet weak var circularExpressionsButton: UIButton!
    @IBOutlet weak var horizontalExpressionsButton: UIButton!
    @IBOutlet weak var verticalExpressionsButton: UIButton!
    @IBOutlet weak var selectedExpressionLabel: UILabel!
    
    private var circularExpressionsOverlayView: ExpressionsOverlayView?
    private var horizontalExpressionsOverlayView: ExpressionsOverlayView?
    private var verticalExpressionsOverlayView: ExpressionsOverlayView?
    
    private var selectedExpressionList: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.circularExpressionsOverlayView == nil {
            self.selectedExpressionList = [ "😎", "🍺", "🥐", "🐙", "🙍‍♂️", "🤓", "😡" ]
            self.circularExpressionsOverlayView = ExpressionsOverlayView(frame: self.circularExpressionsButton.frame,
                                                                expressionList: self.selectedExpressionList!,
                                                            expressionDiameter: 36, kind: .circular(1.0, 0.4))
            self.circularExpressionsOverlayView?.delegate = self
            self.circularExpressionsOverlayView?.isUserInteractionEnabled = true
            self.view.addSubview(self.circularExpressionsOverlayView ?? UIView())
        }
        
        if self.horizontalExpressionsOverlayView == nil {
            self.selectedExpressionList = [ "😎", "🍺", "🥐", "🐙", "🙍‍♂️", "🤓" ]
            self.horizontalExpressionsOverlayView = ExpressionsOverlayView(frame: self.horizontalExpressionsButton.frame,
                                                                         expressionList: self.selectedExpressionList!,
                                                                         expressionDiameter: 32, kind: .straight(.horizontal, 0.75, 0.4))
            self.horizontalExpressionsOverlayView?.delegate = self
            self.horizontalExpressionsOverlayView?.isUserInteractionEnabled = true
            self.view.addSubview(self.horizontalExpressionsOverlayView ?? UIView())
        }

        if self.verticalExpressionsOverlayView == nil {
            self.selectedExpressionList = [ "😎", "🍺", "🥐", "🐙", "🙍‍♂️", "🤓", "🥺", "🥳", "🤢"]
            self.verticalExpressionsOverlayView = ExpressionsOverlayView(frame: self.verticalExpressionsButton.frame,
                                                                           expressionList: self.selectedExpressionList!,
                                                                           expressionDiameter: 32, kind: .straight(.vertical, 1.0, 0.4))
            self.verticalExpressionsOverlayView?.delegate = self
            self.verticalExpressionsOverlayView?.isUserInteractionEnabled = true
            self.view.addSubview(self.verticalExpressionsOverlayView ?? UIView())
        }
    }

}

extension ExpressionsViewController: ExpandingExpressionOverlayViewDelegate {
    func overlayViewHandlingGestures() {
        //Do nothing right now - for use in scroll view or subclass of
    }
    
    func overlayViewNotHandlingGestures() {
        //Do nothing right now - for use in scroll view or subclass of
    }
    
    func expressionWasSelected(item: String) {
        self.selectedExpressionLabel.text = item
    }
}
