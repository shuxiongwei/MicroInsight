//
//  Constant.swift
//  QSPS
//
//  Created by 舒雄威 on 2018/8/15.
//  Copyright © 2018年 舒雄威. All rights reserved.
//

import Foundation

//MARK:屏幕尺寸
let ScreenBounds = UIScreen.main.bounds
let ScreenWidth = ScreenBounds.size.width
let ScreenHeight = ScreenBounds.size.height
let MaximumLeftDrawerWidth = ScreenWidth - ScreenWidth / 375.0 * 65.0

//横屏宽高
let LandscapeScreenWidth = (ScreenWidth > ScreenHeight ? ScreenWidth : ScreenHeight)
let LandscapeScreenHeight = (ScreenHeight < ScreenWidth ? ScreenHeight : ScreenWidth)
//竖屏宽高
let PortraitScreenWidth = (ScreenWidth > ScreenHeight ? ScreenHeight : ScreenWidth)
let PortraitScreenHeight = (ScreenHeight < ScreenWidth ? ScreenWidth : ScreenHeight)

//MARK:颜色
func MIRgbaColor(rgbValue: Int32, alpha: Float) -> UIColor {
    return UIColor(red: CGFloat(((Float)((rgbValue & 0xFF0000) >> 16)) / 255.0), green: CGFloat(((Float)((rgbValue & 0xFF00) >> 8)) / 255.0), blue: CGFloat(((Float)(rgbValue & 0xFF)) / 255.0), alpha: CGFloat(alpha))
}

//MARK:导航栏高度
func MINavigationBarHeight(vc: UIViewController) -> CGFloat {
    return (vc.navigationController?.navigationBar.bounds.size.height)!
}

//MARK:状态栏高度
func MIStatusBarHeight() -> CGFloat {
    return UIApplication.shared.statusBarFrame.size.height
}

//MARK:标签栏高度
let MITabBarHeight: CGFloat = (MIStatusBarHeight() > 20 ? 83 : 49)

//MARK:获取根导航控制器
func MIGetNavigationViewController() -> UINavigationController {
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let navVC = appDelegate.window.rootViewController as! UINavigationController
    return navVC
}

enum MIHandleType {
    case Tips        //小贴
    case Glue        //移胶
    case Measure     //测距
}
