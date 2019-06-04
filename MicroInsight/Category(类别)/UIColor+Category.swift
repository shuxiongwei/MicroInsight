//
//  UIColor+Category.swift
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/13.
//  Copyright © 2019 舒雄威. All rights reserved.
//

import Foundation

extension UIColor {
    
    //设置从左到右渐变的颜色
    public class func setGradualLeftToRightColor(view: UIView, fromColor: UIColor, toCololr: UIColor, loactions: [NSNumber]) -> CAGradientLayer {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        //创建渐变色数组，需要转换为CGColor颜色
        gradientLayer.colors = [fromColor.cgColor,toCololr.cgColor]
        //设置渐变颜色方向，左上点为(0,0), 右下点为(1,1)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint =  CGPoint(x: 1, y: 1)
        //设置颜色变化点，取值范围 0.0~1.0
        gradientLayer.locations = loactions
        return gradientLayer
    }
    
    public class func convertToImage(view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        var image = UIImage()
        if let context = UIGraphicsGetCurrentContext(){
            view.layer.render(in: context)
            image = UIGraphicsGetImageFromCurrentImageContext()!
        }
        UIGraphicsEndImageContext()
        return image
    }
}
