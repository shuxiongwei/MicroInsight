//
//  MIDemarcateAlertView.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/4/16.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIDemarcateAlertView.h"
#import "Masonry.h"

@interface MIDemarcateAlertView ()

@property (nonatomic, copy) void (^leftAction)(BOOL);
@property (nonatomic, copy) void (^rightAction)(BOOL);
@property (nonatomic, strong) UIView *alertView;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *leftTitle;
@property (nonatomic, copy) NSString *rightTitle;

@end


@implementation MIDemarcateAlertView

+ (void)showAlertViewWithFrame:(CGRect)frame
                    alertTitle:(NSString *)title
                  alertMessage:(NSString *)message
                     leftTitle:(NSString *)leftTitle
                    rightTitle:(NSString *)rightTitle
                    leftAction:(void(^)(BOOL alert))leftAction
                   rightAction:(void(^)(BOOL alert))rightAction {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //先移除之前的提示
        UIView *v = [UIApplication sharedApplication].keyWindow.subviews.lastObject;
        if ([v isKindOfClass:[MIDemarcateAlertView class]]) {
            [v removeFromSuperview];
        }
        
        MIDemarcateAlertView *alertView = [[MIDemarcateAlertView alloc] initWithFrame:frame alertTitle:title alertMessage:message leftTitle:leftTitle rightTitle:rightTitle leftAction:leftAction rightAction:rightAction];
        [[UIApplication sharedApplication].keyWindow addSubview:alertView];
    });
}

- (instancetype)initWithFrame:(CGRect)frame
                   alertTitle:(NSString *)title
                 alertMessage:(NSString *)message
                    leftTitle:(NSString *)leftTitle
                   rightTitle:(NSString *)rightTitle
                   leftAction:(void(^)(BOOL alert))leftAction
                  rightAction:(void(^)(BOOL alert))rightAction {
    
    if (self = [super initWithFrame:frame]) {
        _title = title;
        _message = message;
        _leftTitle = leftTitle;
        _rightTitle = rightTitle;
        _leftAction = leftAction;
        _rightAction = rightAction;
        
        [self configAlertUI];
    }
    
    return self;
}

- (void)configAlertUI {
    self.backgroundColor = UIColorFromRGBWithAlpha(0x000000, 0.6);
    
    //提示框
    _alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width / 1.8, self.width / 1.8 * 1.1)];
    _alertView.center = self.center;
    _alertView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_alertView];
    [MIUIFactory addShadowToView:_alertView withOpacity:1 shadowColor:UIColorFromRGBWithAlpha(0x000000, 0.12) shadowRadius:23 andCornerRadius:5];

    //标题
    UILabel *titleLab = [MIUIFactory createLabelWithCenter:CGPointZero withBounds:CGRectZero withText:_title withFont:18 withTextColor:UIColorFromRGBWithAlpha(0x00102C, 1) withTextAlignment:NSTextAlignmentLeft];
    [_alertView addSubview:titleLab];
    WSWeak(weakSelf);
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.alertView.mas_left).offset(30);
        make.right.equalTo(weakSelf.alertView.mas_right).offset(-30);
        make.top.equalTo(weakSelf.alertView.mas_top).offset(35);
    }];
    
    //右边按钮
    UIButton *rightBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectZero normalTitle:_rightTitle normalTitleColor:UIColorFromRGBWithAlpha(0x55BE50, 1) highlightedTitleColor:nil selectedColor:nil titleFont:15 normalImage:nil highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(clickRightBtn:)];
    [_alertView addSubview:rightBtn];
    [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.alertView.mas_right).offset(-20);
        make.bottom.equalTo(weakSelf.alertView.mas_bottom).offset(-20);
        make.width.mas_equalTo(64);
        make.height.mas_equalTo(36);
    }];
    
    //左边按钮
    UIButton *leftBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectZero normalTitle:_leftTitle normalTitleColor:UIColorFromRGBWithAlpha(0x999999, 1) highlightedTitleColor:nil selectedColor:nil titleFont:15 normalImage:nil highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(clickLeftBtn:)];
    [_alertView addSubview:leftBtn];
    [leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(rightBtn.mas_left).offset(-12);
        make.bottom.equalTo(weakSelf.alertView.mas_bottom).offset(-20);
        make.width.mas_equalTo(64);
        make.height.mas_equalTo(36);
    }];
    
    UILabel *messageLab = [MIUIFactory createLabelWithCenter:CGPointZero withBounds:CGRectZero withText:_message withFont:15 withTextColor:[UIColor blackColor] withTextAlignment:NSTextAlignmentLeft];
    if ([_title isEqualToString:@"标定教程"]) {
        messageLab.lineBreakMode = 0;
    }
    messageLab.numberOfLines = 0;
    messageLab.textAlignment = NSTextAlignmentLeft;
    messageLab.font = [UIFont fontWithName:@"Helvetica Neue" size:15];
    [_alertView addSubview:messageLab];
    [messageLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.alertView.mas_left).offset(30);
        make.right.equalTo(weakSelf.alertView.mas_right).offset(-30);
        make.top.equalTo(weakSelf.alertView.mas_top).offset(60);
        make.bottom.equalTo(weakSelf.alertView.mas_bottom).offset(-80);
    }];
}

#pragma mark - 按钮点击事件
- (void)clickRightBtn:(UIButton *)sender {
    if (_rightAction) {
        if ([_title isEqualToString:@"标定教程"]) {
            _rightAction(YES);
        } else {
          _rightAction(NO);
        }
    }
    
    [self removeFromSuperview];
}

- (void)clickLeftBtn:(UIButton *)sender {
    if (_leftAction) {
        if ([_title isEqualToString:@"标定教程"]) {
            _leftAction(NO);
        } else {
            _leftAction(YES);
        }
    }
    
    [self removeFromSuperview];
}

@end
