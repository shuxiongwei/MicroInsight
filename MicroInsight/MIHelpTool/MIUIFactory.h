//
//  MIUIFactory.h
//  MicroInsight
//
//  Created by 舒雄威 on 2017/12/29.
//  Copyright © 2017年 舒雄威. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MIUIFactory : NSObject

/**
 创建自定义Button

 @param type 类型
 @param frame 范围
 @param title 标题
 @param norColor 正常状态标题颜色
 @param hgtColor 高亮状态标题颜色
 @param selColor 选中状态标题颜色
 @param font  标题字体大小
 @param norImage 正常状态显示图片
 @param hgtImage 高亮状态显示图片
 @param selImage 选中状态显示图片
 @param target 事件执行者
 @param action 响应事件
 @return 返回创建好的Button
 */
+ (UIButton *)createButtonWithType:(UIButtonType)type
                             frame:(CGRect)frame
                       normalTitle:(NSString *)title
                  normalTitleColor:(UIColor *)norColor
             highlightedTitleColor:(UIColor *)hgtColor
                     selectedColor:(UIColor *)selColor
                         titleFont:(CGFloat)font
                       normalImage:(UIImage *)norImage
                  highlightedImage:(UIImage *)hgtImage
                     selectedImage:(UIImage *)selImage
               touchUpInSideTarget:(id)target
                            action:(SEL)action;

/**
 创建自定义Button
 
 @param type 类型
 @param frame 范围
 @param title 标题
 @param norColor 正常状态标题颜色
 @param hgtColor 高亮状态标题颜色
 @param selColor 选中状态标题颜色
 @param font  标题字体大小
 @param norImage 正常状态显示图片
 @param hgtImage 高亮状态显示图片
 @param selImage 选中状态显示图片
 @param target 事件执行者
 @param action 响应事件
 @param vercital 垂直布局
 @return 返回创建好的Button
 */
+ (UIButton *)createButtonWithType:(UIButtonType)type
                             frame:(CGRect)frame
                       normalTitle:(NSString *)title
                  normalTitleColor:(UIColor *)norColor
             highlightedTitleColor:(UIColor *)hgtColor
                     selectedColor:(UIColor *)selColor
                         titleFont:(CGFloat)font
                       normalImage:(UIImage *)norImage
                  highlightedImage:(UIImage *)hgtImage
                     selectedImage:(UIImage *)selImage
               touchUpInSideTarget:(id)target
                            action:(SEL)action
                   layoutDirection:(BOOL)vercital;

/**
 创建自定义Label

 @param centerPoint 中心点
 @param bounds 大小
 @param text 文本
 @param font 字体大小
 @param color 字体颜色
 @param alignment 字体对齐方式
 @return 返回创建好的Label
 */
+ (UILabel *)createLabelWithCenter:(CGPoint)centerPoint
                        withBounds:(CGRect)bounds
                          withText:(NSString *)text
                          withFont:(CGFloat)font
                     withTextColor:(UIColor *)color
                 withTextAlignment:(NSTextAlignment)alignment;

/**
 创建自定义Layer

 @param path 路径
 @param strokeColor 边框颜色
 @param fillColor 填充颜色
 @param width 线条宽度
 @return 返回创建好的Layer
 */
+ (CAShapeLayer *)createShapeLayerWithPath:(CGPathRef)path
                               strokeColor:(CGColorRef)strokeColor
                                 fillColor:(CGColorRef)fillColor
                                 lineWidth:(CGFloat)width;

/**
 颜色转图片

 @param color 颜色
 @param rect 尺寸
 @return 返回图片
 */
+ (UIImage *)createImageWithColor:(UIColor *)color rect:(CGRect)rect;

/**
 给view添加阴影和圆角

 @param view 需要操作的view
 @param shadowOpacity 阴影不透明度
 @param shadowColor 阴影颜色
 @param shadowRadius 阴影半径
 @param cornerRadius 圆角
 */
+ (void)addShadowToView:(UIView *)view
            withOpacity:(float)shadowOpacity
            shadowColor:(UIColor *)shadowColor
           shadowRadius:(CGFloat)shadowRadius
        andCornerRadius:(CGFloat)cornerRadius;

/**
 图片模糊
 
 @param image 待模糊的图片
 @return 模糊后的图片
 */
+ (UIImage *)coreBlurImage:(UIImage *)image;

/**
 创建自定义弹窗
 
 @param title 提示文字
 @param titleColor 提示文字颜色
 @param titleFont 提示文字大小
 @param message 消息文字
 @param msgColor 消息文字颜色
 @param msgFont 消息文字大小
 @param style 弹窗样式
 @param leftTitle 左边按钮标题
 @param leftStyle 左边按钮样式
 @param rightTitle 右边按钮标题
 @param rightStyle 右边按钮样式
 @param actionTitleColor 按钮标题颜色
 @param select 选择回调
 @return 返回创建好的弹窗
 */
+ (UIAlertController *)createAlertControllerWithTitle:(NSString *)title
                                           titleColor:(UIColor *)titleColor
                                            titleFont:(CGFloat)titleFont
                                              message:(NSString *)message
                                         messageColor:(UIColor *)msgColor
                                          messageFont:(CGFloat)msgFont
                                           alertStyle:(UIAlertControllerStyle)style
                                      actionLeftTitle:(NSString *)leftTitle
                                      actionLeftStyle:(UIAlertActionStyle)leftStyle
                                     actionRightTitle:(NSString *)rightTitle
                                     actionRightStyle:(UIAlertActionStyle)rightStyle
                                     actionTitleColor:(UIColor *)actionTitleColor
                                         selectAction:(void(^)(void))select;

@end
