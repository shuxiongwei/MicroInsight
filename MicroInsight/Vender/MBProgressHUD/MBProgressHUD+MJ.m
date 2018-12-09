
//
//  MBProgressHUD+LJ.h
//  lntuApp
//
//  Created by JieLee on 15-01-05.
//  Copyright (c) 2015年 PUPBOSS. All rights reserved.
//

#import "MBProgressHUD+MJ.h"

@implementation MBProgressHUD (MJ)

#pragma mark 显示信息
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view {
    [MBProgressHUD show:text icon:icon view:view afterDelay:2.0];
}

+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view afterDelay:(float)afterDelay {
    
    if (view == nil) {
        view = [[UIApplication sharedApplication].windows lastObject];
    }
        
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = text;
    
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
    
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 2.0秒之后再消失
    [hud hide:YES afterDelay:afterDelay];
}

#pragma mark 显示错误信息
+ (void)shortShowError:(NSString *)error toView:(UIView *)view {
    [self show:error icon:@"error.png" view:view afterDelay:0.5];
}

+ (void)showError:(NSString *)error toView:(UIView *)view {
    [self show:error icon:@"error.png" view:view];
}

+ (void)showSuccess:(NSString *)success toView:(UIView *)view {
    [self show:success icon:@"success.png" view:view];
}

#pragma mark 显示一些信息
+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view {
    
    if (view == nil) {
        view = [[UIApplication sharedApplication].windows lastObject];
    }
    
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = message;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // YES代表需要蒙版效果
    hud.dimBackground = YES;
    
    return hud;
}

+ (void)showStatus:(NSString *)message {
    UIView *view = [[UIApplication sharedApplication].windows lastObject];
    
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = message;
    hud.labelFont = [UIFont systemFontOfSize:13];
    hud.margin = 15;
    hud.cornerRadius = 5;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // YES代表需要蒙版效果
    hud.dimBackground = YES;
    hud.color = UIColorFromRGBWithAlpha(0x333333, 1);
}

+ (void)showSuccess:(NSString *)success {
    [self showSuccess:success toView:nil];
}

+ (void)showError:(NSString *)error {
    [self showError:error toView:nil];
}

+ (MBProgressHUD *)showMessage:(NSString *)message {
    return [self showMessage:message toView:nil];
}

+ (void)hideHUDForView:(UIView *)view {
    [self hideHUDForView:view animated:YES];
}

+ (void)hideHUD {
    UIView *view = [[UIApplication sharedApplication].windows lastObject];
    [self hideHUDForView:view];
}

@end
