//
//  MIBaseViewController.h
//  MicroInsight
//
//  Created by 舒雄威 on 2018/8/22.
//  Copyright © 2018年 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MIBaseViewController : UIViewController

/**
 配置导航栏左边视图

 @param text 标题
 */
- (void)configLeftBarButtonItem:(NSString *)text;

/**
 退到上级页面
 */
- (void)popToForwardViewController;

/**
 配置导航栏右边视图
 
 @param type 按钮类型
 @param frame 范围
 @param title 标题
 @param norColor 正常状态标题颜色
 @param hgtColor 高亮状态标题颜色
 @param selColor 选中状态标题颜色
 @param font 标题文字大小
 @param norImage 正常状态图片
 @param highImage 高亮状态图片
 @param selImage 选中状态图片
 @param target 目标
 @param action 事件
 */
- (void)configRightBarButtonItemWithType:(UIButtonType)type
                                   frame:(CGRect)frame
                             normalTitle:(NSString *)title
                        normalTitleColor:(UIColor *)norColor
                   highlightedTitleColor:(UIColor *)hgtColor
                           selectedColor:(UIColor *)selColor
                               titleFont:(CGFloat)font
                             normalImage:(UIImage *)norImage
                        highlightedImage:(UIImage *)highImage
                           selectedImage:(UIImage *)selImage
                     touchUpInSideTarget:(id)target
                                  action:(SEL)action;

/**
 配置导航栏右边视图
 
 @param type 按钮类型
 @param frame 范围
 @param title 标题
 @param norColor 正常状态标题颜色
 @param hgtColor 高亮状态标题颜色
 @param selColor 选中状态标题颜色
 @param font 标题文字大小
 @param norImage 正常状态图片
 @param highImage 高亮状态图片
 @param selImage 选中状态图片
 @param bgColor 背景颜色
 @param target 目标
 @param action 事件
 */
- (void)configRightBarButtonItemWithType:(UIButtonType)type
                                   frame:(CGRect)frame
                             normalTitle:(NSString *)title
                        normalTitleColor:(UIColor *)norColor
                   highlightedTitleColor:(UIColor *)hgtColor
                           selectedColor:(UIColor *)selColor
                               titleFont:(CGFloat)font
                             normalImage:(UIImage *)norImage
                        highlightedImage:(UIImage *)highImage
                           selectedImage:(UIImage *)selImage
                         backgroundColor:(UIColor *)bgColor
                     touchUpInSideTarget:(id)target
                                  action:(SEL)action;

/**
 释放对象
 */
- (void)releaseObject;

- (void)configBackBtn;
- (void)setStatusBarBackgroundColor:(UIColor *)color;

@end
