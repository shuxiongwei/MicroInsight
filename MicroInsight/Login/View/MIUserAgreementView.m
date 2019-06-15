//
//  MIUserAgreementView.m
//  MicroInsight
//
//  Created by 舒雄威 on 17/8/24.
//  Copyright © 2017年 Yoya. All rights reserved.
//

#import "MIUserAgreementView.h"

#define WIDTH (frame.size.width)
#define HEIGHT (self.bounds.size.height)

@interface MIUserAgreementView ()

@property (nonatomic ,strong) UIView *navigationView;
@property (nonatomic ,strong) UIWebView *serviceDelegateWebView;

@end

@implementation MIUserAgreementView

- (UIView *)navigationView {
    
    if (!_navigationView) {
        _navigationView = [[UIView alloc] init];
    }
    return _navigationView;
}

- (UIWebView *)serviceDelegateWebView {
    
    if (!_serviceDelegateWebView) {
        _serviceDelegateWebView = [[UIWebView alloc] init];
    }
    return _serviceDelegateWebView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self addNavigtaionViewWithFrame:frame];
        [self addWebViewWithFrame:frame];
    }
    
    return self;
}

- (void)addNavigtaionViewWithFrame:(CGRect)frame {
    self.navigationView.frame = CGRectMake(0, 0, WIDTH, KNaviBarAllHeight);
    self.navigationView.backgroundColor = [UIColor whiteColor];
    [self.navigationView addSubview:[self addGObackButton]];
    [self.navigationView addSubview:[self addTitle]];
    [self addSubview:self.navigationView];
}

//返回按钮
- (UIButton *)addGObackButton {
    CGFloat y = (KIsiPhoneX ? 30 : 10);
    UIButton *gobackButton = [[UIButton alloc] initWithFrame:CGRectMake(2, y, 50, 50)];
    [gobackButton setImage:[UIImage imageNamed:@"icon_review_close_nor"] forState:UIControlStateNormal];
    [gobackButton addTarget:self action:@selector(goBackView) forControlEvents:UIControlEventTouchDown];
    return gobackButton;
}

- (void)goBackView {
    [self removeFromSuperview];
}

//title
- (UILabel *)addTitle {
    CGFloat y = (KIsiPhoneX ? 30 : 10);
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width / 2 - 100, y, 200, 44)];
    title.text = @"用户服务协议";
    title.font = [UIFont systemFontOfSize:18];
    title.textAlignment = NSTextAlignmentCenter;
    return title;
}

//本地html 协议
- (void)addWebViewWithFrame:(CGRect)frame {
    self.serviceDelegateWebView.frame = CGRectMake(0, KNaviBarAllHeight, WIDTH, HEIGHT - KNaviBarAllHeight);
    
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"user_agreement.html" withExtension:nil];
    NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
    [self.serviceDelegateWebView loadRequest:request];
    [self addSubview:self.serviceDelegateWebView];
}

@end
