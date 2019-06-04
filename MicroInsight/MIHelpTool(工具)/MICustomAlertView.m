//
//  MICustomAlertView.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/18.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MICustomAlertView.h"
#import "MicroInsight-Swift.h"

@interface MICustomAlertView ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) void (^leftAction)(void);
@property (nonatomic, copy) void (^rightAction)(void);

@end


@implementation MICustomAlertView

+ (void)showAlertViewWithFrame:(CGRect)frame
                    alertTitle:(NSString *)title
                  alertMessage:(NSString *)message
                    leftAction:(void(^)(void))leftAction
                   rightAction:(void(^)(void))rightAction {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //先移除之前的提示
        UIView *v = [UIApplication sharedApplication].keyWindow.subviews.lastObject;
        if ([v isKindOfClass:[MICustomAlertView class]]) {
            [v removeFromSuperview];
        }
        
        MICustomAlertView *alertView = [[MICustomAlertView alloc] initWithFrame:frame alertTitle:title alertMessage:message leftAction:leftAction rightAction:rightAction];
        [[UIApplication sharedApplication].keyWindow addSubview:alertView];
    });
}

- (instancetype)initWithFrame:(CGRect)frame
                   alertTitle:(NSString *)title
                 alertMessage:(NSString *)message
                   leftAction:(void(^)(void))leftAction
                  rightAction:(void(^)(void))rightAction {
    
    if (self = [super initWithFrame:frame]) {
        _title = title;
        _message = message;
        _leftAction = leftAction;
        _rightAction = rightAction;
        self.backgroundColor = UIColorFromRGBWithAlpha(0x666666, 0.8);
        [self configAlertUI];
    }
    
    return self;
}

- (void)configAlertUI {
    CGFloat scale = MIScreenWidth / 375.0;
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 295 * scale, 170 * scale)];
    bgView.center = self.center;
    bgView.backgroundColor = [UIColor whiteColor];
    [bgView round:3 RectCorners:UIRectCornerAllCorners];
    [self addSubview:bgView];
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(29, 33, bgView.width - 58, 15)];
    titleLab.text = _title;
    titleLab.textColor = UIColorFromRGBWithAlpha(0x333333, 1);
    titleLab.textAlignment = NSTextAlignmentLeft;
    titleLab.font = [UIFont systemFontOfSize:15];
    [bgView addSubview:titleLab];
    
    UILabel *messageLab = [[UILabel alloc] initWithFrame:CGRectMake(29, 70, bgView.width - 58, 15)];
    messageLab.text = _message;
    messageLab.textColor = UIColorFromRGBWithAlpha(0x666666, 1);
    messageLab.textAlignment = NSTextAlignmentLeft;
    messageLab.font = [UIFont systemFontOfSize:15];
    [bgView addSubview:messageLab];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, bgView.height - 50, bgView.width / 2.0, 50);
    leftBtn.backgroundColor = UIColorFromRGBWithAlpha(0xF9F9F9, 1);
    [leftBtn setTitle:@"取消" forState:UIControlStateNormal];
    [leftBtn setTitleColor:UIColorFromRGBWithAlpha(0xBEBEBE, 1) forState:UIControlStateNormal];
    leftBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [leftBtn addTarget:self action:@selector(clickLeftBtn) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:leftBtn];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(bgView.width / 2.0, bgView.height - 50, bgView.width / 2.0, 50);
    [rightBtn setTitle:@"确定" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [rightBtn setButtonCustomBackgroudImageWithBtn:rightBtn fromColor:UIColorFromRGBWithAlpha(0x72B3E3, 1) toColor:UIColorFromRGBWithAlpha(0x6DD1CC, 1)];
    [rightBtn addTarget:self action:@selector(clickRightBtn) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:rightBtn];
}

- (void)clickLeftBtn {
    if (_leftAction) {
        _leftAction();
    }
    
    [self removeFromSuperview];
}

- (void)clickRightBtn {
    if (_rightAction) {
        _rightAction();
    }
    
    [self removeFromSuperview];
}

@end
