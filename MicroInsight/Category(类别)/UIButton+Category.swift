//
//  UIButton+Category.swift
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/14.
//  Copyright © 2019 舒雄威. All rights reserved.
//

import Foundation

extension UIButton {
    
    @objc public func setButtonCustomBackgroudImage(btn: UIButton, fromColor: UIColor, toColor: UIColor) {
        
        let layer = UIColor.setGradualLeftToRightColor(view: btn, fromColor: fromColor, toCololr: toColor, loactions: [0.0, 1.0])
        let btnBg = UIView(frame: CGRect(x: 0, y: 0, width: btn.bounds.width, height: btn.bounds.height))
        btnBg.layer.addSublayer(layer)
        btn.setBackgroundImage(UIColor.convertToImage(view: btnBg), for: .normal)
    }
    
}
