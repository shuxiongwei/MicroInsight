//
//  MIDemarcateAlertView.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/4/16.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIDemarcateAlertView.h"


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
    self.backgroundColor = UIColorFromRGBWithAlpha(0x000000, 0.5);
    
    CGRect rect;
    CGFloat titleTopMargin;
    CGFloat messageTopMargin;
    CGFloat messageLeftMargin;
    CGFloat messageRightMargin;
    if ([_title isEqualToString:@"标定教程"]) {
        rect = CGRectMake(0, 0, 235, 210);
        titleTopMargin = 30;
        messageTopMargin = 66;
        messageLeftMargin = 28;
        messageRightMargin = 25;
    } else {
        rect = CGRectMake(0, 0, 235, 199);
        titleTopMargin = 35;
        messageTopMargin = 74;
        messageLeftMargin = 27;
        messageRightMargin = 23;
    }
    
    //提示框
    _alertView = [[UIView alloc] initWithFrame:rect];
    _alertView.center = self.center;
    _alertView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_alertView];
    [_alertView round:3 RectCorners:UIRectCornerAllCorners];

    //标题
    UILabel *titleLab = [MIUIFactory createLabelWithCenter:CGPointZero withBounds:CGRectZero withText:_title withFont:18 withTextColor:UIColorFromRGBWithAlpha(0x00102C, 1) withTextAlignment:NSTextAlignmentLeft];
    [_alertView addSubview:titleLab];
    WSWeak(weakSelf);
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.alertView.mas_left).offset(26);
        make.right.equalTo(weakSelf.alertView.mas_right).offset(-30);
        make.top.equalTo(weakSelf.alertView.mas_top).offset(titleTopMargin);
    }];
    
    //右边按钮
    UIButton *rightBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectZero normalTitle:_rightTitle normalTitleColor:UIColorFromRGBWithAlpha(0x333333, 1) highlightedTitleColor:nil selectedColor:nil titleFont:14 normalImage:nil highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(clickRightBtn:)];
    rightBtn.backgroundColor = UIColorFromRGBWithAlpha(0xF9F9F9, 1);
    [_alertView addSubview:rightBtn];
    [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.alertView.mas_right).offset(-25);
        make.bottom.equalTo(weakSelf.alertView.mas_bottom).offset(-21);
        make.width.mas_equalTo(88);
        make.height.mas_equalTo(40);
    }];
    
    //左边按钮
    UIButton *leftBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectZero normalTitle:_leftTitle normalTitleColor:UIColorFromRGBWithAlpha(0x666666, 1) highlightedTitleColor:nil selectedColor:nil titleFont:14 normalImage:nil highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(clickLeftBtn:)];
    leftBtn.backgroundColor = UIColorFromRGBWithAlpha(0xF9F9F9, 1);
    [_alertView addSubview:leftBtn];
    [leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(26);
        make.bottom.equalTo(weakSelf.alertView.mas_bottom).offset(-21);
        make.width.mas_equalTo(88);
        make.height.mas_equalTo(40);
    }];
    
    UILabel *messageLab = [MIUIFactory createLabelWithCenter:CGPointZero withBounds:CGRectZero withText:_message withFont:15 withTextColor:UIColorFromRGBWithAlpha(0x666666, 1) withTextAlignment:NSTextAlignmentLeft];
    if ([_title isEqualToString:@"标定教程"]) {
        messageLab.lineBreakMode = 0;
    }
    [UILabel changeLineSpaceForLabel:messageLab WithSpace:5];
    messageLab.numberOfLines = 0;
    messageLab.textAlignment = NSTextAlignmentLeft;
    [_alertView addSubview:messageLab];
    [messageLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.alertView.mas_left).offset(messageLeftMargin);
        make.right.equalTo(weakSelf.alertView.mas_right).offset(-messageRightMargin);
        make.top.equalTo(weakSelf.alertView.mas_top).offset(messageTopMargin);
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
