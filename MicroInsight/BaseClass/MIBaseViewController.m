//
//  MIBaseViewController.m
//  MicroInsight
//
//  Created by 舒雄威 on 2018/8/22.
//  Copyright © 2018年 舒雄威. All rights reserved.
//

#import "MIBaseViewController.h"


@interface MIBaseViewController ()

@end

@implementation MIBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont boldSystemFontOfSize:18],
       NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)configBackBtn {
    UIButton *backBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(20, 20, 30, 30) normalTitle:nil normalTitleColor:nil highlightedTitleColor:nil selectedColor:nil titleFont:0 normalImage:[UIImage imageNamed:@"icon_review_close_nor"] highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(goBack:)];
    [self.view addSubview:backBtn];
}

#pragma mark - 配置导航栏左边视图
- (void)configLeftBarButtonItem:(NSString *)text {
    UIButton *leftBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(0, 0, 40, 30) normalTitle:text normalTitleColor:[UIColor whiteColor] highlightedTitleColor:nil selectedColor:nil titleFont:15 normalImage:[UIImage imageNamed:@"return"] highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(popToForwardViewController)];
    [leftBtn layoutButtonWithEdgeInsetsStyle:MIButtonEdgeInsetsStyleLeft imageTitleSpace:5];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
}

- (void)popToForwardViewController {
    [self releaseObject];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 配置导航栏右边视图
- (void)configRightBarButtonItemWithType:(UIButtonType)type
                                   frame:(CGRect)frame
                             normalTitle:(NSString *)title
                        normalTitleColor:(UIColor *)norColor
                   highlightedTitleColor:(UIColor *)hgtColor
                           selectedColor:(UIColor *)selColor
                               titleFont:(CGFloat)font
                             normalImage:(UIImage *)norImage
                        highlightedImage:(UIImage *)highImage
                           selectedImage:(UIImage *)selImage
                     touchUpInSideTarget:(id)target
                                  action:(SEL)action {
    UIButton *rightBtn = [MIUIFactory createButtonWithType:type frame:frame normalTitle:title normalTitleColor:norColor highlightedTitleColor:hgtColor selectedColor:selColor titleFont:font normalImage:norImage highlightedImage:highImage selectedImage:selImage touchUpInSideTarget:target action:action];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
}

#pragma mark - 释放对象
- (void)releaseObject {
    
}

#pragma mark - 事件响应
//返回
- (void)goBack:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
