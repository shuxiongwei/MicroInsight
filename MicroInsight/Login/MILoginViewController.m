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

@property (weak, nonatomic) IBOutlet UILabel *loginTitle;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *signInBtn;
@property (weak, nonatomic) IBOutlet UITextField *accountTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordCheckTF;
@property (weak, nonatomic) IBOutlet UIButton *bottomBtn;
@property (weak, nonatomic) IBOutlet UIView *checkPswTFSupView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkPsdTFHeight;
@property (nonatomic, assign) MIModuleType type;

@end

@implementation MILoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _type = MIModuleTypeLogin;
    _checkPswTFSupView.hidden = YES;
    _contentViewHeight.constant = 200;
    _loginTitle.font = [UIFont captionFontWithName:@"custom" size:20];
}

#pragma mark - IB Action
- (IBAction)loginBtnClick:(UIButton *)sender {
    [self refreshUI];
    [_bottomBtn setTitle:@"登录" forState:UIControlStateNormal];
    _type = MIModuleTypeLogin;
    _checkPswTFSupView.hidden = YES;
    _contentViewHeight.constant = 200;
    sender.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    _signInBtn.titleLabel.font = [UIFont systemFontOfSize:14];
}

- (IBAction)assignBtnClick:(UIButton *)sender {
    [self refreshUI];
    [_bottomBtn setTitle:@"注册" forState:UIControlStateNormal];
    _type = MIModuleTypAssign;
    _checkPswTFSupView.hidden = NO;
    _contentViewHeight.constant = 250;
    sender.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    _loginBtn.titleLabel.font = [UIFont systemFontOfSize:14];
}

- (IBAction)XBtnClick:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)bottomBtnClick:(UIButton *)sender {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    if (_accountTF.text.length == 0 || _passwordTF.text.length == 0) {
        [self alertText:@"请输入账号或密码"];
        return;
    }

    if (_type == MIModuleTypAssign) {
        NSString *psd = [_passwordTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (psd.length < 6) {
            [self alertText:@"密码不得少于6位"];
            return;
        }
    
        if (![_passwordTF.text isEqualToString:_passwordCheckTF.text]) {
            [self alertText:@"输入的确认密码不正确"];
            return;
        }
    }

    if (_type == MIModuleTypeLogin) {
        [MIRequestManager loginWithUsername:_accountTF.text password:_passwordTF.text completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
            
            NSInteger code = [jsonData[@"code"] integerValue];
            if (code == 0) {
                NSDictionary *data = jsonData[@"data"];
                NSDictionary *user = data[@"user"];
                [MILocalData setCurrentLoginUsername:user[@"username"]];
                [MILocalData setCurrentRequestToken:user[@"token"]];
                
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [self alertText:@"登录失败"];
            }
        }];
    } else {
        [MIRequestManager registerWithUsername:_accountTF.text password:_passwordTF.text completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
            
            NSInteger code = [jsonData[@"code"] integerValue];
            if (code == 0) {
                [self loginBtnClick:_loginBtn];
            } else {
                [self alertText:@"注册失败"];
            }
        }];
    }
}

- (IBAction)textfieldEditingChanged:(UITextField *)sender {
    
}

- (void)refreshUI {
    _accountTF.text = nil;
    _passwordTF.text = nil;
    _passwordCheckTF.text = nil;
}

#pragma mark AlertView
- (void)alertText :(NSString *)text{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:text delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
    alert.layer.cornerRadius = 8.0;
    alert.layer.masksToBounds = YES;
    [alert show];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

@end
