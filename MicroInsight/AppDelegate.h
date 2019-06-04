//
//  AppDelegate.h
//  MicroInsight
//
//  Created by 舒雄威 on 2018/7/10.
//  Copyright © 2018年 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMHTabBarController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) MMDrawerController *drawerController;

@end

