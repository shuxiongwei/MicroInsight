//
//  MILoginViewController.m
//  MicroInsight
//
//  Created by Jonphy on 2018/11/19.
//  Copyright © 2018 舒雄威. All rights reserved.
//


#import "MILoginsViewController.h"
#import "MIThirdPartyLoginManager.h"
#import "MIUserAgreementView.h"

typedef NS_ENUM(NSInteger,MIModuleType) {
    MIModuleTypeLogin,
    MIModuleTypAssign
};

@interface MILoginsViewController ()

@property (weak, nonatomic) IBOutlet UIButton *messageBtn;
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
@property (weak, nonatomic) IBOutlet UIButton *agreementBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomHeight;
@property (weak, nonatomic) IBOutlet UIButton *companyBtn;
@property (nonatomic, assign) MIModuleType type;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger downCount;

@end

@implementation MILoginsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _downCount = 60;
    _type = MIModuleTypeLogin;
    _checkPswTFSupView.hidden = YES;
    _contentViewHeight.constant = 200;
    _bottomHeight.constant = 25;
    _agreementBtn.hidden = YES;
    _companyBtn.hidden = YES;
    _loginTitle.font = [UIFont captionFontWithName:@"custom" size:20];
    _messageBtn.layer.cornerRadius = 5;
    _messageBtn.layer.masksToBounds = YES;
}

#pragma mark - 定时器
- (void)initTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerRun) userInfo:nil repeats:YES];
}

- (void)timerRun {
    _downCount --;
    if (_downCount == 0) {
        _messageBtn.userInteractionEnabled = YES;
        _messageBtn.backgroundColor = UIColorFromRGBWithAlpha(0x75AD0D, 1);
        [_messageBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [self stopTimer];
    } else {
        _messageBtn.backgroundColor = [UIColor lightGrayColor];
        [_messageBtn setTitle:[NSString stringWithFormat:@"%ld秒后获取", _downCount] forState:UIControlStateNormal];
    }
}

- (void)stopTimer {
    [_timer invalidate];
    _timer = nil;
}

#pragma mark - IB Action
- (IBAction)loginBtnClick:(UIButton *)sender {
    [self refreshUI];
    [_bottomBtn setTitle:@"登   录" forState:UIControlStateNormal];
    _type = MIModuleTypeLogin;
    _checkPswTFSupView.hidden = YES;
    _messageBtn.hidden = YES;
    _contentViewHeight.constant = 200;
    _bottomHeight.constant = 25;
    _agreementBtn.hidden = YES;
    _companyBtn.hidden = YES;
    sender.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    _signInBtn.titleLabel.font = [UIFont systemFontOfSize:14];
}

- (IBAction)assignBtnClick:(UIButton *)sender {
    [self refreshUI];
    [_bottomBtn setTitle:@"注   册" forState:UIControlStateNormal];
    _type = MIModuleTypAssign;
    _checkPswTFSupView.hidden = NO;
    _messageBtn.hidden = NO;
    _contentViewHeight.constant = 270;
    _bottomHeight.constant = 40;
    _agreementBtn.hidden = NO;
    _companyBtn.hidden = NO;
    sender.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    _loginBtn.titleLabel.font = [UIFont systemFontOfSize:14];
}

- (IBAction)XBtnClick:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)bottomBtnClick:(UIButton *)sender {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    if (_accountTF.text.length == 0 || _passwordTF.text.length == 0) {
        [self alertText:@"请输入手机号或密码"];
        return;
    }

    if (_type == MIModuleTypAssign) {
        NSString *psd = [_passwordTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (psd.length < 6) {
            [self alertText:@"密码不得少于6位"];
            return;
        }
    
        if ([MIHelpTool isBlankString:_passwordCheckTF.text]) {
            [self alertText:@"请输入短信验证码"];
            return;
        }
        
        if (!_agreementBtn.selected) {
            [self alertText:@"注册需同意用户协议"];
            return;
        }
    }
    
    WSWeak(weakSelf);
    if (_type == MIModuleTypeLogin) {
        [MIRequestManager loginWithUsername:_accountTF.text password:_passwordTF.text completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
            
            NSInteger code = [jsonData[@"code"] integerValue];
            if (code == 0) {
                NSDictionary *data = jsonData[@"data"];
                NSDictionary *user = data[@"user"];
                MIUserInfoModel *model = [MIUserInfoModel yy_modelWithDictionary:user];
                [MILocalData saveCurrentLoginUserInfo:model];
                
                [weakSelf.navigationController popViewControllerAnimated:YES];
            } else {
                [weakSelf alertText:@"登录失败"];
            }
        }];
    } else {
//        [MIRequestManager registerWithUsername:_accountTF.text password:_passwordTF.text completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
//
//            NSInteger code = [jsonData[@"code"] integerValue];
//            if (code == 0) {
//                [weakSelf loginBtnClick:weakSelf.loginBtn];
//            } else {
//                [weakSelf alertText:@"注册失败"];
//            }
//        }];
        
        [MIRequestManager registerWithMobile:_accountTF.text password:_passwordTF.text verifyToken:_token verifyCode:_passwordCheckTF.text completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
            
            NSInteger code = [jsonData[@"code"] integerValue];
            if (code == 0) {
                [weakSelf loginBtnClick:weakSelf.loginBtn];
                [weakSelf alertText:@"注册成功"];
            } else {
                [weakSelf alertText:@"注册失败"];
            }
        }];
    }
}

- (IBAction)textfieldEditingChanged:(UITextField *)sender {
    
}

- (IBAction)thirdPartLoginByQQ:(UIButton *)sender {
    
    WSWeak(weakSelf);
    [[MIThirdPartyLoginManager shareManager] getUserInfoWithWTLoginType:MILoginTypeTencent result:^(NSDictionary *loginResult, NSString *error) {

        if ([MIHelpTool isBlankString:error]) {
            [MIRequestManager loginByQQWithOpenId:loginResult[@"openId"] accessToken:loginResult[@"accessToken"] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {

                NSInteger code = [jsonData[@"code"] integerValue];
                if (code == 0) {
                    NSDictionary *data = jsonData[@"data"];
                    NSDictionary *user = data[@"user"];
                    MIUserInfoModel *model = [MIUserInfoModel yy_modelWithDictionary:user];
                    [MILocalData saveCurrentLoginUserInfo:model];

                    [weakSelf.navigationController popViewControllerAnimated:YES];
                } else {
                    [weakSelf alertText:@"登录失败"];
                }
            }];
        } else {
            [MIToastAlertView showAlertViewWithMessage:error];
        }
    } showViewController:self];
}

- (IBAction)thirdPartLoginByWX:(UIButton *)sender {
    
    WSWeak(weakSelf);
    [[MIThirdPartyLoginManager shareManager] getUserInfoWithWTLoginType:MILoginTypeWeiXin result:^(NSDictionary *loginResult, NSString *error) {

        if ([MIHelpTool isBlankString:error]) {
            [MIRequestManager loginByWXWithCode:loginResult[@"code"] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
                
                NSInteger code = [jsonData[@"code"] integerValue];
                if (code == 0) {
                    NSDictionary *data = jsonData[@"data"];
                    NSDictionary *user = data[@"user"];
                    MIUserInfoModel *model = [MIUserInfoModel yy_modelWithDictionary:user];
                    [MILocalData saveCurrentLoginUserInfo:model];
                    
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                } else {
                    [weakSelf alertText:@"登录失败"];
                }
            }];
        } else {
            [MIToastAlertView showAlertViewWithMessage:error];
        }
    } showViewController:self];
}

- (IBAction)clickMessageBtn:(UIButton *)sender {
    
    WSWeak(weakSelf);
    [MIRequestManager getMessageVerificationCodeWithMobile:_accountTF.text type:0 completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        NSInteger code = [jsonData[@"code"] integerValue];
        if (code == 0) {
            NSDictionary *data = jsonData[@"data"];
            weakSelf.token = data[@"verifyToken"];
            [weakSelf initTimer];
        }
    }];
}

- (IBAction)clickAgreementBtn:(UIButton *)sender {
    sender.selected = !sender.selected;
}

- (IBAction)clickCompanyBtn:(UIButton *)sender {
    MIUserAgreementView *userV = [[MIUserAgreementView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:userV];
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
