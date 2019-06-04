//
//  QZPlayerToolBar.m
//  QZSQ
//
//  Created by 舒雄威 on 2019/5/17.
//  Copyright © 2019 XMZY. All rights reserved.
//

#import "QZPlayerToolBar.h"

@interface QZPlayerToolBar ()

@property (nonatomic, strong) UIButton *playOrPauseBtn; //播放或暂停按钮
@property (nonatomic, strong) UISlider *progressSlider; //进度条
@property (nonatomic, strong) UILabel *timeLab; //时间
@property (nonatomic, strong) UIButton *fullScreenBtn; //全屏按钮
@property (nonatomic, assign) BOOL isSliderDraging; //标识进度条是否正在被拖拽
@property (nonatomic, strong) UILabel *currentTimeLab;
@property (nonatomic, strong) UILabel *totalTimeLab;

@end

@implementation QZPlayerToolBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configUI];
    }
    
    return self;
}

- (void)configUI {
    self.backgroundColor = [UIColor clearColor];
    
    self.playOrPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playOrPauseBtn setImage:[UIImage imageNamed:@"icon_album_pause_nor"] forState:UIControlStateNormal];
    [self.playOrPauseBtn setImage:[UIImage imageNamed:@"icon_album_play_nor"] forState:UIControlStateSelected];
    [self.playOrPauseBtn addTarget:self action:@selector(clickPlayOrPauseBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.playOrPauseBtn];
    [self.playOrPauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.offset(15);
        make.width.height.equalTo(@(23));
    }];
    
    self.currentTimeLab = [[UILabel alloc] init];
    self.currentTimeLab.textColor = [UIColor whiteColor];
    self.currentTimeLab.font = [UIFont systemFontOfSize:10];
    self.currentTimeLab.text = @"00:00";
    self.currentTimeLab.textAlignment = NSTextAlignmentRight;
    [self addSubview:self.currentTimeLab];
    [self.currentTimeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.centerX.equalTo(self.mas_left).offset(72);
    }];
    
    self.progressSlider = [[UISlider alloc] init];
    self.progressSlider.minimumTrackTintColor = UIColorFromRGBWithAlpha(0xFF1617, 1);
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"icon_album_progressCircle_nor"] forState:UIControlStateNormal];
    [self.progressSlider addTarget:self action:@selector(sliderValueChanged:forEvent:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.progressSlider];
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.offset(100);
        make.right.offset(-62);
    }];
    
    self.totalTimeLab = [[UILabel alloc] init];
    self.totalTimeLab.textColor = [UIColor whiteColor];
    self.totalTimeLab.font = [UIFont systemFontOfSize:10];
    self.totalTimeLab.text = @"00:00";
    self.totalTimeLab.textAlignment = NSTextAlignmentRight;
    [self addSubview:self.totalTimeLab];
    [self.totalTimeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.offset(-20);
    }];
}

//实现方法
- (void)sliderValueChanged:(UISlider *)slider forEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    switch (touch.phase) {
        case UITouchPhaseBegan:
            self.isSliderDraging = YES;
            break;
        case UITouchPhaseMoved:
            self.isSliderDraging = YES;
            if (self.changeProgressBlock) {
                self.changeProgressBlock(slider.value);
            }
            break;
        case UITouchPhaseEnded:
            self.isSliderDraging = NO;
            break;
        case UITouchPhaseCancelled:
            self.isSliderDraging = NO;
            break;
        default:
            break;
    }
}

#pragma mark - 事件响应
- (void)clickPlayOrPauseBtn:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.playOrPauseBlock) {
        self.playOrPauseBlock(sender.selected);
    }
}

#pragma mark - 外部方法
- (void)refreshTimeLableWithCurrentTime:(NSTimeInterval)currentTime
                               duration:(NSTimeInterval)duration {
    
    self.currentTimeLab.text = [MIHelpTool convertTime:currentTime];
    self.totalTimeLab.text = [MIHelpTool convertTime:duration];
    
    //如果进度条正在拖拽的时候，就不要刷新进度条的值
    if (!self.isSliderDraging) {
        self.progressSlider.value = currentTime / duration;
    }
}

- (void)refreshPlayOrPauseButtonStatus:(BOOL)pause {
    self.playOrPauseBtn.selected = pause;
}

- (BOOL)getPlayOrPuaseButtonStatus {
    return !self.playOrPauseBtn.selected;
}

@end
