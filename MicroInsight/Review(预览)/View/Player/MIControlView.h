//
//  MIControlView.h
//  SBPlayer
//
//  Created by sycf_ios on 2017/4/10.
//  Copyright © 2017年 shibiao. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MIControlView;
@protocol SBControlViewDelegate <NSObject>

@required
/**
 点击UISlider获取点击点

 @param controlView 控制视图
 @param value 当前点击点
 */
- (void)controlView:(MIControlView *)controlView pointSliderLocationWithCurrentValue:(CGFloat)value;

/**
 拖拽UISlider的knob的时间响应代理方法

 @param controlView 控制视图
 @param slider UISlider
 */
- (void)controlView:(MIControlView *)controlView draggedPositionWithSlider:(UISlider *)slider ;

/**
 点击放大按钮的响应事件

 @param controlView 控制视图
 @param fullScreen 是否全屏
 */
- (void)controlView:(MIControlView *)controlView fullScreen:(BOOL)fullScreen;

/**
 点击播放按钮

 @param controlView 控制视图
 @param play 是否播放
 */
- (void)controlView:(MIControlView *)controlView playOrPause:(BOOL)play;

@end

@interface MIControlView : UIView

@property (nonatomic, strong) UIButton *playBtn;
//全屏按钮
@property (nonatomic,strong) UIButton *largeButton;
//进度条当前值
@property (nonatomic,assign) CGFloat value;
//最小值
@property (nonatomic,assign) CGFloat minValue;
//最大值
@property (nonatomic,assign) CGFloat maxValue;
//当前时间
@property (nonatomic,copy) NSString *currentTime;
//总时间
@property (nonatomic,copy) NSString *totalTime;
//缓存条当前值
@property (nonatomic,assign) CGFloat bufferValue;
//UISlider手势
@property (nonatomic,strong) UITapGestureRecognizer *tapGesture;
//代理方法
@property (nonatomic,weak) id<SBControlViewDelegate> delegate;

- (void)refreshConstraintsForSubviews;

@end
