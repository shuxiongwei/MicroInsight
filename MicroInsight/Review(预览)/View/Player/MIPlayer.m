//
//  SBView.m
//  SBPlayer
//
//  Created by sycf_ios on 2017/4/10.
//  Copyright © 2017年 shibiao. All rights reserved.
//

#import "MIPlayer.h"


@interface MIPlayer () <SBControlViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong, readonly) AVPlayerLayer *playerLayer;
//底部控制视图
@property (nonatomic, strong) MIControlView *controlView;
//原始约束
@property (nonatomic, strong) NSArray *oldConstriants;
//加载动画
@property (nonatomic, strong) UIActivityIndicatorView *activityIndeView;
@property (nonatomic, strong) UIButton *backBtn;

@end

static NSInteger count = 0;

@implementation MIPlayer

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

//MARK: Get方法和Set方法
- (AVPlayer *)player {
    return self.playerLayer.player;
}

- (void)setPlayer:(AVPlayer *)player {
    self.playerLayer.player = player;
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer;
}

- (CGFloat)rate {
    return self.player.rate;
}

- (void)setRate:(CGFloat)rate {
    self.player.rate = rate;
}

- (void)setMode:(SBLayerVideoGravity)mode {
    switch (mode) {
        case SBLayerVideoGravityResizeAspect:
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            break;
        case SBLayerVideoGravityResizeAspectFill:
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            break;
        case SBLayerVideoGravityResize:
            self.playerLayer.videoGravity = AVLayerVideoGravityResize;
            break;
    }
}

//MARK:实例化
- (instancetype)initWithFrame:(CGRect)frame videoUrl:(NSString *)url {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupPlayerUI];
        [self assetWithURL:url];
    }
    return self;
}

- (void)assetWithURL:(NSString *)url {
    
    NSURL *assetUrl;
    if ([url containsString:@"http"]) {
        assetUrl = [NSURL URLWithString:url];
    } else {
        assetUrl = [NSURL fileURLWithPath:url];
    }
    
    NSDictionary *options = @{ AVURLAssetPreferPreciseDurationAndTimingKey : @YES };
    self.anAsset = [[AVURLAsset alloc] initWithURL:assetUrl options:options];
    NSArray *keys = @[@"duration"];

    [self.anAsset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        NSError *error = nil;
        AVKeyValueStatus tracksStatus = [self.anAsset statusOfValueForKey:@"duration" error:&error];
        switch (tracksStatus) {
            case AVKeyValueStatusLoaded:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!CMTIME_IS_INDEFINITE(self.anAsset.duration)) {
                        CGFloat second = self.anAsset.duration.value / self.anAsset.duration.timescale;
                        self.controlView.totalTime = [self convertTime:second];
                        self.controlView.minValue = 0;
                        self.controlView.maxValue = second;
                    }
                });
            }
                break;
            case AVKeyValueStatusFailed:
            {
                //NSLog(@"AVKeyValueStatusFailed失败,请检查网络,或查看plist中是否添加App Transport Security Settings");
            }
                break;
            case AVKeyValueStatusCancelled:
            {
                NSLog(@"AVKeyValueStatusCancelled取消");
            }
                break;
            case AVKeyValueStatusUnknown:
            {
                NSLog(@"AVKeyValueStatusUnknown未知");
            }
                break;
            case AVKeyValueStatusLoading:
            {
                NSLog(@"AVKeyValueStatusLoading正在加载");
            }
                break;
        }
    }];
    
    [self setupPlayerWithAsset:self.anAsset];
}

- (instancetype)initWithAsset:(AVURLAsset *)asset {
    self = [super init];
    if (self) {
        [self setupPlayerUI];
        [self setupPlayerWithAsset:asset];
    }
    return self;
}

- (void)setupPlayerWithAsset:(AVURLAsset *)asset {
    self.item = [[AVPlayerItem alloc]initWithAsset:asset];
    self.player = [[AVPlayer alloc]initWithPlayerItem:self.item];
    [self.playerLayer displayIfNeeded];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self addPeriodicTimeObserver];
    
    //添加KVO
    [self addKVO];
    //添加消息中心
    [self addNotificationCenter];
}

//FIXME: Tracking time,跟踪时间的改变
- (void)addPeriodicTimeObserver {
    __weak typeof(self) weakSelf = self;
    playbackTimerObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.f, 1.f) queue:NULL usingBlock:^(CMTime time) {
        weakSelf.controlView.value = weakSelf.item.currentTime.value / (weakSelf.item.currentTime.timescale * 1.0);
        if (!CMTIME_IS_INDEFINITE(self.anAsset.duration)) {
            weakSelf.controlView.currentTime = [weakSelf convertTime:weakSelf.controlView.value];
        }
        if (count >= 5) {
            if (!weakSelf.controlView.hidden) {
                [weakSelf setSubViewsIsHide:YES];
            }
        }
        count += 1;
    }];
}

//TODO: KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus itemStatus = [[change objectForKey:NSKeyValueChangeNewKey]integerValue];
        
        switch (itemStatus) {
            case AVPlayerItemStatusUnknown:
            {
                _status = SBPlayerStatusUnknown;
                NSLog(@"AVPlayerItemStatusUnknown");
            }
                break;
            case AVPlayerItemStatusReadyToPlay:
            {
                _status = SBPlayerStatusReadyToPlay;
                NSLog(@"AVPlayerItemStatusReadyToPlay");
            }
                break;
            case AVPlayerItemStatusFailed:
            {
                _status = SBPlayerStatusFailed;
                NSLog(@"AVPlayerItemStatusFailed");
            }
                break;
            default:
                break;
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {  //监听播放器的下载进度
        NSArray *loadedTimeRanges = [self.item loadedTimeRanges];
        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval timeInterval = startSeconds + durationSeconds;// 计算缓冲总进度
        CMTime duration = self.item.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        //缓存值
        self.controlView.bufferValue = timeInterval / totalDuration;
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) { //监听播放器在缓冲数据的状态
        _status = SBPlayerStatusBuffering;
        if (!self.activityIndeView.isAnimating) {
            [self.activityIndeView startAnimating];
        }
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        NSLog(@"缓冲达到可播放");
        [self.activityIndeView stopAnimating];
    } else if ([keyPath isEqualToString:@"rate"]) { //当rate==0时为暂停,rate==1时为播放,当rate等于负数时为回放
        if ([[change objectForKey:NSKeyValueChangeNewKey]integerValue] == 0) {
            _isPlaying = false;
            _status = SBPlayerStatusPlaying;
        } else {
            _isPlaying = true;
            _status = SBPlayerStatusStopped;
        }
    }
}

//添加KVO
- (void)addKVO {
    //监听状态属性
    [self.item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监听网络加载情况属性
    [self.item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    //监听播放的区域缓存是否为空
    [self.item addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    //缓存可以播放的时候调用
    [self.item addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    //监听暂停或者播放中
    [self.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
}

//MARK:添加消息中心
- (void)addNotificationCenter {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(SBPlayerItemDidPlayToEndTimeNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.player currentItem]];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(willResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
}

//MARK: NotificationCenter
- (void)SBPlayerItemDidPlayToEndTimeNotification:(NSNotification *)notification {
    [self.item seekToTime:kCMTimeZero];
    [self setSubViewsIsHide:NO];
    count = 0;
    [self pause];
    self.controlView.playBtn.selected = NO;
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    UIInterfaceOrientation _interfaceOrientation=[[UIApplication sharedApplication]statusBarOrientation];
    switch (_interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        {
            _isFullScreen = YES;
            if (!self.oldConstriants) {
                self.oldConstriants = [self getCurrentVC].view.constraints;
            }
            [self.controlView updateConstraintsIfNeeded];
            //删除UIView animate可以去除横竖屏切换过渡动画
            [UIView animateWithDuration:kTransitionTime delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0. options:UIViewAnimationOptionTransitionCurlUp animations:^{
                [[UIApplication sharedApplication].keyWindow addSubview:self];
                [self mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.mas_equalTo([UIApplication sharedApplication].keyWindow);
                }];
                [self layoutIfNeeded];
            } completion:nil];
        }
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
        case UIInterfaceOrientationPortrait:
        {
            _isFullScreen = NO;
            [[self getCurrentVC].view addSubview:self];
            //删除UIView animate可以去除横竖屏切换过渡动画
            [UIView animateKeyframesWithDuration:kTransitionTime delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
                if (self.oldConstriants) {
                    [[self getCurrentVC].view addConstraints:self.oldConstriants];
                }
                [self layoutIfNeeded];
            } completion:nil];
        }
            break;
        case UIInterfaceOrientationUnknown:
            NSLog(@"UIInterfaceOrientationUnknown");
            break;
    }
    [[self getCurrentVC].view layoutIfNeeded];
}

- (void)willResignActive:(NSNotification *)notification {
    if (_isPlaying) {
        [self setSubViewsIsHide:NO];
        count = 0;
        [self pause];
        self.controlView.playBtn.selected = NO;
    }
}

//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC {
    UIViewController *result = nil;
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        result = nextResponder;
    } else {
        result = window.rootViewController;
    }
    return result;
}

//MARK: 设置界面 在此方法下面可以添加自定义视图，和删除视图
- (void)setupPlayerUI {
    [self.activityIndeView startAnimating];
    [self addGestureEvent];
    [self addLoadingView];
    [self addBackBtn];
    [self initTimeLabels];
}

//初始化时间
- (void)initTimeLabels {
    self.controlView.currentTime = @"00:00";
    self.controlView.totalTime = @"00:00";
}

//添加加载视图
- (void)addLoadingView {
    [self addSubview:self.activityIndeView];
    [self.activityIndeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(@80);
        make.center.mas_equalTo(self);
    }];
}

- (void)addBackBtn {
    if (!_backBtn) {
        [self addSubview:self.backBtn];
    }
    [self.backBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(10);
        make.top.mas_equalTo(self).offset(10);
        make.width.height.mas_equalTo(@30);
    }];
    [self.backBtn setEnlargeEdge:10];
}

//添加点击事件
- (void)addGestureEvent {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapAction:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
}

- (void)handleTapAction:(UITapGestureRecognizer *)gesture {
    self.controlView.hidden = !self.controlView.hidden;
    count = 0;
}

//懒加载ActivityIndicateView
- (UIActivityIndicatorView *)activityIndeView {
    if (!_activityIndeView) {
        _activityIndeView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndeView.hidesWhenStopped = YES;
    }
    return _activityIndeView;
}

//懒加载控制视图
- (MIControlView *)controlView {
    if (!_controlView) {
        _controlView = [[MIControlView alloc] initWithFrame:CGRectMake(0, self.height - 44, MIScreenWidth, 44)];
        _controlView.delegate = self;
        _controlView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:_controlView];
    }
    return _controlView;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:@"icon_review_close_nor"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

//设置子视图是否隐藏
- (void)setSubViewsIsHide:(BOOL)isHide {
    self.controlView.hidden = isHide;
}

- (void)goBack:(UIButton *)sender {
    if (_goBack) {
        _goBack();
    }
}

//MARK: SBControlViewDelegate
- (void)controlView:(MIControlView *)controlView pointSliderLocationWithCurrentValue:(CGFloat)value {
    count = 0;
    CMTime pointTime = CMTimeMake(value * self.item.currentTime.timescale, self.item.currentTime.timescale);
    [self.item seekToTime:pointTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)controlView:(MIControlView *)controlView draggedPositionWithSlider:(UISlider *)slider {
    count = 0;
    CMTime pointTime = CMTimeMake(controlView.value * self.item.currentTime.timescale, self.item.currentTime.timescale);
    [self.item seekToTime:pointTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)controlView:(MIControlView *)controlView fullScreen:(BOOL)fullScreen {
    count = 0;

    [UIView animateWithDuration:kTransitionTime delay:0 usingSpringWithDamping:0 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCurlUp animations:^{
        if (fullScreen) {
            self.transform = CGAffineTransformMakeRotation(M_PI_2);
            self.frame = CGRectMake(0, 0, MIScreenWidth, MIScreenHeight);
            self.controlView.frame = CGRectMake(0, self.width - 44, self.height, 44);
        } else {
            self.transform = CGAffineTransformIdentity;
            self.frame = CGRectMake(0, 0, MIScreenWidth, MIScreenWidth * 9.0 / 16.0);
            self.controlView.frame = CGRectMake(0, self.height - 44, self.width, 44);
        }
        [self addBackBtn];
        [self.controlView refreshConstraintsForSubviews];
        
    } completion:nil];
}

- (void)controlView:(MIControlView *)controlView playOrPause:(BOOL)play {
    count = 0;
    if (play) {
        [self play];
    } else {
        [self pause];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[MIControlView class]]) {
        return NO;
    }
    return YES;
}

//将数值转换成时间
- (NSString *)convertTime:(CGFloat)second {
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:d];
    return showtimeNew;
}

- (void)play {
    if (self.player) {
        [self.player play];
    }
}

- (void)pause {
    if (self.player) {
        [self.player pause];
    }
}

- (void)stop {
    [self.item removeObserver:self forKeyPath:@"status"];
    [self.player removeTimeObserver:playbackTimerObserver];
    [self.item removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.item removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.item removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [self.player removeObserver:self forKeyPath:@"rate"];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[self.player currentItem]];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    if (self.player) {
        [self pause];
        self.anAsset = nil;
        self.item = nil;
        self.controlView.value = 0;
        self.controlView.currentTime = @"00:00";
        self.controlView.totalTime = @"00:00";
        self.player = nil;
        self.activityIndeView = nil;
        [self removeFromSuperview];
    }
}

@end
