//
//  MIDemarcateAlertView.h
//  MicroInsight
//
//  Created by 舒雄威 on 2019/4/16.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MIDemarcateAlertView : UIView

/**
 显示提示视图
 
 @param frame 范围
 @param title 提示标题
 @param message 提示信息
 @param leftTitle 左边按钮标题
 @param rightTitle 左边按钮标题
 @param leftAction 左边按钮响应
 @param rightAction 右边按钮响应
 */
+ (void)showAlertViewWithFrame:(CGRect)frame
                    alertTitle:(NSString *)title
                  alertMessage:(NSString *)message
                     leftTitle:(NSString *)leftTitle
                    rightTitle:(NSString *)rightTitle
                    leftAction:(void(^)(BOOL alert))leftAction
                   rightAction:(void(^)(BOOL alert))rightAction;

@end

NS_ASSUME_NONNULL_END
