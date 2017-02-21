//
// Created by 姜振华 on 2017/2/20.
// Copyright (c) 2017 naoyashiga. All rights reserved.
//

import Foundation
import UIKit

private func roundByUnit(num: Double, _ unit: inout Double) -> Double {
    let remain = modf(num, &unit)
    if remain > unit / 2.0 {
        return ceilByUnit(num: num, &unit)
    } else {
        return floorByUnit(num: num, &unit)
    }
}

private func ceilByUnit(num: Double, _ unit: inout  Double) -> Double {
    return num - modf(num, &unit) + unit
}

private func floorByUnit(num: Double, _ unit: inout Double) -> Double {
    return num - modf(num, &unit)
}

private func pixel(num: Double) -> Double {
    var unit: Double
    switch Int(UIScreen.main.scale) {
        case 1: unit = 1.0 / 1.0
        case 2: unit = 1.0 / 2.0
        case 3: unit = 1.0 / 3.0
        default: unit = 0.0
    }
    return roundByUnit(num: num, &unit)
}

extension UIView {
    func dj_addCorner(radius r: CGFloat) {
        self.dj_addCorner(radius: r, borderWidth: 1, backgroundColor: UIColor.clear, borderColor: UIColor.black)
    }

    func dj_addCorner(radius r:CGFloat,
                      borderWidth: CGFloat,
                      backgroundColor: UIColor,
                      borderColor: UIColor) {
        let img = dj_drawRectWithRoundedCorner(radius: r,
                                               borderWidth: borderWidth,
                                               backgroundColor: backgroundColor,
                                               borderColor: borderColor)!;
        let imageView = UIImageView(image: img)
        //这种做法无法保证遮罩在最上面
//        self.insertSubview(imageView, at: 0)
        //因为是最后调用，可以放心的addSubView
        self.addSubview(imageView)
    }

    func dj_drawRectWithRoundedCorner(radius r: CGFloat,
                                      borderWidth: CGFloat,
                                      backgroundColor: UIColor,
                                      borderColor: UIColor) -> UIImage? {
        let sizeToFit = CGSize(width: pixel(num: Double(self.bounds.size.width)), height: Double(self.bounds.size.height))
        let halfBorderWidth = CGFloat(borderWidth / 2.0)

        UIGraphicsBeginImageContextWithOptions(sizeToFit, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            context.setLineWidth(borderWidth)
            context.setStrokeColor(borderColor.cgColor)
            context.setFillColor(backgroundColor.cgColor)
            let width = sizeToFit.width, height = sizeToFit.height
            context.move(to: CGPoint.init(x: width - halfBorderWidth, y: r + halfBorderWidth))// 开始坐标右边开始
            context.addArc(tangent1End: CGPoint.init(x: width - halfBorderWidth, y: height - halfBorderWidth), tangent2End: CGPoint.init(x: width - r - halfBorderWidth, y: height - halfBorderWidth), radius: r)// 右下角角度
            context.addArc(tangent1End: CGPoint.init(x:halfBorderWidth, y:height - halfBorderWidth), tangent2End: CGPoint.init(x:halfBorderWidth, y:height - r - halfBorderWidth), radius: r)// 左下角角度
            context.addArc(tangent1End: CGPoint.init(x:halfBorderWidth, y:halfBorderWidth), tangent2End: CGPoint.init(x:width - halfBorderWidth, y:halfBorderWidth), radius: r)// 左上角
            context.addArc(tangent1End: CGPoint.init(x: width - halfBorderWidth, y: halfBorderWidth), tangent2End: CGPoint.init(x:width - halfBorderWidth, y: r + halfBorderWidth), radius: r)// 右上角
            context.drawPath(using: .fillStroke)
        }

        let output = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return output
    }
}

extension UIImageView {
    /**
     / !!!只有当 imageView 不为nil 时，调用此方法才有效果

     :param: radius 圆角半径
     */
    override func dj_addCorner(radius r: CGFloat) {
        // 被注释的是图片添加圆角的 OC 写法
//        self.image = self.image?.imageAddCornerWithRadius(radius, andSize: self.bounds.size)
        self.image = self.image?.dj_drawRectWithRoundedCorner(radius: r, self.bounds.size)
    }
}

extension UIImage {
    func dj_drawRectWithRoundedCorner(radius r: CGFloat, _ sizetoFit: CGSize) -> UIImage? {
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: sizetoFit)

        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            context.addPath(UIBezierPath(roundedRect: rect, byRoundingCorners: UIRectCorner.allCorners, cornerRadii: CGSize.init(width: r, height: r)
            ).cgPath)
            context.clip()
            self.draw(in: rect)
            context.drawPath(using: .fillStroke)
        }
        
        let output = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return output
    }
}
