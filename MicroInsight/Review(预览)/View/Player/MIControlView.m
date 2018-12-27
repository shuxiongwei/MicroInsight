//
//  MIControlView.m
//  SBPlayer
//
//  Created by sycf_ios on 2017/4/10.
//  Copyright © 2017年 shibiao. All rights reserved.
//

#import "MIControlView.h"
#import "MISlider.h"
#import "Masonry.h"

@interface MIControlView ()

//当前时间
@property (nonatomic, strong) UILabel *timeLabel;
//总时间
@property (nonatomic, strong) UILabel *totalTimeLabel;
//进度条
@property (nonatomic, strong) MISlider *slider;
//缓存进度条
@property (nonatomic, strong) MISlider *bufferSlier;

@end


@implementation MIControlView

#pragma mark - 懒加载
- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setImage:[UIImage imageNamed:@"btn_play"] forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"btn_pause"] forState:UIControlStateSelected];
        [_playBtn addTarget:self action:@selector(handlePlayBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = [UIColor whiteColor];
    }
    return _timeLabel;
}

- (UILabel *)totalTimeLabel {
    if (!_totalTimeLabel) {
        _totalTimeLabel = [[UILabel alloc] init];
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
        _totalTimeLabel.font = [UIFont systemFontOfSize:12];
        _totalTimeLabel.textColor = [UIColor whiteColor];
    }
    return _totalTimeLabel;
}

- (UISlider *)slider {
    if (!_slider) {
        _slider = [[MISlider alloc] init];
        [_slider setThumbImage:[UIImage imageNamed:@"icon_camera_circle_normal"] forState:UIControlStateNormal];
        _slider.continuous = YES;
        self.tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
        [_slider addTarget:self action:@selector(handleSliderPosition:) forControlEvents:UIControlEventValueChanged];
        [_slider addGestureRecognizer:self.tapGesture];
        _slider.maximumTrackTintColor = [UIColor clearColor];
        _slider.minimumTrackTintColor = [UIColor greenColor];
    }
    return _slider;
}

- (UIButton *)largeButton {
    if (!_largeButton) {
        _largeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _largeButton.contentMode = UIViewContentModeScaleToFill;
        [_largeButton setImage:[UIImage imageNamed:@"full_screen"] forState:UIControlStateNormal];
        [_largeButton addTarget:self action:@selector(hanleLargeBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _largeButton;
}

- (UISlider *)bufferSlier {
    if (!_bufferSlier) {
        _bufferSlier = [[MISlider alloc] init];
        [_bufferSlier setThumbImage:[UIImage new] forState:UIControlStateNormal];
        _bufferSlier.continuous = YES;
        _bufferSlier.minimumTrackTintColor = [UIColor whiteColor];
        _bufferSlier.minimumValue = 0.f;
        _bufferSlier.maximumValue = 1.f;
        _bufferSlier.userInteractionEnabled = NO;
    }
    return _bufferSlier;
}

#pragma mark - UI
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI {
    [self addSubview:self.playBtn];
    [self addSubview:self.timeLabel];
    [self addSubview:self.bufferSlier];
    [self addSubview:self.slider];
    [self addSubview:self.totalTimeLabel];
    [self addSubview:self.largeButton];
    [self refreshConstraintsForSubviews];
}

- (void)refreshConstraintsForSubviews {
    [self.playBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(10);
        make.bottom.mas_equalTo(self).offset(-5);
        make.width.height.mas_equalTo(@30);
        make.centerY.mas_equalTo(@[self.playBtn, self.timeLabel, self.slider, self.totalTimeLabel, self.largeButton]);
    }];
    [self.playBtn setEnlargeEdge:10];
    
    [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.playBtn.mas_right).offset(5);
        make.right.mas_equalTo(self.slider).offset(-5).priorityLow();
        make.width.mas_equalTo(@50);
    }];
    
    [self.slider mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.timeLabel.mas_right).offset(5);
        make.right.mas_equalTo(self.totalTimeLabel.mas_left).offset(-5);
        make.width.mas_equalTo(self.width - 10 - 30 - 5 - 50 - 5 - 5 - 50 - 5 - 30 - 10);
    }];
    
    [self.totalTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.slider.mas_right).offset(5);
        make.right.mas_equalTo(self.largeButton.mas_left);
        make.width.mas_equalTo(@50).priorityHigh();
    }];
    
    [self.largeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.mas_equalTo(self).offset(-10);
        make.left.mas_equalTo(self.totalTimeLabel.mas_right);
        make.width.height.mas_equalTo(@30);
    }];
    [self.largeButton setEnlargeEdge:10];
    
    [self.bufferSlier mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.slider);
    }];
}

#pragma mark - action
- (void)handlePlayBtn:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if ([self.delegate respondsToSelector:@selector(controlView:playOrPause:)]) {
        [self.delegate controlView:self playOrPause:sender.selected];
    }
}

- (void)hanleLargeBtn:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if ([self.delegate respondsToSelector:@selector(controlView:fullScreen:)]) {
        [self.delegate controlView:self fullScreen:sender.selected];
    }
}

- (void)handleSliderPosition:(UISlider *)slider {
    if ([self.delegate respondsToSelector:@selector(controlView:draggedPositionWithSlider:)]) {
        [self.delegate controlView:self draggedPositionWithSlider:self.slider];
    }
}

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:self.slider];
    CGFloat pointX = point.x;
    CGFloat sliderWidth = self.slider.frame.size.width;
    CGFloat currentValue = pointX/sliderWidth * self.slider.maximumValue;
    if ([self.delegate respondsToSelector:@selector(controlView:pointSliderLocationWithCurrentValue:)]) {
        [self.delegate controlView:self pointSliderLocationWithCurrentValue:currentValue];
    }
}

#pragma mark - setter 和 getter方法
- (void)setValue:(CGFloat)value {
    self.slider.value = value;
}

- (CGFloat)value {
    return self.slider.value;
}

- (void)setMinValue:(CGFloat)minValue {
    self.slider.minimumValue = minValue;
}

- (CGFloat)minValue {
    return self.slider.minimumValue;
}

- (void)setMaxValue:(CGFloat)maxValue {
    self.slider.maximumValue = maxValue;
}

- (CGFloat)maxValue {
    return self.slider.maximumValue;
}

- (void)setCurrentTime:(NSString *)currentTime {
    self.timeLabel.text = currentTime;
}

- (NSString *)currentTime {
    return self.timeLabel.text;
}

- (void)setTotalTime:(NSString *)totalTime {
    self.totalTimeLabel.text = totalTime;
}

- (NSString *)totalTime {
    return self.totalTimeLabel.text;
}

- (CGFloat)bufferValue {
    return self.bufferSlier.value;
}

- (void)setBufferValue:(CGFloat)bufferValue {
    self.bufferSlier.value = bufferValue;
}

@end
