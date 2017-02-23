//
//  GradientSwitch.swift
//  DribbbleReader
//
//  Created by 姜振华 on 2017/2/22.
//  Copyright © 2017年 naoyashiga. All rights reserved.
//

import UIKit
import QuartzCore

fileprivate let kTickToDotAnimationKey = "kTickToDotAnimationKey"
fileprivate let kDotToTickAnimationKey = "kDotToTickAnimationKey"
fileprivate let kCrossToDotAnimationKey = "kCrossToDotAnimationKey"
fileprivate let kDotToCrossAnimationKey = "kDotToCrossAnimationKey"

class SwitchAnimationManager: NSObject {
    
    var rect:CGRect
    
    init(rect:CGRect) {
        self.rect = rect
        super.init()
    }
    
    /// 点 -> 勾
    func dotToTickAnimationFromValues(values:[Any]) -> CAAnimationGroup {
        let lineAnimation:CAKeyframeAnimation = self.lineAnimationWithKeyTimes(keyTimes: [NSNumber.init(value: 0),NSNumber.init(value: 0.3)], beginTime: 0, values: values)
        let scaleAnimation:CABasicAnimation = self.transformAnimation()
        scaleAnimation.duration = 0.1
        scaleAnimation.beginTime = 0.2
        
        let lineGroup:CAAnimationGroup = CAAnimationGroup()
        lineGroup.animations = [lineAnimation, scaleAnimation]
        lineGroup.duration = 0.5
        lineGroup.repeatCount = 1
        lineGroup.isRemovedOnCompletion = false
        lineGroup.fillMode = kCAFillModeForwards
        lineGroup.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        return lineGroup
    }
    
    /// 勾 -> 点
    func tickToDotAnimationFromValues(values:[Any]) -> CAAnimationGroup {
        let scaleAnimation = self.transformAnimation()
        scaleAnimation.duration = 0.05
        scaleAnimation.beginTime = 0
        
        let lineAnimation = self.lineAnimationWithKeyTimes(keyTimes: [NSNumber.init(value: 0.1), NSNumber.init(value: 0.4)], beginTime: 0, values: values)
        
        let lineGroup = CAAnimationGroup()
        lineGroup.animations = [scaleAnimation, lineAnimation]
        lineGroup.duration = 0.5
        lineGroup.repeatCount = 1
        lineGroup.isRemovedOnCompletion = false
        lineGroup.fillMode = kCAFillModeForwards
        lineGroup.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        return lineGroup
    }
    
    ///  点 -> 叉
    func dotToCrossAnimationFromValues(values:[Any], keyTimes:[NSNumber], duration:TimeInterval) -> CAAnimationGroup {
        let lineAnimation:CAKeyframeAnimation = self.lineAnimationWithKeyTimes(keyTimes: keyTimes, beginTime: 0, values: values)
        lineAnimation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear)
        let scaleAnimation:CABasicAnimation = self.transformAnimation()
        
        let beginTime:TimeInterval = (keyTimes.last?.doubleValue)!
        scaleAnimation.beginTime = beginTime - 0.15
        scaleAnimation.duration = 0.1
        scaleAnimation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear)
        
        let lineGroup: CAAnimationGroup = CAAnimationGroup()
        lineGroup.animations = [lineAnimation, scaleAnimation]
        lineGroup.duration = duration
        lineGroup.repeatCount = 1
        lineGroup.isRemovedOnCompletion = false
        lineGroup.fillMode = kCAFillModeForwards
        
        return lineGroup
    }
    
    ///  叉 -> 点
    func crossToDotAnimationFromValues(values:[Any], keyTimes:[NSNumber], duration:TimeInterval) -> CAAnimationGroup {
        let lineAnimation = self.lineAnimationWithKeyTimes(keyTimes: keyTimes, beginTime: 0, values: values)
        lineAnimation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear)
        
        let scaleAnimation:CABasicAnimation = self.transformAnimation()
        scaleAnimation.beginTime = 0
        scaleAnimation.duration = 0.1
        
        let lineGroup:CAAnimationGroup = CAAnimationGroup()
        lineGroup.animations = [scaleAnimation, lineAnimation]
        lineGroup.duration = duration
        lineGroup.repeatCount = 1
        lineGroup.isRemovedOnCompletion = false
        lineGroup.fillMode = kCAFillModeForwards
        
        return lineGroup
    }
    
    private func lineAnimationWithKeyTimes(keyTimes:[NSNumber], beginTime:TimeInterval, values:[Any]) -> CAKeyframeAnimation {
        let animation:CAKeyframeAnimation = CAKeyframeAnimation.init(keyPath: "path")
        animation.values = values
        animation.keyTimes = keyTimes
        animation.beginTime = beginTime
        return animation
    }
    
    private func transformAnimation() -> CABasicAnimation {
        let animation:CABasicAnimation = CABasicAnimation.init(keyPath: "transform")
        var tr:CATransform3D = CATransform3DIdentity
        tr = CATransform3DTranslate(tr, rect.width/2, rect.height/2, 0)
        tr = CATransform3DScale(tr, 1.2, 1.2, 1)
        tr = CATransform3DTranslate(tr, -rect.width/2, -rect.height/2, 0)
        animation.toValue = NSValue(caTransform3D: tr)
        animation.autoreverses = true
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        return animation
    }
}

//Mark: Switch上的按钮
class KnobView: UIView {
    
    var tickShapeLayer: CAShapeLayer { return KnobView.defaultShapeLayer() };
    var crossShapeLayer1: CAShapeLayer { return KnobView.defaultShapeLayer() };
    var crossShapeLayer2: CAShapeLayer { return KnobView.defaultShapeLayer() };
    
    var dotPath: UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint.init(x: self.frame.width/2, y: self.frame.width/2))
        path.addLine(to: CGPoint.init(x: self.frame.size.width/2, y: self.frame.size.width/2))
        return path
    };
    
    var tickPath: UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint.init(x: self.frame.width/8 * 3, y: self.frame.width/2))
        path.addLine(to: CGPoint.init(x: self.frame.width/2, y: self.frame.width/8*5))
        path.addLine(to: CGPoint.init(x: self.frame.size.width/8*6, y: self.frame.size.width/8*3))
        return path
    };
    var crossPath1: UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint.init(x: self.frame.width/9*6, y: self.frame.size.width/9*3))
        path.addLine(to: CGPoint.init(x: self.frame.width/9*3, y: self.frame.size.width/9*6))
        return path;
    };
    var crossPath2: UIBezierPath {
        let path = UIBezierPath()
        
        return path
    };
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    private static func defaultShapeLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.lineCap = kCALineCapRound
        layer.lineJoin = kCALineJoinRound
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = 2
        return layer
    }
    
    func initialize() {
        backgroundColor = UIColor.clear
        tickShapeLayer.path = tickPath.cgPath
        crossShapeLayer1.path = crossPath1.cgPath
        crossShapeLayer2.path = crossPath2.cgPath
        crossShapeLayer1.isHidden = true
        crossShapeLayer2.isHidden = true
        
        layer.addSublayer(tickShapeLayer)
        layer.addSublayer(crossShapeLayer1)
        layer.addSublayer(crossShapeLayer2)
    }
}

class GradientSwitch: UIView, CAAnimationDelegate {
    
    @IBInspectable var on:Bool = false {
        didSet {
            let w = self.frame.height - knobMargin * 2
            let h = self.frame.height
            
            knobShapeLayerHidden(isOn:on)
            if on {
                knob.frame = CGRect.init(x: 0, y: 0, width: w, height: w)
                gradientView.frame = CGRect.init(x: 0, y: 0, width: self.frame.width*3, height: h)
            } else {
                knob.frame = CGRect.init(x: self.frame.width-knobMargin-w, y: knobMargin, width: w, height: w)
                gradientView.frame = CGRect.init(x: -self.frame.width*2, y: 0, width: self.frame.width*3, height: h)
            }
        }
    }
    var action:((Bool) -> Void)?
    
    private var borderWidth: CGFloat {
        return self.frame.size.height / 7
    }
    private var borderShape: CAShapeLayer {
        let borderShape = CAShapeLayer()
        let borderPath = UIBezierPath.init(roundedRect: CGRect.init(x: 0, y: 0, width: self.frame.width, height: self.frame.height),
                                           cornerRadius: self.frame.height / 2)
        borderShape.path = borderPath.cgPath
        borderShape.fillColor = UIColor.clear.cgColor
        borderShape.strokeColor = UIColor.borderColor().cgColor
        borderShape.lineWidth = borderWidth
        
        return borderShape
    }
    private var gradientView: UIView {
        let offColor1 = UIColor.hexStr("EF9C29", alpha: 1).cgColor
        let offColor2 = UIColor.hexStr("E76B39", alpha: 1).cgColor
        let onColor1 = UIColor.hexStr("08DED6", alpha: 1).cgColor
        let onColor2 = UIColor.hexStr("18DEB9", alpha: 1).cgColor
        
        let view:UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.width*3, height: self.frame.height))
        view.backgroundColor = UIColor.clear
        let gradientLayer = self.setupGradientLayerWithColors(colors: [offColor1,offColor2, onColor1, onColor2],
                                                              width: self.frame.width * 3)
        view.layer.addSublayer(gradientLayer)
        return view
    }
    
    private var knobMargin: CGFloat {
        return self.frame.height / 12
    }
    private var knob:KnobView {
        let w = frame.height - knobMargin * 2
        return KnobView.init(frame: CGRect.init(x:knobMargin,y:knobMargin,width:w,height:w))
    }
    private var manager:SwitchAnimationManager {
        return SwitchAnimationManager.init(rect: knob.frame)
    }
    
    private var isAnimating:Bool = false
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialize() {
        layer.masksToBounds = true
        layer.cornerRadius = frame.height / 2
        backgroundColor = UIColor.clear
        on = true
        self.addSubview(gradientView)
        layer.addSublayer(borderShape)
        self.addSubview(knob)
    }
    
    func setOn(on:Bool, animated:Bool) {
        guard self.on == on else {
            if animated {
                if on {
                    onAnimation()
                } else {
                    offAnimation()
                }
            } else {
                self.on = on
            }
            return
        }
    }
    
    private func setupGradientLayerWithColors(colors:[CGColor], width:CGFloat) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.colors = colors
        layer.locations = [NSNumber.init(value: 0.0),NSNumber.init(value: 0.33),NSNumber.init(value: 0.63),NSNumber.init(value: 1)]
        layer.startPoint = CGPoint.init()
        layer.endPoint = CGPoint.init(x: 1, y: 0)
        layer.frame = CGRect.init(x: 0, y: 0, width: width, height: self.frame.height)
        return layer
    }
    
    private func knobShapeLayerHidden(isOn:Bool) {
        knob.tickShapeLayer.isHidden = !isOn
        knob.crossShapeLayer1.isHidden = isOn
        knob.crossShapeLayer2.isHidden = isOn
    }
    
    //MARK: Animations
    private func offAnimation() {
        isAnimating = true
        knobShapeLayerHidden(isOn: true)
        
        let w = frame.height - knobMargin * 2
        
        let tickAnimationGroup = manager.tickToDotAnimationFromValues(values: [knob.tickPath.cgPath, knob.dotPath.cgPath])
        let crossAnimationGroup1 = manager.dotToCrossAnimationFromValues(values: [knob.dotPath.cgPath, knob.crossPath1.cgPath],
                                                                         keyTimes: [NSNumber.init(value: 0.05),NSNumber.init(value: 0.35)],
                                                                         duration: 0.55)
        let crossAnimationGroup2 = manager.dotToCrossAnimationFromValues(values: [knob.dotPath.cgPath,knob.crossPath2.cgPath],
                                                                         keyTimes: [NSNumber.init(value: 0),NSNumber.init(value: 0.3)],
                                                                         duration: 0.5)
        
        crossAnimationGroup2.delegate = self
        knob.tickShapeLayer.add(tickAnimationGroup, forKey: kTickToDotAnimationKey)
        UIView.animateKeyframes(withDuration: 0.5, delay: 0.1, options: .calculationModePaced, animations: { 
            self.knob.frame = CGRect.init(x: self.frame.width - self.knobMargin - w, y: self.knobMargin, width: w, height: w)
            self.gradientView.frame = CGRect.init(x: -self.frame.width*2, y: 0, width: self.frame.width*3, height: self.frame.height)
        }) { (finished:Bool) in
            self.knobShapeLayerHidden(isOn: false)
            self.knob.crossShapeLayer1.add(crossAnimationGroup1, forKey: kDotToCrossAnimationKey)
            self.knob.crossShapeLayer2.add(crossAnimationGroup2, forKey: kDotToCrossAnimationKey)
        }
    }
    
    private func onAnimation() {
        isAnimating = true
        knobShapeLayerHidden(isOn: true)
        
        let w = frame.height - knobMargin * 2
        
        let tickAnimationGroup = manager.dotToTickAnimationFromValues(values: [knob.dotPath.cgPath, knob.tickPath.cgPath])
        let crossAnimationGroup1 = manager.crossToDotAnimationFromValues(values: [knob.crossPath1.cgPath, knob.dotPath.cgPath],
                                                                         keyTimes: [NSNumber.init(value: 0),NSNumber.init(value: 0.3)],
                                                                         duration: 0.5)
        let crossAnimationGroup2 = manager.crossToDotAnimationFromValues(values: [knob.crossPath2.cgPath, knob.dotPath.cgPath],
                                                                         keyTimes: [NSNumber.init(value: 0.05),NSNumber.init(value: 0.35)],
                                                                         duration: 0.55)
        
        knob.crossShapeLayer1.add(crossAnimationGroup1, forKey: kCrossToDotAnimationKey)
        knob.crossShapeLayer2.add(crossAnimationGroup2, forKey: kCrossToDotAnimationKey)
        
        UIView.animateKeyframes(withDuration: 0.5, delay: 0.1, options: .calculationModePaced, animations: {
            self.knob.frame = CGRect.init(x: self.knobMargin, y: self.knobMargin, width: w, height: w)
            self.gradientView.frame = CGRect.init(x: 0, y: 0, width: self.frame.width*3, height: self.frame.height)
        }) { (finished:Bool) in
            self.knobShapeLayerHidden(isOn: true)
            self.knob.tickShapeLayer.add(tickAnimationGroup, forKey: kDotToTickAnimationKey)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if !isAnimating {
            if self.on {
                offAnimation()
            } else {
                onAnimation()
            }
        }
    }
    
    //MARK:CAAnimationDelegate
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            if anim == knob.crossShapeLayer2.animation(forKey: kDotToCrossAnimationKey) {
                isAnimating = false
                on = false
            } else if anim == knob.tickShapeLayer.animation(forKey: kDotToTickAnimationKey) {
                isAnimating = false
                on = true
            }
            if action != nil {
                action!(on)
            }
        }
    }
}
