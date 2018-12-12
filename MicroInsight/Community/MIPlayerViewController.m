//
//  MIPlayerViewController.m
//  MicroInsight
//
//  Created by Jonphy on 2018/12/12.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "MIPlayerViewController.h"
#import <PLPlayerKit/PLPlayerKit.h>

@interface MIPlayerViewController ()<PLPlayerDelegate>

@property (strong, nonatomic) PLPlayer *player;

@end

@implementation MIPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.player = [PLPlayer playerWithURL:[NSURL URLWithString:_videoURL] option:[PLPlayerOption defaultOption]];
    _player.delegate = self;
     [self.view addSubview:_player.playerView];
    _player.playerView.frame = self.view.bounds;
    [_player play];
    // Do any additional setup after loading the view.
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
