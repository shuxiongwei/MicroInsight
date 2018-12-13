//
//  MIPlayerViewController.m
//  MicroInsight
//
//  Created by Jonphy on 2018/12/12.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "MIPlayerViewController.h"
#import <SuperPlayer/SuperPlayer.h>

@interface MIPlayerViewController ()<SuperPlayerDelegate>

@property (strong, nonatomic) SuperPlayerView *playerView;

@end

@implementation MIPlayerViewController

- (void)dealloc{
    
    [_playerView pause];
    _playerView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _playerView = [[SuperPlayerView alloc] init];
    // 设置代理，用于接受事件
    _playerView.delegate = self;
    // 设置父View，_playerView会被自动添加到holderView下面
    _playerView.fatherView = self.view;
    
    SuperPlayerModel *playerModel = [[SuperPlayerModel alloc] init];
    // 设置播放地址，直播、点播都可以
    playerModel.videoURL = _videoURL;
    // 开始播放
    [_playerView playWithModel:playerModel];
    
//    self.player = [PLPlayer playerWithURL:[NSURL URLWithString:_videoURL] option:[PLPlayerOption defaultOption]];
//    _player.delegate = self;
//     [self.view addSubview:_player.playerView];
//    _player.playerView.frame = self.view.bounds;
//    [_player play];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)superPlayerBackAction:(SuperPlayerView *)player{
    
    [self.navigationController popViewControllerAnimated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
