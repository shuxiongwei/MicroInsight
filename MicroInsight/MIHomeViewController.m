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

@interface MIHomeViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@property (weak, nonatomic) IBOutlet UIButton *userBtn;
@property (weak, nonatomic) IBOutlet UIView *albumView;
@property (weak, nonatomic) IBOutlet UIView *communityView;
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UIView *shootView;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;

@end

@implementation MIHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self configHomeUI];
    [self configGestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSString *username = [MILocalData getCurrentLoginUsername];
    if (![MIHelpTool isBlankString:username]) {
        _username.text = username;
    }
    
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
    NSString *username = [MILocalData getCurrentLoginUsername];
    if (![MIHelpTool isBlankString:username]) {
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
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    MILoginViewController *vc = [board instantiateViewControllerWithIdentifier:@"MILoginViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - helper
- (void)setAlbumImageViewWithFirstLocalAssetThumbnail {

    NSString *assetsPath = [MIHelpTool assetsPath];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:assetsPath]) {
        NSArray *contentOfFolder = [fm contentsOfDirectoryAtPath:assetsPath error:nil];
        if (contentOfFolder.count > 0) {
            NSMutableArray *paths = [NSMutableArray arrayWithArray:contentOfFolder];
            [paths sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                return [obj2 compare:obj1];
            }];
            
            UIImage *image;
            NSString *path = paths.firstObject;
            NSString *fullPath = [assetsPath stringByAppendingPathComponent:path];
            if ([path.pathExtension isEqualToString:@"png"]) {
                image = [UIImage imageWithContentsOfFile:fullPath];
            } else {
                AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:fullPath]];
                image = [MIHelpTool fetchThumbnailWithAVAsset:asset curTime:0];
            }
            
            _albumImageView.image = image;
        } else {
            _albumImageView.image = [UIImage imageNamed:@"home_btn_album"];
        }
    }
}

@end
