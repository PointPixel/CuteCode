import Foundation
import UIKit

protocol ExpandingExpressionOverlayViewDelegate {
    func overlayViewHandlingGestures()
    func overlayViewNotHandlingGestures()
    func expressionWasSelected(item: String)
}

extension Double {
    var toRadians: Double {
        return self * 0.0174533
    }
}

//TODO: Change buttons to UIViews

class ExpressionsOverlayView: UIView {
    
    enum Orientation {
        case vertical
        case horizontal
    }
    
    enum ExpandingExpressionOverlayType {
        case straight(Orientation, Float, Double)
        case circular(Float, Double)
    }
    
    var expressions: [String]!
    
    var delegate: ExpandingExpressionOverlayViewDelegate?
    
    private var buttons: [UIButton] = [UIButton]()
    private var buttonLocations: [CGRect] = [CGRect]()
    
    private var initialOrigin: CGPoint!
    private var initialSize: CGSize!
    
    private var expressionDiameter: CGFloat!
    private var expressionPulseSize: CGFloat = 2.0
    private var expressionSelectedSize: CGFloat = 1.5
    private let diameterSpacing: CGFloat = 6.0
    private let straightSpacing: CGFloat = 10.0
    
    private var expandedDiameter: CGFloat!
    
    private var debugMode: Bool = false
    
    private var scaledButton: UIButton? = nil
    private var overlayType: ExpandingExpressionOverlayType = .circular(1.0, 0.4)
    
    private var expressionAngle: Double {
        return 360.0 / Double(self.expressions.count)
    }
    
    // MARK: Initialisation
    
    init(frame: CGRect, expressionList: [String], expressionDiameter: CGFloat, kind: ExpandingExpressionOverlayType) {
        super.init(frame: frame)
        self.expressions = expressionList
        self.expressionDiameter = expressionDiameter
        self.initialOrigin = self.frame.origin
        self.initialSize = self.frame.size
        self.overlayType = kind
        
        for expression in self.expressions {
            let btn = UIButton(frame: CGRect(origin: CGPoint.zero,
                                               size: CGSize(width: self.expressionDiameter, height: self.expressionDiameter)))
            
            btn.center = CGPoint(x: (self.frame.minX + self.expressionDiameter / 2.0),
                                 y: (self.frame.size.height / 2.0))
            
            btn.titleLabel?.font = UIFont(name: "Helvetica Neue", size: self.expressionDiameter)
            btn.setTitle(expression, for: .normal)
            btn.isUserInteractionEnabled = false
            btn.isHidden = !self.debugMode
            
            if self.debugMode == true {
                btn.layer.borderWidth = 1.0
                btn.layer.borderColor = UIColor.green.cgColor
            }
            
            self.buttons.append(btn)
            
            self.addSubview(btn)
        }
        
        self.expandedDiameter = ((self.expressionDiameter * self.diameterSpacing) + (CGFloat(self.expressions.count)))
        
        if self.debugMode == true {
            self.layer.borderWidth = 1.0
            self.layer.borderColor = UIColor.red.cgColor
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Gesture handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.presentInstincts()
        self.delegate?.overlayViewHandlingGestures()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        var selectedIndex: Int? = nil
        if let touch = touches.first {
            
            let touchPoint = touch.location(in: self)
            
            for i in 0..<self.buttonLocations.count {
                if self.buttonLocations[i].contains(touchPoint) {
                    selectedIndex = i
                    break
                }
            }
            
            if let index = selectedIndex {
                
                let btn = self.buttons[index]
                
                if self.scaledButton != btn {
                    UIView.animate(withDuration: 0.2, animations: {
                        btn.transform = CGAffineTransform(scaleX: self.expressionPulseSize, y: self.expressionPulseSize)
                    }) { (complete) in
                        if complete {
                            UIView.animate(withDuration: 0.1, animations: {
                                btn.transform = CGAffineTransform(scaleX: self.expressionSelectedSize, y: self.expressionSelectedSize)
                            })
                        }
                    }
                    self.scaledButton = btn
                }
                
            } else {
                if self.scaledButton != nil {
                    UIView.animate(withDuration: 0.1) {
                        self.scaledButton?.transform = CGAffineTransform.identity
                    }
                    self.scaledButton = nil
                } else {
                    self.buttons.forEach { (button) in
                        button.transform = CGAffineTransform.identity
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            
            let touchPoint = touch.location(in: self)
            
            for i in 0..<self.buttonLocations.count {
                if self.buttonLocations[i].contains(touchPoint) {
                    self.delegate?.expressionWasSelected(item: self.expressions[i])
                    break
                }
            }
        }
        self.removeInstincts()
        self.delegate?.overlayViewNotHandlingGestures()
    }
    
    // MARK: UI Calculations
    
    private func calculateRectanlgesCircular(startAngle: Double, centerPoint: CGPoint, instinctCount: Int, spokeAngle: CGFloat, radius: CGFloat, expressionDiameter: CGFloat) {
        for i in 0..<instinctCount {
            let theta = startAngle + (Double(i) * Double(spokeAngle))
            let thetaRadians = theta.toRadians
            let x = Double(centerPoint.x) - Double(radius) * cos(Double(thetaRadians))
            let y = Double(radius) * sin(Double(thetaRadians)) + Double(centerPoint.y)
            
            let rect = CGRect(x: CGFloat(x) - expressionDiameter / 2.0, y: CGFloat(y) - expressionDiameter / 2.0, width: expressionDiameter, height: expressionDiameter)
            
            if self.debugMode == true {
                let view = UIView(frame: rect)
                view.layer.borderWidth = 1.5
                view.layer.borderColor = UIColor.blue.cgColor
                self.addSubview(view)
            }
            
            self.buttonLocations.append(rect)
        }
    }
    
    private func calculateRectanglesHorizontal(startPoint: CGPoint, instinctCount: Int, expressionDiameter: CGFloat) {
        for i in 0..<instinctCount {
            let x = startPoint.x + (expressionDiameter + self.straightSpacing) * CGFloat(i + 1)
            let y = startPoint.y
            let rect = CGRect(x: CGFloat(x) - expressionDiameter / 2.0, y: CGFloat(y) - expressionDiameter / 2.0, width: expressionDiameter, height: expressionDiameter)
            
            if self.debugMode == true {
                let view = UIView(frame: rect)
                view.layer.borderWidth = 1.5
                view.layer.borderColor = UIColor.blue.cgColor
                self.addSubview(view)
            }
            
            self.buttonLocations.append(rect)
        }
    }

    private func calculateRectanglesVertical(startPoint: CGPoint, instinctCount: Int, expressionDiameter: CGFloat) {
        for i in 0..<instinctCount {
            let x = startPoint.x
            let y = startPoint.y - (expressionDiameter + self.straightSpacing) * CGFloat(i + 1)
            let rect = CGRect(x: CGFloat(x), y: CGFloat(y) - expressionDiameter / 2.0, width: expressionDiameter, height: expressionDiameter)
            
            if self.debugMode == true {
                let view = UIView(frame: rect)
                view.layer.borderWidth = 1.5
                view.layer.borderColor = UIColor.blue.cgColor
                self.addSubview(view)
            }
            
            self.buttonLocations.append(rect)
        }
    }
    
    private func presentInstincts() {
        
        var straightStartXPoint: CGFloat = self.straightSpacing
        
        for btn in self.buttons {
            btn.isHidden = false
        }
        
        if case .circular(_,_) = self.overlayType {
            self.frame = CGRect(x: self.frame.origin.x,
                                y: self.frame.origin.y - ((self.expandedDiameter - self.initialSize.height) / 2.0),
                                width: self.expandedDiameter,
                                height: self.expandedDiameter)
        } else if case .straight(let direction, _, _) = self.overlayType, direction == .horizontal {
            self.frame = CGRect(x: self.frame.origin.x,
                                y: self.frame.origin.y - (self.expressionDiameter / 2.0),
                                width: (self.expressionDiameter + self.straightSpacing) * CGFloat(self.expressions.count + 1) + self.straightSpacing,
                                height: self.expressionDiameter * 2.0)
        } else {
            self.frame = CGRect(x: self.frame.origin.x,
                                y: self.frame.maxY - (self.expressionDiameter + self.straightSpacing) * CGFloat(self.expressions.count + 1),
                                width: self.expressionDiameter,
                                height: (self.expressionDiameter + self.straightSpacing) * CGFloat(self.expressions.count + 1))
        }
        
        var straightStartYPoint: CGFloat = self.bounds.maxY
        
        if case .circular(_,_) = self.overlayType {
            let tempRadius = (self.expandedDiameter / 2.0) - (self.expressionDiameter / 2.0)
            
            self.calculateRectanlgesCircular(startAngle: 0.0,
                                             centerPoint: CGPoint(x:self.expressionDiameter / 2.0 + tempRadius, y:self.expandedDiameter / 2.0),
                                             instinctCount: self.expressions.count,
                                             spokeAngle: CGFloat(self.expressionAngle),
                                             radius: tempRadius,
                                             expressionDiameter: self.expressionDiameter)
        } else if case .straight(let direction, _, _) = self.overlayType, direction == .horizontal {
            self.calculateRectanglesHorizontal(startPoint: CGPoint(x: self.straightSpacing, y: self.bounds.midY),
                                             instinctCount: self.expressions.count,
                                             expressionDiameter: self.expressionDiameter)
        } else {
            self.calculateRectanglesVertical(startPoint: CGPoint(x: self.bounds.minX, y: self.bounds.maxY),
                                             instinctCount: self.expressions.count,
                                             expressionDiameter: self.expressionDiameter)
        }
        
        let initialRadius: CGFloat = self.expandedDiameter / 2.0
        
        var requiredPath: UIBezierPath = UIBezierPath()
        
        if case .straight(let direction,_,_) = self.overlayType, direction == .horizontal {
            requiredPath.move(to: CGPoint(x: straightStartXPoint, y: self.bounds.midY))
        } else if case .straight(let direction,_,_) = self.overlayType, direction == .vertical {
            requiredPath.move(to: CGPoint(x: self.bounds.midX, y: straightStartYPoint))
        }
        
        var endAngle = 180.0
        
        let animationSpeed: Float
        let animationDuration: Double
        
        switch self.overlayType {
            case .circular(let speed, let duration):
                animationSpeed = speed
                animationDuration = duration
            case .straight(_, let speed, let duration):
                animationSpeed = speed
                animationDuration = duration
        }
        
        for i in 0..<self.buttons.count {
            
            if case .circular(_,_) = self.overlayType {
                requiredPath = UIBezierPath()
                requiredPath.addArc(withCenter: CGPoint(x:initialRadius,
                                                        y:self.frame.size.height / 2.0),
                                    radius: initialRadius - (self.expressionDiameter / 2.0),
                                    startAngle: CGFloat(-180.0.toRadians),
                                    endAngle: CGFloat(endAngle.toRadians),
                                    clockwise: true)
                
                endAngle -= self.expressionAngle
            } else if case .straight(let direction,_,_) = self.overlayType, direction == .horizontal {
                straightStartXPoint += self.expressionDiameter + self.straightSpacing
                requiredPath.addLine(to: CGPoint(x:straightStartXPoint, y:self.bounds.midY))
            } else {
                straightStartYPoint -= self.expressionDiameter + self.straightSpacing
                requiredPath.addLine(to: CGPoint(x:self.bounds.midX, y:straightStartYPoint))
            }
            
            let keyFrameAnimation = CAKeyframeAnimation(keyPath: "position")
            keyFrameAnimation.path = requiredPath.cgPath
            keyFrameAnimation.calculationMode = .cubic
            keyFrameAnimation.duration = animationDuration
            keyFrameAnimation.speed = animationSpeed
            keyFrameAnimation.isRemovedOnCompletion = false
            keyFrameAnimation.fillMode = .forwards
            
            self.buttons[i].layer.add(keyFrameAnimation, forKey: "curve-forwards")
        }
    }
    
    private func removeInstincts() {
        
        let initialRadius: CGFloat = self.frame.height / 2.0
        var startAngle = 180.0
        
        var requiredPath = UIBezierPath()
        
        let animationSpeed: Float
        let animationDuration: Double
        
        switch self.overlayType {
        case .circular(let speed, let duration):
            animationSpeed = speed
            animationDuration = duration
        case .straight(_, let speed, let duration):
            animationSpeed = speed
            animationDuration = duration
        }
        
        for i in 0..<self.buttons.count {
            
            if case .circular(_,_) = self.overlayType {
                requiredPath = UIBezierPath()
                requiredPath.addArc(withCenter: CGPoint(x:self.expressionDiameter / 2.0 + initialRadius,
                                                        y:self.frame.size.height / 2.0),
                                    radius: initialRadius,
                                    startAngle: CGFloat(startAngle.toRadians),
                                    endAngle: CGFloat(-180.0.toRadians),
                                    clockwise: false)
                startAngle -= self.expressionAngle
            } else if case .straight(let direction,_,_) = self.overlayType, direction == .horizontal {
                requiredPath = UIBezierPath()
                requiredPath.move(to: CGPoint(x: (self.expressionDiameter + self.straightSpacing) * CGFloat(i + 1), y:self.bounds.midY))
                requiredPath.addLine(to: CGPoint(x: 10.0, y:self.bounds.midY))
            } else {
                requiredPath = UIBezierPath()
                requiredPath.move(to: CGPoint(x: self.bounds.midX, y:self.bounds.maxY - (self.expressionDiameter + self.straightSpacing) * CGFloat(i + 1)))
                requiredPath.addLine(to: CGPoint(x: self.bounds.midX, y:self.bounds.maxY))
            }
            
            let keyFrameAnimation = CAKeyframeAnimation(keyPath: "position")
            keyFrameAnimation.path = requiredPath.cgPath
            keyFrameAnimation.duration = animationDuration
            keyFrameAnimation.speed = animationSpeed
            keyFrameAnimation.isRemovedOnCompletion = true
            keyFrameAnimation.fillMode = .backwards
            
            self.buttons[i].layer.add(keyFrameAnimation, forKey: "curve-backwards")
            
            UIView.animate(withDuration: 0.2, delay: 0.2, animations: {
                self.buttons[i].alpha = 0.0
            }) { (completed) in
                self.buttons[i].isHidden = true
                self.buttons[i].alpha = 1.0
                self.frame = CGRect(origin: self.initialOrigin, size: self.initialSize)
            }
        }
    }
}

