//
//  MILoginViewController.m
//  MicroInsight
//
//  Created by Jonphy on 2018/11/19.
//  Copyright © 2018 舒雄威. All rights reserved.
//


#import "MILoginViewController.h"

typedef NS_ENUM(NSInteger,MIModuleType) {
    MIModuleTypeLogin,
    MIModuleTypAssign
};

@interface MILoginViewController ()

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *signInBtn;
@property (weak, nonatomic) IBOutlet UITextField *accountTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordCheckTF;
@property (weak, nonatomic) IBOutlet UIButton *bottomBtn;
@property (weak, nonatomic) IBOutlet UIView *checkPswTFSupView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeight;

@end

@implementation MILoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - IB Action
- (IBAction)loginBtnClick:(UIButton *)sender {
    
}

- (IBAction)assignBtnClick:(UIButton *)sender {
    
}

- (IBAction)XBtnClick:(UIButton *)sender {
    
}

- (IBAction)bottomBtnClick:(UIButton *)sender {
    
}

- (IBAction)textfieldEditingChanged:(UITextField *)sender {
    
}

@end
