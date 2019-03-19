//
//  MIAlertView.h
//  MicroInsight
//
//  Created by 舒雄威 on 2018/5/25.
//  Copyright © 2018年 QiShon. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, MIAlertType) {
    QSAlertTextField,   //显示文本框
    QSAlertProgress,    //显示进度
    QSAlertMessage,     //显示提示信息
    QSAlertStatus       //显示状态(完成、失败等)
};

@interface MIAlertView : UIView

/**
 显示提示视图

 @param frame 视图范围
 @param bounds 提示框大小
 @param type 提示类型
 @param title 提示标题
 @param message 提示信息
 @param alertInfo 记录提示信息
 @param leftAction 左边按钮响应
 @param rightAction 右边按钮响应
 */
+ (void)showAlertViewWithFrame:(CGRect)frame
                   alertBounds:(CGRect)bounds
                     alertType:(MIAlertType)type
                    alertTitle:(NSString *)title
                  alertMessage:(NSString *)message
                     alertInfo:(id)alertInfo
                    leftAction:(void(^)(id alert))leftAction
                   rightAction:(void(^)(id alert))rightAction;

/**
 初始化
 
 @param frame 视图范围
 @param bounds 提示框大小
 @param type 提示类型
 @param title 提示标题
 @param message 提示信息
 @param alertInfo 记录提示信息
 @param leftAction 左边按钮响应
 @param rightAction 右边按钮响应
 @return 返回值
 */
- (instancetype)initWithFrame:(CGRect)frame
                  alertBounds:(CGRect)bounds
                    alertType:(MIAlertType)type
                   alertTitle:(NSString *)title
                 alertMessage:(NSString *)message
                    alertInfo:(id)alertInfo
                   leftAction:(void(^)(id alert))leftAction
                  rightAction:(void(^)(id alert))rightAction;

/**
 刷新进度

 @param progress 进度
 @param completed 完成回调
 */
- (void)refreshCurrentProgress:(CGFloat)progress completed:(void(^)(NSString *diskName))completed;

@end
