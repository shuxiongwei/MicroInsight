//
//  MIHomeViewController.m
//  MicroInsight
//
//  Created by 舒雄威 on 2018/10/21.
//  Copyright © 2018年 舒雄威. All rights reserved.
//

#import "MIHomessViewController.h"
#import "MIPhotographyViewController.h"
#import "MILoginsViewController.h"
#import "MICommunityViewController.h"
#import "MIMyAlbumViewController.h"
#import "MIMineViewController.h"
#import "UIViewController+MMDrawerController.h"

static const NSInteger IMAGE_NUMBER = 3;

@interface MIHomessViewController ()

{
    CGFloat scale;
    BOOL isFirst; //判断是否为第一次进入该页面
}

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UILabel *homeLab;
@property (assign, nonatomic) NSInteger currentIndex;
@property (strong, nonatomic) NSTimer *timer; //控制过渡的定时器
@property (strong, nonatomic) NSTimer *time;  //控制放大的定时器

@end

@implementation MIHomessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    _homeLab.font = [UIFont captionFontWithName:@"custom" size:20];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;

    isFirst = YES;
    _currentIndex = 0;
    _bgImageView.image = [UIImage imageNamed:@"img_home_bg_0.jpg"];
    
    [self timeRun];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.timer invalidate];
    self.timer = nil;
    
    [self.time invalidate];
    self.time = nil;
}

#pragma mark - 动画
- (void)timeRun {
    [self transitionAnimation];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(transitionAnimation) userInfo:nil repeats:YES];
}

- (void)transitionAnimation {
    [self.time invalidate];
    self.time = nil;
    
    scale = 1.0;
    
    if (!isFirst) {
        [self transitionAnimationWithType:kCATransitionFade];
    }
    isFirst = NO;
    
    self.time = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(imageViewBlowUp) userInfo:nil repeats:YES];
}

- (void)imageViewBlowUp {
    scale += 0.0008;
    _bgImageView.transform = CGAffineTransformMakeScale(scale, scale);
}

- (void)transitionAnimationWithType:(NSString *)type {
    CATransition *transition = [[CATransition alloc] init];
    transition.type = type;
    transition.duration = 2.0;
    _bgImageView.image = [self transitionImage];
    
    //添加动画效果
    [_bgImageView.layer addAnimation:transition forKey:@"Animation"];
}

- (UIImage *)transitionImage {
    self.currentIndex = (self.currentIndex + 1) % IMAGE_NUMBER;
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"img_home_bg_%ld.jpg",(long)_currentIndex]];
    return image;
}

#pragma mark - 按钮点击事件
//个人中心
- (IBAction)clickUserBtn:(UIButton *)sender {
//    if ([MILocalData hasLogin]) {
//        MIMineViewController *mineVC = [[MIMineViewController alloc] initWithNibName:@"MIMineViewController" bundle:nil];
//        [self.navigationController pushViewController:mineVC animated:YES];
//    } else {
//        UIStoryboard *board = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
//        MILoginViewController *vc = [board instantiateViewControllerWithIdentifier:@"MILoginViewController"];
//        [self.navigationController pushViewController:vc animated:YES];
//    }
    
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

//社区
- (IBAction)clickCommunityBtn:(UIButton *)sender {
    if ([MILocalData hasLogin]) {
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"Community" bundle:nil];
        MICommunityViewController *vc = [board instantiateViewControllerWithIdentifier:@"MICommunityViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        MILoginsViewController *vc = [board instantiateViewControllerWithIdentifier:@"MILoginViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//相机
- (IBAction)clickCameraBtn:(UIButton *)sender {
    MIPhotographyViewController *vc = [[MIPhotographyViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

//相册
- (IBAction)clickAlbumBtn:(UIButton *)sender {
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"MyAlbum" bundle:nil];
    MIMyAlbumViewController *vc = [board instantiateViewControllerWithIdentifier:@"MIMyAlbumViewController"];
    vc.albumType = MIAlbumTypePhoto;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
