//
//  MyPhotoSheetView.h
//  QZSQ
//
//  Created by yedexiong20 on 2018/9/15.
//  Copyright © 2018年 XMZY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyPhotoSheetView : UIView

/* <#name#> */
@property (copy,nonatomic) void(^SheetActionBlock)(NSString *title);

+(instancetype)shareViewWithTitles:(NSArray *)titles imgs:(NSArray *)imgs title:(NSString *)title;

-(void)showInView:(UIView*)view;

-(void)show;

-(void)dismiss;

@end
