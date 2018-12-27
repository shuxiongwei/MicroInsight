//
//  MIMineViewController.m
//  MicroInsight
//
//  Created by 舒雄威 on 2017/12/29.
//  Copyright © 2017年 舒雄威. All rights reserved.
//

#import "MIMineViewController.h"
#import "AppDelegate.h"
#import <Photos/Photos.h>
#import "MIMineEditViewController.h"
#import "UIImageView+WebCache.h"
#import "MICommunityViewController.h"

@interface MIMineViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *userLab;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLab;
@property (weak, nonatomic) IBOutlet UILabel *genderLab;
@property (weak, nonatomic) IBOutlet UILabel *birthdayLab;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndeView;

@end

@implementation MIMineViewController

- (UIActivityIndicatorView *)activityIndeView {
    if (!_activityIndeView) {
        _activityIndeView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 80) / 2.0, (self.view.bounds.size.height - 80) / 2.0, 80, 80)];
        _activityIndeView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        _activityIndeView.hidesWhenStopped = YES;
    }
    return _activityIndeView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //去除导航栏下方的横线
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init]
                                                  forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc]init]];
    [self refreshMineUI];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.title = @"个人中心";
    [super configLeftBarButtonItem:@"返回"];
    [super configRightBarButtonItemWithType:UIButtonTypeCustom frame:CGRectMake(0, 0, 40, 30) normalTitle:@"编辑" normalTitleColor:[UIColor whiteColor] highlightedTitleColor:nil selectedColor:nil titleFont:15 normalImage:nil highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(clickEditBtn:)];
    
    [self configMineUI];
}

#pragma mark - 配置UI
- (void)configMineUI {
    [self.view addSubview:self.activityIndeView];
    _headImageView.layer.cornerRadius = _headImageView.size.width / 2.0;
    _headImageView.layer.masksToBounds = YES;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchHeadImageView:)];
    [_headImageView addGestureRecognizer:recognizer];
    
    MIUserInfoModel *model = [MILocalData getCurrentLoginUserInfo];
    //等比缩放，限定在矩形框外
    NSString *imgUrl = [NSString stringWithFormat:@"%@?x-oss-process=image/resize,m_fill,h_%ld,w_%ld", model.avatar, (NSInteger)_headImageView.size.width / 1, (NSInteger)_headImageView.size.width / 1];
    [_headImageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"account"] options:SDWebImageRetryFailed];
}

- (void)refreshMineUI {
    MIUserInfoModel *model = [MILocalData getCurrentLoginUserInfo];
    _nicknameLab.text = model.nickname;
    _genderLab.text = (model.gender == 0 ? @"男" : @"女");
    _birthdayLab.text = model.birthday;
    _userLab.text = model.username;
}

#pragma mark - 修改头像
- (void)touchHeadImageView:(UIGestureRecognizer *)recognizer {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle: UIAlertControllerStyleActionSheet];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        AVAuthorizationStatus AVstatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (AVstatus == AVAuthorizationStatusDenied) {
            UIAlertController *alertVC = [MIUIFactory createAlertControllerWithTitle:@"无法访问相机" titleColor:[UIColor darkGrayColor] titleFont:16 message:@"请在iPhone的\"设置-隐私-相机\"中允许访问相机" messageColor:[UIColor darkGrayColor] messageFont:18 alertStyle:UIAlertControllerStyleAlert actionLeftTitle:@"取消" actionLeftStyle:UIAlertActionStyleDefault actionRightTitle:@"设置" actionRightStyle:UIAlertActionStyleDefault actionTitleColor:[UIColor darkGrayColor] selectAction:^{
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }];
            [self presentViewController:alertVC animated:YES completion:nil];
            return;
        } else if (AVstatus == AVAuthorizationStatusNotDetermined) {
            [MBProgressHUD showError:@"此设备不支持拍照"];
        }
        
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }];
    
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"从相册上传" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:cameraAction];
    [alertController addAction:photoAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 注销登录
- (IBAction)logout:(UIButton *)sender {
    UIAlertController *alertVC = [MIUIFactory createAlertControllerWithTitle:nil titleColor:nil titleFont:0 message:@"您确定要注销登录" messageColor:[UIColor darkGrayColor] messageFont:18 alertStyle:UIAlertControllerStyleAlert actionLeftTitle:@"取消" actionLeftStyle:UIAlertActionStyleDefault actionRightTitle:@"确定" actionRightStyle:UIAlertActionStyleDefault actionTitleColor:[UIColor darkGrayColor] selectAction:^{
        
        [MILocalData saveCurrentLoginUserInfo:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (IBAction)gotoMineProduction:(UIButton *)sender {
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Community" bundle:nil];
    MICommunityViewController *vc = [board instantiateViewControllerWithIdentifier:@"MICommunityViewController"];
    vc.isMine = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)clickEditBtn:(UIButton *)sender {
    MIMineEditViewController *editVC = [[MIMineEditViewController alloc] initWithNibName:@"MIMineEditViewController" bundle:nil];
    [self.navigationController pushViewController:editVC animated:YES];
}

#pragma mark - UIImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *image;
    if (picker.allowsEditing) {
        image = info[@"UIImagePickerControllerEditedImage"];
    } else {
        image = info[@"UIImagePickerControllerOriginalImage"];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self modifyUserAvatar:image];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)modifyUserAvatar:(UIImage *)image {
    if (!self.activityIndeView.isAnimating) {
        [self.activityIndeView startAnimating];
    }
    
    WSWeak(weakSelf);
    NSString *fileName = [[MIHelpTool timeStampSecond] stringByAppendingString:@".jpg"];
    [MIRequestManager uploadUserAvatarWithFile:@"file" fileName:fileName avatar:image requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        NSInteger code = [jsonData[@"code"] integerValue];
        if (code == 0) {
            MIUserInfoModel *model = [MILocalData getCurrentLoginUserInfo];
            NSDictionary *data = jsonData[@"data"];
            model.avatar = data[@"avatar"];
            [MILocalData saveCurrentLoginUserInfo:model];
            
            weakSelf.headImageView.image = image;
            [weakSelf.activityIndeView stopAnimating];
        } else {
            [MIToastAlertView showAlertViewWithMessage:@"头像设置失败"];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
