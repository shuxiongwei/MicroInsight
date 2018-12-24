//
//  MIHomeViewController.m
//  MicroInsight
//
//  Created by 舒雄威 on 2018/10/21.
//  Copyright © 2018年 舒雄威. All rights reserved.
//

#import "MIHomeViewController.h"
#import "MIPhotographyViewController.h"
#import "MILoginViewController.h"
#import "MICommunityViewController.h"
#import "MIMyAlbumViewController.h"
#import "MICommunityListModel.h"
#import "UIImageView+WebCache.h"
#import "MIMineViewController.h"
#import "UIButton+WebCache.h"

@interface MIHomeViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@property (weak, nonatomic) IBOutlet UIButton *userBtn;
@property (weak, nonatomic) IBOutlet UIView *albumView;
@property (weak, nonatomic) IBOutlet UIView *communityView;
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UIView *shootView;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;
@property (weak, nonatomic) IBOutlet UIImageView *communityImageView;

@end

@implementation MIHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self configHomeUI];
    [self configGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    MIUserInfoModel *model = [MILocalData getCurrentLoginUserInfo];
    _username.text = model.nickname;
    
    //等比缩放，限定在矩形框外
    NSString *imgUrl = [NSString stringWithFormat:@"%@?x-oss-process=image/resize,m_fill,h_%d,w_%d", model.avatar, 50, 50];
    [_userBtn sd_setImageWithURL:[NSURL URLWithString:imgUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"icon_home_user_nor"] options:SDWebImageRetryFailed];
    
    [self setCommunityBackgroundImage];
    [self setAlbumImageViewWithFirstLocalAssetThumbnail];
}

- (void)configHomeUI {
    
    CGFloat width = (MIScreenWidth - 5 * 3) / 3.0 * 2.0;
    _widthConstraint.constant = width;
    
    _albumView.layer.cornerRadius = 3;
    _albumView.layer.masksToBounds = YES;
    _communityView.layer.cornerRadius = 3;
    _communityView.layer.masksToBounds = YES;
    _loginView.layer.cornerRadius = 3;
    _loginView.layer.masksToBounds = YES;
    _shootView.layer.cornerRadius = 3;
    _shootView.layer.masksToBounds = YES;
    _userBtn.layer.cornerRadius = 25;
    _userBtn.layer.masksToBounds = YES;
}

- (void)configGestureRecognizer {
    UITapGestureRecognizer *albumT = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickAlbumView:)];
    [_albumView addGestureRecognizer:albumT];
    
    UITapGestureRecognizer *communityT = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCommunityView:)];
    [_communityView addGestureRecognizer:communityT];
    
    UITapGestureRecognizer *shootT = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickShootView:)];
    [_shootView addGestureRecognizer:shootT];
    
    UITapGestureRecognizer *loginT = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickLoginView:)];
    [_loginView addGestureRecognizer:loginT];
}

#pragma mark - 手势
//相册
- (void)clickAlbumView:(UITapGestureRecognizer *)rec {
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"MyAlbum" bundle:nil];
    MIMyAlbumViewController *vc = [board instantiateViewControllerWithIdentifier:@"MIMyAlbumViewController"];
    vc.albumType = MIAlbumTypePhoto;
    [self.navigationController pushViewController:vc animated:YES];
}

//社区
- (void)clickCommunityView:(UITapGestureRecognizer *)rec {
    if ([MILocalData hasLogin]) {
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"Community" bundle:nil];
        MICommunityViewController *vc = [board instantiateViewControllerWithIdentifier:@"MICommunityViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        MILoginViewController *vc = [board instantiateViewControllerWithIdentifier:@"MILoginViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//拍摄
- (void)clickShootView:(UITapGestureRecognizer *)rec {
    MIPhotographyViewController *vc = [[MIPhotographyViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

//登录
- (void)clickLoginView:(UITapGestureRecognizer *)rec {
    if ([MILocalData hasLogin]) {
        MIMineViewController *mineVC = [[MIMineViewController alloc] initWithNibName:@"MIMineViewController" bundle:nil];
        [self.navigationController pushViewController:mineVC animated:YES];
    } else {
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        MILoginViewController *vc = [board instantiateViewControllerWithIdentifier:@"MILoginViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - helper
- (void)setAlbumImageViewWithFirstLocalAssetThumbnail {
    
    NSString *path = [MILocalData getFirstLocalAssetPath];
    if (path == nil) {
        _albumImageView.image = [UIImage imageNamed:@"home_btn_album"];
    } else {
        UIImage *image;
        
        if ([path.pathExtension isEqualToString:@"png"]) {
            image = [UIImage imageWithContentsOfFile:path];
        } else {
            AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:path]];
            image = [MIHelpTool fetchThumbnailWithAVAsset:asset curTime:0];
        }
        
        _albumImageView.image = image;
    }
}

- (void)setCommunityBackgroundImage {
    if ([MILocalData hasLogin]) {
        [self requestFirstNetworkAssetThumbnailComplete:^(BOOL success) {
            
        }];
    } else {
        _communityImageView.image = [UIImage imageNamed:@"home_btn_social"];
    }
}

- (void)requestFirstNetworkAssetThumbnailComplete:(void(^)(BOOL success))completed {
    
    WSWeak(weakSelf);
    [MIRequestManager getCommunityDataListWithSearchTitle:@"" requestToken:[MILocalData getCurrentRequestToken] page:1 pageSize:1 isMine:NO completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        NSInteger code = [jsonData[@"code"] integerValue];
        if (code == 0) {
            NSDictionary *data = jsonData[@"data"];
            NSArray *list = data[@"list"];
            if (list.count > 0) {
                NSDictionary *dic = list.firstObject;
                MICommunityListModel *model = [MICommunityListModel yy_modelWithDictionary:dic];

                NSString *url = [NSString stringWithFormat:@"?x-oss-process=image/resize,m_fill,h_%ld,w_%ld", (NSInteger)weakSelf.communityImageView.size.height / 1, (NSInteger)weakSelf.communityImageView.size.width / 1];
                
                if (model.contentType.integerValue == 0) {
                    [weakSelf.communityImageView sd_setImageWithURL:[NSURL URLWithString:[model.url stringByAppendingString:url]] placeholderImage:nil options:SDWebImageRetryFailed];
                } else {
                    [weakSelf.communityImageView sd_setImageWithURL:[NSURL URLWithString:[model.coverUrl stringByAppendingString:url]] placeholderImage:nil options:SDWebImageRetryFailed];
                }
            } else {
                weakSelf.communityImageView.image = [UIImage imageNamed:@"home_btn_social"];
            }
        } else {
            weakSelf.communityImageView.image = [UIImage imageNamed:@"home_btn_social"];
        }
    }];
}

@end
