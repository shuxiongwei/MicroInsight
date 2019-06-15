//
//  UILabel+YBAttributeTextTapAction.h
//
//  Created by LYB on 16/7/1.
//  Copyright © 2016年 LYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YBAttributeTapActionDelegate <NSObject>
@optional
/**
 *  YBAttributeTapActionDelegate
 *
 *  @param string  点击的字符串
 *  @param range   点击的字符串range
 *  @param index 点击的字符在数组中的index
 */
- (void)yb_attributeTapReturnString:(NSString *)string
                              range:(NSRange)range
                              index:(NSInteger)index;
@end

@interface YBAttributeModel : NSObject

@property (nonatomic, copy) NSString *str;

@property (nonatomic, assign) NSRange range;

@end





@interface UILabel (YBAttributeTextTapAction)

/**
 *  是否打开点击效果，默认是打开
 */
@property (nonatomic, assign) BOOL enabledTapEffect;

/**
 *  给文本添加点击事件Block回调
 *
 *  @param strings  需要添加的字符串数组
 *  @param tapClick 点击事件回调
 */
- (void)yb_addAttributeTapActionWithStrings:(NSArray <NSString *> *)strings
                                 tapClicked:(void (^) (NSString *string , NSRange range , NSInteger index))tapClick;

/**
 *  给文本添加点击事件delegate回调
 *
 *  @param strings  需要添加的字符串数组
 *  @param delegate delegate
 */
- (void)yb_addAttributeTapActionWithStrings:(NSArray <NSString *> *)strings
                                   delegate:(id <YBAttributeTapActionDelegate> )delegate;

/**
 创建UILable

 @param frame 范围
 @param text 文本
 @param font 字号
 @param color 字体颜色
 @param alignment 文本对齐方式
 @param bgColor 背景颜色
 @return 返回值
 */
+ (UILabel *)createLabelWithFrame:(CGRect)frame
                             text:(NSString *)text
                             font:(CGFloat)font
                        textColor:(UIColor *)color
                    textAlignment:(NSTextAlignment)alignment
                  backgroundColor:(UIColor *)bgColor;

/**
 设置lable的文本内容

 @param lastText 显示在最后的文字内容
 @param width 内容宽度
 @param contentText 内容
 */
- (void)setLineBreakByTruncatingLastLine:(NSString *)lastText
                            contentWidth:(CGFloat)width
                             contentText:(NSString *)contentText;

@end

