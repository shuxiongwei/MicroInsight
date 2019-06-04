//
//  MICustomAlertView.h
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/18.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MICustomAlertView : UIView

/**
 显示提示视图
 
 @param frame 视图范围
 @param title 提示标题
 @param message 提示信息
 @param leftAction 左边按钮响应
 @param rightAction 右边按钮响应
 */
+ (void)showAlertViewWithFrame:(CGRect)frame
                    alertTitle:(NSString *)title
                  alertMessage:(NSString *)message
                    leftAction:(void(^)(void))leftAction
                   rightAction:(void(^)(void))rightAction;

@end

NS_ASSUME_NONNULL_END
