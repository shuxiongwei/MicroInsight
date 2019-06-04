//
//  MIPlayerViewController.m
//  MicroInsight
//
//  Created by Jonphy on 2018/12/12.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "MIPlayerViewController.h"
#import "MIPlayer.h"

@interface MIPlayerViewController ()

@property (nonatomic, strong) MIPlayer *player;

@end

@implementation MIPlayerViewController

- (void)dealloc {
    [_player stop];
    [self setPlayer:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];

    _player = [[MIPlayer alloc] initWithFrame:CGRectMake(0, 0, MIScreenWidth, MIScreenWidth * 9.0 / 16.0) videoUrl:_videoURL];
    _player.mode = SBLayerVideoGravityResizeAspect;
    WSWeak(weakSelf);
    _player.goBack = ^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    [self.view addSubview:_player];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
}

@end
