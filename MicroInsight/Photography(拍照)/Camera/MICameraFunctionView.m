//
//  MICameraFunctionView.m
//  MicroInsight
//
//  Created by 舒雄威 on 2018/8/30.
//  Copyright © 2018年 舒雄威. All rights reserved.
//

#import "MICameraFunctionView.h"

typedef NS_ENUM(NSInteger, MIFunctionType) {
    MIFunctionTorch = 100,
    MIFunctionFocal,
    MIFunctionFocus,
    MIFunctionExposure,
    MIFunctionBalance
};

@interface MICameraFunctionView ()

@property (nonatomic, strong) UIView *functionTypeView;
@property (nonatomic, strong) UIView *torchView;
@property (nonatomic, strong) UIView *focalView;
@property (nonatomic, strong) UIView *focusView;
@property (nonatomic, strong) UIView *exposureView;
@property (nonatomic, strong) UIView *balanceView;
@property (nonatomic, strong) UISlider *isoSlider;
@property (nonatomic, strong) UISlider *redSlider;
@property (nonatomic, strong) UISlider *greenSlider;
@property (nonatomic, strong) UISlider *blueSlider;
@property (nonatomic, strong) UISlider *durationSlider;
@property (nonatomic, strong) NSMutableArray *functionHandleViews;
@property (nonatomic, weak) id<MICameraFunctionViewDelegate> delegate;

@end


@implementation MICameraFunctionView

- (instancetype)initWithFrame:(CGRect)frame delegate:(id)delegate {
    
    if (self = [super initWithFrame:frame]) {
        _delegate = delegate;
        [self configFunctionTypeView];
        [self configFunctionHandleViews];
    }
    
    return self;
}

#pragma mark - 配置UI
- (void)configFunctionTypeView {
    
    _functionTypeView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, self.width - 10 * 2, 30)];
    _functionTypeView.backgroundColor = [UIColor clearColor];
    _functionTypeView.layer.borderColor = [UIColor whiteColor].CGColor;
    _functionTypeView.layer.borderWidth = 2;
    _functionTypeView.layer.cornerRadius = 1;
    _functionTypeView.layer.masksToBounds = YES;
    [self addSubview:_functionTypeView];
    
    NSArray *functionList = @[@"照明亮度", @"镜头", @"对焦", @"曝光", @"白平衡"];
    CGFloat wid = (self.bounds.size.width - 10 * 2) / (functionList.count * 1.0);
    for (NSInteger i = 0; i < functionList.count; i++) {
        UIButton *btn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(i * wid, 0, wid, 30) normalTitle:functionList[i] normalTitleColor:[UIColor whiteColor] highlightedTitleColor:nil selectedColor:[UIColor blackColor] titleFont:13 normalImage:nil highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(clickFunctionBtn:)];
        btn.tag = i + 100;
        btn.layer.borderColor = [UIColor whiteColor].CGColor;
        btn.layer.borderWidth = 1;
        [_functionTypeView addSubview:btn];
    }
}

- (void)configFunctionHandleViews {
    _functionHandleViews = [NSMutableArray arrayWithCapacity:0];
    
    _torchView = [self createSliderViewWithFrame:CGRectMake(0, 60, self.width, 20) minValue:0 maxValue:1 action:@selector(changeTorchFactor:) tag:MIFunctionTorch title:@"亮度"];
    _focalView = [self createSliderViewWithFrame:CGRectMake(0, 60, self.width, 20) minValue:1 maxValue:5 action:@selector(changeFocalFactor:) tag:MIFunctionFocal title:@"放大"];
    _focusView = [self createSliderViewWithFrame:CGRectMake(0, 60, self.width, 20) minValue:0 maxValue:1 action:@selector(changeFocusFactor:) tag:MIFunctionFocus title:@"对焦"];
    [_functionHandleViews addObject:_torchView];
    [_functionHandleViews addObject:_focalView];
    [_functionHandleViews addObject:_focusView];
    
    [self configFunctionHandleExposureView];
    [self configFunctionHandleBalanceView];
}

- (UIView *)createSliderViewWithFrame:(CGRect)frame
                             minValue:(CGFloat)min
                             maxValue:(CGFloat)max
                               action:(SEL)action
                                  tag:(MIFunctionType)tag
                                title:(NSString *)title {
    
    UIView *v = [[UIView alloc] initWithFrame:frame];
    v.backgroundColor = [UIColor clearColor];
    v.tag = tag;
    v.hidden = YES;
    [self addSubview:v];
    
    UILabel *torchLab = [MIUIFactory createLabelWithCenter:CGPointMake(30, 10) withBounds:CGRectMake(0, 0, 40, 20) withText:title withFont:13 withTextColor:[UIColor blackColor] withTextAlignment:NSTextAlignmentCenter];
    torchLab.backgroundColor = [UIColor whiteColor];
    torchLab.layer.cornerRadius = 5;
    torchLab.layer.masksToBounds = YES;
    [v addSubview:torchLab];
    
    UISlider *torchSlider = [[UISlider alloc] initWithFrame:CGRectMake(65, 0, v.width - 75, 20)];
    [torchSlider setThumbImage:[UIImage imageNamed:@"icon_camera_circle_normal"] forState:UIControlStateNormal];
    torchSlider.minimumTrackTintColor = [UIColor whiteColor];
    torchSlider.maximumTrackTintColor = [UIColor whiteColor];
    torchSlider.minimumValue = min;
    torchSlider.maximumValue = max;
    [torchSlider addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    [v addSubview:torchSlider];
    
    return v;
}

//配置曝光功能视图
- (void)configFunctionHandleExposureView {
    _exposureView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, self.width, 60)];
    _exposureView.backgroundColor = [UIColor clearColor];
    _exposureView.tag = MIFunctionExposure;
    _exposureView.hidden = YES;
    [self addSubview:_exposureView];
    [_functionHandleViews addObject:_exposureView];
    
    UILabel *durationLab = [MIUIFactory createLabelWithCenter:CGPointMake(30, 10) withBounds:CGRectMake(0, 0, 40, 20) withText:@"快门" withFont:13 withTextColor:[UIColor blackColor] withTextAlignment:NSTextAlignmentCenter];
    durationLab.backgroundColor = [UIColor whiteColor];
    durationLab.layer.cornerRadius = 5;
    durationLab.layer.masksToBounds = YES;
    [_exposureView addSubview:durationLab];

    _durationSlider = [[UISlider alloc] initWithFrame:CGRectMake(65, 0, _exposureView.width - 75, 20)];
    [_durationSlider setThumbImage:[UIImage imageNamed:@"icon_camera_circle_normal"] forState:UIControlStateNormal];
    _durationSlider.minimumTrackTintColor = [UIColor whiteColor];
    _durationSlider.maximumTrackTintColor = [UIColor whiteColor];
    CGPoint durationPoint = [self.delegate getDeviceMinAndMaxExposureDurationFactor:self];
    _durationSlider.minimumValue = durationPoint.x;
    _durationSlider.maximumValue = durationPoint.y;
    [_durationSlider addTarget:self action:@selector(changeExposureDurationAndIsoFactor:) forControlEvents:UIControlEventValueChanged];
    [_exposureView addSubview:_durationSlider];
//
//    UILabel *isoLab = [MIUIFactory createLabelWithCenter:CGPointMake(30, 10) withBounds:CGRectMake(0, 0, 40, 20) withText:@"ISO" withFont:13 withTextColor:[UIColor blackColor] withTextAlignment:NSTextAlignmentCenter];
//    isoLab.backgroundColor = [UIColor whiteColor];
//    isoLab.layer.cornerRadius = 5;
//    isoLab.layer.masksToBounds = YES;
//    [_exposureView addSubview:isoLab];
//
//    _isoSlider = [[UISlider alloc] initWithFrame:CGRectMake(65, 0, _exposureView.width - 75, 20)];
//    [_isoSlider setThumbImage:[UIImage imageNamed:@"icon_camera_circle_normal"] forState:UIControlStateNormal];
//    _isoSlider.minimumTrackTintColor = [UIColor whiteColor];
//    _isoSlider.maximumTrackTintColor = [UIColor whiteColor];
//    CGPoint isoPoint = [self.delegate getDeviceMinAndMaxExposureIsoFactor:self];
//    _isoSlider.minimumValue = isoPoint.x;
//    _isoSlider.maximumValue = isoPoint.y;
//    [_isoSlider addTarget:self action:@selector(changeExposureDurationAndIsoFactor:) forControlEvents:UIControlEventValueChanged];
//    [_exposureView addSubview:_isoSlider];
//
//    UILabel *biasLab = [MIUIFactory createLabelWithCenter:CGPointMake(30, 50) withBounds:CGRectMake(0, 0, 40, 20) withText:@"补偿" withFont:13 withTextColor:[UIColor blackColor] withTextAlignment:NSTextAlignmentCenter];
//    biasLab.backgroundColor = [UIColor whiteColor];
//    biasLab.layer.cornerRadius = 5;
//    biasLab.layer.masksToBounds = YES;
//    [_exposureView addSubview:biasLab];
//
//    UISlider *biasSlider = [[UISlider alloc] initWithFrame:CGRectMake(65, 40, _exposureView.width - 75, 20)];
//    [biasSlider setThumbImage:[UIImage imageNamed:@"icon_camera_circle_normal"] forState:UIControlStateNormal];
//    biasSlider.minimumTrackTintColor = [UIColor whiteColor];
//    biasSlider.maximumTrackTintColor = [UIColor whiteColor];
//    CGPoint biasPoint = [self.delegate getDeviceMinAndMaxExposureBiasFactor:self];
//    biasSlider.minimumValue = biasPoint.x;
//    biasSlider.maximumValue = biasPoint.y;
//    [biasSlider addTarget:self action:@selector(changeExposureBiasFactor:) forControlEvents:UIControlEventValueChanged];
//    [_exposureView addSubview:biasSlider];
}

//配置白平衡功能视图
- (void)configFunctionHandleBalanceView {
    CGFloat max = [self.delegate getDeviceMaxBalanceFactor:self];
    _balanceView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, self.width, 100)];
    _balanceView.backgroundColor = [UIColor clearColor];
    _balanceView.tag = MIFunctionBalance;
    _balanceView.hidden = YES;
    [self addSubview:_balanceView];
    [_functionHandleViews addObject:_balanceView];
    
    UILabel *redLab = [MIUIFactory createLabelWithCenter:CGPointMake(30, 10) withBounds:CGRectMake(0, 0, 40, 20) withText:@"红" withFont:13 withTextColor:[UIColor blackColor] withTextAlignment:NSTextAlignmentCenter];
    redLab.backgroundColor = [UIColor whiteColor];
    redLab.layer.cornerRadius = 5;
    redLab.layer.masksToBounds = YES;
    [_balanceView addSubview:redLab];

    _redSlider = [[UISlider alloc] initWithFrame:CGRectMake(65, 0, _exposureView.width - 75, 20)];
    [_redSlider setThumbImage:[UIImage imageNamed:@"icon_camera_circle_normal"] forState:UIControlStateNormal];
    _redSlider.minimumTrackTintColor = [UIColor whiteColor];
    _redSlider.maximumTrackTintColor = [UIColor whiteColor];
    _redSlider.minimumValue = 1;
    _redSlider.maximumValue = max;
    [_redSlider addTarget:self action:@selector(changeBalanceFactor:) forControlEvents:UIControlEventValueChanged];
    [_balanceView addSubview:_redSlider];

    UILabel *greenLab = [MIUIFactory createLabelWithCenter:CGPointMake(30, 50) withBounds:CGRectMake(0, 0, 40, 20) withText:@"绿" withFont:13 withTextColor:[UIColor blackColor] withTextAlignment:NSTextAlignmentCenter];
    greenLab.backgroundColor = [UIColor whiteColor];
    greenLab.layer.cornerRadius = 5;
    greenLab.layer.masksToBounds = YES;
    [_balanceView addSubview:greenLab];

    _greenSlider = [[UISlider alloc] initWithFrame:CGRectMake(65, 40, _exposureView.width - 75, 20)];
    [_greenSlider setThumbImage:[UIImage imageNamed:@"icon_camera_circle_normal"] forState:UIControlStateNormal];
    _greenSlider.minimumTrackTintColor = [UIColor whiteColor];
    _greenSlider.maximumTrackTintColor = [UIColor whiteColor];
    _greenSlider.minimumValue = 2.0;
    _greenSlider.maximumValue = max;
    [_greenSlider addTarget:self action:@selector(changeBalanceFactor:) forControlEvents:UIControlEventValueChanged];
    [_balanceView addSubview:_greenSlider];
    
    UILabel *blueLab = [MIUIFactory createLabelWithCenter:CGPointMake(30, 90) withBounds:CGRectMake(0, 0, 40, 20) withText:@"蓝" withFont:13 withTextColor:[UIColor blackColor] withTextAlignment:NSTextAlignmentCenter];
    blueLab.backgroundColor = [UIColor whiteColor];
    blueLab.layer.cornerRadius = 2.0;
    blueLab.layer.masksToBounds = YES;
    [_balanceView addSubview:blueLab];
    
    _blueSlider = [[UISlider alloc] initWithFrame:CGRectMake(65, 80, _exposureView.width - 75, 20)];
    [_blueSlider setThumbImage:[UIImage imageNamed:@"icon_camera_circle_normal"] forState:UIControlStateNormal];
    _blueSlider.minimumTrackTintColor = [UIColor whiteColor];
    _blueSlider.maximumTrackTintColor = [UIColor whiteColor];
    _blueSlider.minimumValue = 2.0;
    _blueSlider.maximumValue = max;
    [_blueSlider addTarget:self action:@selector(changeBalanceFactor:) forControlEvents:UIControlEventValueChanged];
    [_balanceView addSubview:_blueSlider];
}

#pragma mark - 事件响应
//点检功能按钮
- (void)clickFunctionBtn:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        sender.backgroundColor = [UIColor whiteColor];
    } else {
        sender.backgroundColor = [UIColor clearColor];
    }
    
    [self setButtonSelecteStateOfFunctionViewSubviews:sender.tag];
    [self showOrHideFuntionHandleViews:sender.tag show:sender.selected];
}

//手电筒
- (void)changeTorchFactor:(UISlider *)slider {
    if (_changeTorchFactor) {
        _changeTorchFactor(slider.value);
    }
}

//调焦
- (void)changeFocalFactor:(UISlider *)slider {
    if (_changeFocalFactor) {
        _changeFocalFactor(slider.value);
    }
}

//对焦
- (void)changeFocusFactor:(UISlider *)slider {
    if (_changeFocusFactor) {
        _changeFocusFactor(slider.value);
    }
}

//曝光时长和感光度
- (void)changeExposureDurationAndIsoFactor:(UISlider *)slider {
    if (_changeExposureDurationAndIsoFactor) {
        _changeExposureDurationAndIsoFactor(_durationSlider.value, _isoSlider.value);
    }
}

//曝光倾斜
- (void)changeExposureBiasFactor:(UISlider *)slider {
    if (_changeExposureBiasFactor) {
        _changeExposureBiasFactor(slider.value);
    }
}

//白平衡
- (void)changeBalanceFactor:(UISlider *)slider {
    if (_changeBalanceFactor) {
        _changeBalanceFactor(_redSlider.value, _greenSlider.value, _blueSlider.value);
    }
}

#pragma mark - 内部方法
//设置功能按钮的选择状态
- (void)setButtonSelecteStateOfFunctionViewSubviews:(MIFunctionType)type {
    for (UIButton *btn in _functionTypeView.subviews) {
        if (btn.tag != type && btn.selected) {
            btn.selected = NO;
            btn.backgroundColor = [UIColor clearColor];
            break;
        }
    }
}

//显示或隐藏功能操作视图
- (void)showOrHideFuntionHandleViews:(MIFunctionType)type show:(BOOL)show {
    if (show) {
        for (UIView *v in _functionHandleViews) {
            if (v.tag == type) {
                v.hidden = NO;
            } else {
                v.hidden = YES;
            }
        }
    } else {
        for (UIView *v in _functionHandleViews) {
            if (v.tag == type) {
                v.hidden = YES;
                break;
            }
        }
    }
}

@end
