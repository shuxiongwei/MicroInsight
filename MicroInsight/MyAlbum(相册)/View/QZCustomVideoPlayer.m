//
//  QZCustomVideoPlayer.m
//  QZSQ
//
//  Created by 舒雄威 on 2019/5/17.
//  Copyright © 2019 XMZY. All rights reserved.
//

#import "QZCustomVideoPlayer.h"
#import "QZPlayerToolBar.h"

@interface QZCustomVideoPlayer ()

@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) QZPlayerToolBar *toolBar;
@property (nonatomic, strong) id playbackTimeObserver; //界面更新时间ID
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation QZCustomVideoPlayer

- (instancetype)initWithFrame:(CGRect)frame
                     videoUrl:(nullable NSString *)videoUrl {
    return [self initWithFrame:frame videoUrl:videoUrl videoAsset:nil];
}

- (instancetype)initWithFrame:(CGRect)frame
                     videoUrl:(nullable NSString *)videoUrl
                   videoAsset:(nullable AVAsset *)asset {
    return [self initWithFrame:frame videoUrl:videoUrl videoAsset:asset networkVideoUrl:nil];
}

- (instancetype)initWithFrame:(CGRect)frame
                     videoUrl:(nullable NSString *)videoUrl
                   videoAsset:(nullable AVAsset *)asset
              networkVideoUrl:(nullable NSString *)networkVideoUrl {

    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        [self configPlayerWidthVideoUrl:videoUrl videoAsset:asset networkVideoUrl:networkVideoUrl];
        [self configPlayerToolBar];
        [self addVideoKVO];
        [self addVideoTimerObserver];
        [self addVideoNotic];
        [self addRecognizer];
    }
    
    return self;
}

- (void)configPlayerWidthVideoUrl:(NSString *)videoUrl
                       videoAsset:(AVAsset *)asset
                  networkVideoUrl:(NSString *)networkVideoUrl {

    if (![MIHelpTool isBlankString:videoUrl]) {
        self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:videoUrl]];
    } else if (![MIHelpTool isBlankString:networkVideoUrl]) {
        self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:networkVideoUrl]];
    } else {
        self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    }
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.bounds;
    [self.layer addSublayer:self.playerLayer];
    [self.player play];
    
    [self.indicatorView startAnimating];
}

- (void)configPlayerToolBar {
    
    CGFloat y = self.height - 53;
    self.toolBar = [[QZPlayerToolBar alloc] initWithFrame:CGRectMake(0, y, self.width, 53)];
    [self addSubview:self.toolBar];
    
    WSWeak(weakSelf)
    self.toolBar.playOrPauseBlock = ^(BOOL isPause) {
        if (isPause) {
            [weakSelf.player pause];
        } else {
            [weakSelf.player play];
        }
    };
    
    self.toolBar.fullScreenBlock = ^(BOOL isFullScreen) {
        if (weakSelf.fullScreenBlock) {
            weakSelf.fullScreenBlock();
        }
    };
    
    self.toolBar.changeProgressBlock = ^(CGFloat progress) {
        NSTimeInterval totalTime = CMTimeGetSeconds(weakSelf.playerItem.duration);
        CMTime time = CMTimeMake(totalTime * progress, 1);
        [weakSelf.player seekToTime:time];
    };
}

- (void)refreshPlayerToolBarTimeLable:(CGFloat)currentTime {
    NSTimeInterval curTime = currentTime;
    NSTimeInterval totalTime = CMTimeGetSeconds(self.playerItem.duration);
    [self.toolBar refreshTimeLableWithCurrentTime:curTime duration:totalTime];
}

#pragma mark - KVO
- (void)addVideoKVO {
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeVideoKVO {
    [self.playerItem removeObserver:self forKeyPath:@"status"];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context {
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = self.playerItem.status;
        switch (status) {
            case AVPlayerItemStatusReadyToPlay: {
                [self refreshPlayerToolBarTimeLable:CMTimeGetSeconds(self.playerItem.currentTime)];
                [self.indicatorView stopAnimating];
            }
                break;
            case AVPlayerItemStatusUnknown: {
                
            }
                break;
            case AVPlayerItemStatusFailed: {
                
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark - TimerObserver
- (void)addVideoTimerObserver {

    WSWeak(weakSelf)
    self.playbackTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 50) queue:NULL usingBlock:^(CMTime time) {

        [weakSelf refreshPlayerToolBarTimeLable:CMTimeGetSeconds(self.playerItem.currentTime)];
    }];
}

- (void)removeVideoTimerObserver {
    [self.player removeTimeObserver:self.playbackTimeObserver];
    [self setPlaybackTimeObserver:nil];
}

#pragma mark - Notification
- (void)addVideoNotic {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)removeVideoNotic {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

//播放结束
- (void)movieToEnd:(NSNotification *)notic {
    [self refreshPlayerToolBarTimeLable:0];
    [self.toolBar refreshPlayOrPauseButtonStatus:YES];
    
    CMTime time = CMTimeMake(0, 1);
    [_player seekToTime:time];
}

#pragma mark - 前台后台切换
- (void)appWillResignActive:(NSNotification *)aNotification {
    [self setPlayerPlayOrPauseStatus];
}

- (void)appDidBecomActive:(NSNotification *)aNotification {
    
}

#pragma mark - 手势
- (void)addRecognizer {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSelf:)];
    [self addGestureRecognizer:tap];
}

- (void)tapSelf:(UITapGestureRecognizer *)rec {
    self.toolBar.hidden = !self.toolBar.hidden;
    if (self.showOrHideToolBarBlock) {
        self.showOrHideToolBarBlock(self.toolBar.hidden);
    }
}

#pragma mark - 外部方法
- (void)setVideoUrl:(NSString *)videoUrl {
    self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:videoUrl]];
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    [self.player play];
}

- (void)refreshSubviewFrame {
    self.playerLayer.frame = self.bounds;
    
    CGFloat y = self.height - 40;
    if (KIsiPhoneX) {
        y = self.height - 50;
    }
    self.toolBar.frame = CGRectMake(0, y, self.width, 40);
}

- (void)setPlayerPlayOrPauseStatus {
    if ([self.toolBar getPlayOrPuaseButtonStatus]) {
        [self.player pause];
        [self.toolBar refreshPlayOrPauseButtonStatus:YES];
    }
}

- (void)clear {
    [self removeVideoKVO];
    [self removeVideoNotic];
    [self removeVideoTimerObserver];
    [self.player pause];
    [self setPlayerItem:nil];
    [self setPlayer:nil];
    [self setPlayerLayer:nil];
}

#pragma mark - 懒加载
- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _indicatorView.center = self.center;
        [self addSubview:_indicatorView];
        [self bringSubviewToFront:_indicatorView];
    }
    
    return _indicatorView;
}

@end
