//
//  MIMineEditViewController.m
//  MicroInsight
//
//  Created by 舒雄威 on 2018/12/21.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "MIMineEditViewController.h"
#import "MIDatePickerView.h"

const NSInteger maxLength = 10;

@interface MIMineEditViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nicknameTF;
@property (weak, nonatomic) IBOutlet UILabel *genderLab;
@property (weak, nonatomic) IBOutlet UILabel *birthdayLab;

@end

@implementation MIMineEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"编辑资料";
    [super configLeftBarButtonItem:@"返回"];
    [super configRightBarButtonItemWithType:UIButtonTypeCustom frame:CGRectMake(0, 0, 40, 30) normalTitle:@"保存" normalTitleColor:[UIColor whiteColor] highlightedTitleColor:nil selectedColor:nil titleFont:15 normalImage:nil highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(clickSaveBtn:)];
    
    MIUserInfoModel *model = [MILocalData getCurrentLoginUserInfo];
    _genderLab.text = (model.gender == 0 ? @"男" : @"女");
    _birthdayLab.text = model.birthday;
    _nicknameTF.text = model.nickname;
    _nicknameTF.delegate = self;
    [_nicknameTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _nicknameTF.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _nicknameTF.layer.borderWidth = 0.5;
    _nicknameTF.layer.cornerRadius = 17.5;
    _nicknameTF.layer.masksToBounds = YES;
    [_nicknameTF setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
}

- (IBAction)selectGender:(UIButton *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle: UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    WSWeak(weakSelf);
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"男" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        weakSelf.genderLab.text = action.title;
    }];
    
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"女" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        weakSelf.genderLab.text = action.title;
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:cameraAction];
    [alertController addAction:photoAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 注销登录
- (IBAction)logout:(UIButton *)sender {
    UIAlertController *alertVC = [MIUIFactory createAlertControllerWithTitle:nil titleColor:nil titleFont:0 message:@"您确定要注销登录" messageColor:[UIColor darkGrayColor] messageFont:18 alertStyle:UIAlertControllerStyleAlert actionLeftTitle:@"取消" actionLeftStyle:UIAlertActionStyleDefault actionRightTitle:@"确定" actionRightStyle:UIAlertActionStyleDefault actionTitleColor:[UIColor darkGrayColor] selectAction:^{
        
        
    }];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (IBAction)selectBirthday:(UIButton *)sender {
    NSDate *birthdayDate = [MIHelpTool converString:_birthdayLab.text toDateByFormat:@"yyyy-MM-dd"];
    WSWeak(weakSelf);
    MIDatePickerView *pickerV = [[MIDatePickerView alloc] initWithDateStyle:DateStyleShowYearMonthDay scrollToDate:birthdayDate CompleteBlock:^(NSDate *date) {
        
        weakSelf.birthdayLab.text = [MIHelpTool converDate:date toStringByFormat:@"yyyy-MM-dd"];
    }];
    [pickerV show];
}

- (void)clickSaveBtn:(UIButton *)sender {
    if ([MIHelpTool isBlankString:_nicknameTF.text]) {
        [MIToastAlertView showAlertViewWithMessage:@"昵称不得为空"];
        return;
    }
    
    [MBProgressHUD showStatus:@"信息保存中，请稍后！"];
    
    WSWeak(weakSelf);
    //NSDate *birthdayDate = [MIHelpTool converString:_birthdayLab.text toDateByFormat:@"yyyy-MM-dd"];
    [MIRequestManager modifyUserInfoWithNickname:_nicknameTF.text gender:_genderLab.text birthday:_birthdayLab.text requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
        });
        
        NSInteger code = [jsonData[@"code"] integerValue];
        if (code == 0) {
            MIUserInfoModel *model = [MILocalData getCurrentLoginUserInfo];
            model.nickname = weakSelf.nicknameTF.text;
            model.gender = ([weakSelf.genderLab.text isEqualToString:@"男"] ? 0 : 1);
            model.birthday = weakSelf.birthdayLab.text;
            [MILocalData saveCurrentLoginUserInfo:model];
            
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } else {
            [MIToastAlertView showAlertViewWithMessage:@"信息保存失败"];
        }
    }];
}

#pragma mark - UITextFieldDelegate
//判断是否满足规则，改变输入框
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([MIHelpTool isInputRuleAndNumber:string] || [string isEqualToString:@""]) {
        return YES;
    }
    return NO;
}

//输入框的内容发生改变
- (void)textFieldDidChange:(UITextField *)textField {
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

#pragma mark - touch事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_nicknameTF resignFirstResponder];
}

@end
