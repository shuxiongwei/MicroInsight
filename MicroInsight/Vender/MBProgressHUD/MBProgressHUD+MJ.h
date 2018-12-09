//
//  MBProgressHUD+MJ.h
//  NewHuDongFilm
//
//  Created by leon on 16/3/10.
//  Copyright © 2016年 leon. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (MJ)

+ (void)showSuccess:(NSString *)success toView:(UIView *)view;
+ (void)showError:(NSString *)error toView:(UIView *)view;
+ (void)shortShowError:(NSString *)error toView:(UIView *)view;

+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view;

+ (void)showSuccess:(NSString *)success;
+ (void)showError:(NSString *)error;
+ (MBProgressHUD *)showMessage:(NSString *)message;

+ (void)hideHUDForView:(UIView *)view;
+ (void)showStatus:(NSString *)message;
+ (void)hideHUD;

@end
