//
//  MIAlertView.m
//  MicroInsight
//
//  Created by 舒雄威 on 2018/5/25.
//  Copyright © 2018年 QiShon. All rights reserved.
//

#import "MIAlertView.h"
#import "Masonry.h"


@interface MIAlertView () <UITextFieldDelegate>

@property (nonatomic, assign) MIAlertType alertType;
@property (nonatomic, copy) void (^leftAction)(id);
@property (nonatomic, copy) void (^rightAction)(id);
@property (nonatomic, strong) UIView *alertView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, strong) UIView *curProgressView;
@property (nonatomic, strong) UILabel *projectLabel;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) id alertInfo; //记录提示信息

@end


@implementation MIAlertView

+ (void)showAlertViewWithFrame:(CGRect)frame
                   alertBounds:(CGRect)bounds
                     alertType:(MIAlertType)type
                    alertTitle:(NSString *)title
                  alertMessage:(NSString *)message
                     alertInfo:(id)alertInfo
                    leftAction:(void(^)(id alert))leftAction
                   rightAction:(void(^)(id alert))rightAction {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //先移除之前的提示
        UIView *v = [UIApplication sharedApplication].keyWindow.subviews.lastObject;
        if ([v isKindOfClass:[MIAlertView class]]) {
            [v removeFromSuperview];
        }
        
        MIAlertView *alertView = [[MIAlertView alloc] initWithFrame:frame alertBounds:bounds alertType:type alertTitle:title alertMessage:message alertInfo:alertInfo leftAction:leftAction rightAction:rightAction];
        [[UIApplication sharedApplication].keyWindow addSubview:alertView];
    });
}

- (instancetype)initWithFrame:(CGRect)frame
                  alertBounds:(CGRect)bounds
                    alertType:(MIAlertType)type
                   alertTitle:(NSString *)title
                 alertMessage:(NSString *)message
                    alertInfo:(id)alertInfo
                   leftAction:(void(^)(id alert))leftAction
                  rightAction:(void(^)(id alert))rightAction {
    
    if (self = [super initWithFrame:frame]) {
        _alertType = type;
        _leftAction = leftAction;
        _rightAction = rightAction;
        _title = title;
        _message = message;
        _alertInfo = alertInfo;
        
        [self configCommonUIWithAlertBounds:bounds];
        [self configOtherUI];
    }
    
    return self;
}

#pragma mark - 配置UI
//配置共用UI
- (void)configCommonUIWithAlertBounds:(CGRect)bounds {

    //提示框
    _alertView = [[UIView alloc] initWithFrame:bounds];
    _alertView.center = self.center;
    _alertView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_alertView];
    [MIUIFactory addShadowToView:_alertView withOpacity:1 shadowColor:UIColorFromRGBWithAlpha(0x000000, 0.12) shadowRadius:23 andCornerRadius:3];

    //标题
    UILabel *titleLab = [MIUIFactory createLabelWithCenter:CGPointZero withBounds:CGRectZero withText:_title withFont:16 withTextColor:UIColorFromRGBWithAlpha(0x00102C, 1) withTextAlignment:NSTextAlignmentLeft];
    [_alertView addSubview:titleLab];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_alertView.mas_left).offset(40);
        make.right.equalTo(_alertView.mas_right).offset(-40);
        make.top.equalTo(_alertView.mas_top).offset(35);
    }];
    
    NSString *rightText = _alertInfo;
    if (_alertType == QSAlertProgress) {
        rightText = @"取消";
    }
    
    //右边按钮(确定)
    UIButton *rightBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectZero normalTitle:rightText normalTitleColor:[UIColor whiteColor] highlightedTitleColor:nil selectedColor:nil titleFont:15 normalImage:nil highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(clickRightBtn:)];
    rightBtn.backgroundColor = [UIColor redColor];
    rightBtn.layer.cornerRadius = 3;
    rightBtn.layer.masksToBounds = YES;
    if (_alertType == QSAlertProgress) {
        [rightBtn setTitleColor:UIColorFromRGBWithAlpha(0x0070F9, 1) forState:UIControlStateNormal];
        rightBtn.backgroundColor = [UIColor clearColor];
    }
    [_alertView addSubview:rightBtn];
    [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_alertView.mas_right).offset(-40);
        make.bottom.equalTo(_alertView.mas_bottom).offset(-24);
        make.width.mas_equalTo(64);
        make.height.mas_equalTo(36);
    }];
    
    if (_alertType != QSAlertProgress && _alertType != QSAlertStatus) {
        //左边按钮(取消)
        NSString *leftT = @"取消";
        if ([rightText isEqualToString:@"重新标定"]) {
            rightBtn.backgroundColor = UIColorFromRGBWithAlpha(0x0070F9, 1);
            leftT = @"已标定值";
        }
        UIButton *leftBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectZero normalTitle:leftT normalTitleColor:[UIColor whiteColor] highlightedTitleColor:nil selectedColor:nil titleFont:15 normalImage:nil highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(clickLeftBtn:)];
        leftBtn.backgroundColor = [UIColor orangeColor];
        leftBtn.layer.cornerRadius = 3;
        leftBtn.layer.masksToBounds = YES;
        [_alertView addSubview:leftBtn];
        [leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(rightBtn.mas_left).offset(-12);
            make.bottom.equalTo(_alertView.mas_bottom).offset(-24);
            make.width.mas_equalTo(64);
            make.height.mas_equalTo(36);
        }];
    }
}

//配置其他UI
- (void)configOtherUI {
    if (_alertType == QSAlertTextField) {
        [self configAlertTextFieldUI];
    } else if (_alertType == QSAlertProgress) {
        [self configAlertProgressUI];
    } else {
        [self configAlertMessageUI];
    }
}

//配置文本框UI
- (void)configAlertTextFieldUI {
    UILabel *projectLab = [MIUIFactory createLabelWithCenter:CGPointZero withBounds:CGRectZero withText:@"项目名称" withFont:12 withTextColor:UIColorFromRGBWithAlpha(0x415C74, 1) withTextAlignment:NSTextAlignmentLeft];
    [_alertView addSubview:projectLab];
    [projectLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_alertView.mas_left).offset(40);
        make.right.equalTo(_alertView.mas_right).offset(-40);
        make.top.equalTo(_alertView.mas_top).offset(72);
    }];
    
    _textField = [[UITextField alloc] init];
    _textField.backgroundColor = UIColorFromRGBWithAlpha(0x9FB1C1, 0.15);
    _textField.layer.cornerRadius = 3;
    _textField.layer.masksToBounds = YES;
    _textField.textAlignment = NSTextAlignmentLeft;
    _textField.font = [UIFont systemFontOfSize:13];
    _textField.textColor = UIColorFromRGBWithAlpha(0x415C74, 1);
    _textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 1)];
    _textField.leftViewMode = UITextFieldViewModeAlways;
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textField.delegate = self;
    [_textField addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    [_alertView addSubview:_textField];
    [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_alertView.mas_left).offset(40);
        make.right.equalTo(_alertView.mas_right).offset(-40);
        make.bottom.equalTo(_alertView.mas_bottom).offset(-88);
        make.height.mas_equalTo(32);
    }];
    
    [_textField becomeFirstResponder];
}

//配置进度UI
- (void)configAlertProgressUI {
    _projectLabel = [MIUIFactory createLabelWithCenter:CGPointZero withBounds:CGRectZero withText:@"0.0%" withFont:20 withTextColor:UIColorFromRGBWithAlpha(0x0070F9, 1) withTextAlignment:NSTextAlignmentLeft];
    [_alertView addSubview:_projectLabel];
    [_projectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_alertView.mas_left).offset(42);
        make.right.equalTo(_alertView.mas_right).offset(-42);
        make.top.equalTo(_alertView.mas_top).offset(75);
    }];
    
    _progressView = [[UIView alloc] init];
    _progressView.backgroundColor = UIColorFromRGBWithAlpha(0xD0E3F4, 1);
    _progressView.layer.cornerRadius = 2.5;
    _progressView.layer.masksToBounds = YES;
    [_alertView addSubview:_progressView];
    [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_alertView.mas_left).offset(40);
        make.right.equalTo(_alertView.mas_right).offset(-40);
        make.top.equalTo(_projectLabel.mas_bottom).offset(9);
        make.height.mas_equalTo(5);
    }];
    
    _curProgressView = [[UIView alloc] init];
    _curProgressView.backgroundColor = UIColorFromRGBWithAlpha(0x0070F9, 1);
    [_progressView addSubview:_curProgressView];
    [_curProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_progressView.mas_left).offset(0);
        make.top.equalTo(_alertView.mas_top).offset(0);
        make.bottom.equalTo(_progressView.mas_bottom).offset(0);
        make.width.mas_equalTo(0);
    }];
}

//配置提示信息UI
- (void)configAlertMessageUI {
    UILabel *messageLab = [MIUIFactory createLabelWithCenter:CGPointZero withBounds:CGRectZero withText:_message withFont:14 withTextColor:UIColorFromRGBWithAlpha(0x415C74, 1) withTextAlignment:NSTextAlignmentLeft];
    messageLab.numberOfLines = 0;
    [_alertView addSubview:messageLab];
    [messageLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_alertView.mas_left).offset(42);
        make.right.equalTo(_alertView.mas_right).offset(-42);
        make.top.equalTo(_alertView.mas_top).offset(75);
        make.bottom.equalTo(_alertView.mas_bottom).offset(-100);
    }];
}

#pragma mark - 按钮点击事件
- (void)clickRightBtn:(UIButton *)sender {
    if (_rightAction) {
        if (_alertType == QSAlertTextField) {
            if ([MIHelpTool isBlankString:_textField.text]) {
                return;
            }
            
            _rightAction(_textField.text);
        } else {
            _rightAction(_alertInfo);
        }
    }

    [self removeFromSuperview];
}

- (void)clickLeftBtn:(UIButton *)sender {
    if (_leftAction) {
        _leftAction(nil);
    }
    
    [self removeFromSuperview];
}

#pragma mark - 外部方法
//刷新当前拷贝进度
- (void)refreshCurrentProgress:(CGFloat)progress completed:(void(^)(NSString *diskName))completed {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (progress == -1) {
            if (completed) {
                completed(nil);
                [self removeFromSuperview];
            }
            
            return;
        }
        
        CGFloat width = _progressView.bounds.size.width;
        _projectLabel.text = [NSString stringWithFormat:@"%.1f%%", progress * 100];
        [_curProgressView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(progress * width);
        }];
        
        //拷贝完成
        if (progress == 1) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
                if (completed) {
                    completed(_alertInfo);
                    [self removeFromSuperview];
                }
            });
        }
    });
}

#pragma mark - touch事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_textField) {
        [_textField resignFirstResponder];
    }
}

#pragma mark - TextFieldDelegate
//判断是否满足规则，改变输入框
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([MIHelpTool isInputRuleAndNumber:string] || [string isEqualToString:@""]) {
        return YES;
    }
    return NO;
}

//输入框的内容发生改变
- (void)textFieldDidChanged:(UITextField *)textField {
    NSString *toBeString = textField.text;
    NSString *lastString;
    if (toBeString.length > 0) {
        lastString=[toBeString substringFromIndex:toBeString.length - 1];
    }
    if (![MIHelpTool isInputRuleAndNumber:toBeString] && [MIHelpTool hasEmoji:lastString]) {
        textField.text = [MIHelpTool disable_emoji:toBeString];
        return;
    }
    
    NSString *lang = [[textField textInputMode] primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if (!position) {
            NSString *getStr = [MIHelpTool getSubString:toBeString];
            if (getStr && getStr.length > 0) {
                textField.text = getStr;
            }
        }
    } else {
        NSString *getStr = [MIHelpTool getSubString:toBeString];
        if (getStr && getStr.length > 0) {
            textField.text = getStr;
        }
    }
}

@end
