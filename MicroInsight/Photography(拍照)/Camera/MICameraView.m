//
//  MICameraView.m
//  MicroInsight
//
//  Created by 佰道聚合 on 2017/7/5.
//  Copyright © 2017年 cyd. All rights reserved.
//

#import "MICameraView.h"
#import "MIDemarcateAlertView.h"


typedef NS_ENUM(NSInteger, MIDemarcateType) {
    MIDemarcateCancel,
    MIDemarcateSave,
    MIDemarcateReset,
};

@interface MICameraView() <UIGestureRecognizerDelegate>

{
    CGFloat lastScale;
    CGFloat minScale;
    CGFloat maxScale;
}

@property (nonatomic, strong) MIVideoPreview *previewView;
@property (nonatomic, strong) UIView *focusView;    // 聚焦动画view
@property (nonatomic, strong) UIView *exposureView; // 曝光动画view
@property (nonatomic, strong) UIButton *torchBtn;
@property (nonatomic, strong) UIButton *photoBtn;
@property (nonatomic, strong) UIButton *videoBtn;
@property (nonatomic, strong) UIButton *shootBtn;
@property (nonatomic, strong) UIButton *coverBtn;
@property (nonatomic, strong) UILabel *recordTitle;
@property (nonatomic, strong) NSTimer *recordTimer;
@property (nonatomic, assign) NSInteger recordSecond;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIView *bottomV;
@property (nonatomic, strong) UILabel *curFactorLab;
@property (nonatomic, strong) UIView *rulerView;

@property (nonatomic, strong) UISlider *focalSliderView; //变焦条
@property (nonatomic, strong) UIImageView *reduceV;
@property (nonatomic, strong) UIImageView *addV;
@property (nonatomic, strong) UIButton *rulerBtn;
@property (nonatomic, strong) UILabel *unitLab;
@property (nonatomic, strong) UILabel *totalLab;
@property (nonatomic, strong) UIImageView *rulerBgView;

/* 相机标定相关 */
@property (nonatomic, assign) BOOL isDemarcating; //相机标定中
@property (nonatomic, strong) UIView *startV; //标定的起点
@property (nonatomic, strong) UIView *endV; //标定的终点
@property (nonatomic, strong) CAShapeLayer *demarcateLayer;
@property (nonatomic, strong) UIView *demarcateSaveView;

@end

@implementation MICameraView

#pragma mark - 懒加载
- (UILabel *)recordTitle {
    if (_recordTitle == nil) {
        _recordTitle = [MIUIFactory createLabelWithCenter:CGPointMake(self.centerX, self.height - 116) withBounds:CGRectMake(0, 0, 100, 12) withText:@"00:00" withFont:12 withTextColor:UIColorFromRGBWithAlpha(0xFF1617, 1) withTextAlignment:NSTextAlignmentCenter];
        _recordTitle.hidden = YES;
        [self addSubview:_recordTitle];
    }
    
    return _recordTitle;
}

- (UIView *)focusView {
    if (_focusView == nil) {
        _focusView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 150, 150.0f)];
        _focusView.backgroundColor = [UIColor clearColor];
        _focusView.layer.borderColor = [UIColor yellowColor].CGColor;
        _focusView.layer.borderWidth = 1.0f;
        _focusView.hidden = YES;
    }
    return _focusView;
}

- (UIView *)exposureView {
    if (_exposureView == nil) {
        _exposureView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 150, 150.0f)];
        _exposureView.backgroundColor = [UIColor clearColor];
        _exposureView.layer.borderColor = [UIColor orangeColor].CGColor;
        _exposureView.layer.borderWidth = 1.0f;
        _exposureView.hidden = YES;
    }
    return _exposureView;
}

- (NSTimer *)recordTimer {
    if (!_recordTimer) {
        _recordTimer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(recordDurationOfVideo:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_recordTimer forMode:NSRunLoopCommonModes];
    }
    return _recordTimer;
}

- (UIView *)demarcateSaveView {
    if (!_demarcateSaveView) {
        _demarcateSaveView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 60, self.width, 60)];
        _demarcateSaveView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_demarcateSaveView];
        
        //取消标定
        UIButton *cancelDemarcateBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(30, (_demarcateSaveView.height - 20) / 2.0, 60, 20) normalTitle:[MILocalData appLanguage:@"personal_key_13"] normalTitleColor:UIColorFromRGBWithAlpha(0x333333, 1) highlightedTitleColor:nil selectedColor:nil titleFont:15 normalImage:nil highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(cancelDemarcate:)];
        [_demarcateSaveView addSubview:cancelDemarcateBtn];
        
        //保存标定
        UIButton *saveDemarcateBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(0, (_demarcateSaveView.height - 20) / 2.0, 60, 20) normalTitle:[MILocalData appLanguage:@"personal_key_9"] normalTitleColor:UIColorFromRGBWithAlpha(0x333333, 1) highlightedTitleColor:nil selectedColor:nil titleFont:15 normalImage:nil highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(saveDemarcate:)];
        saveDemarcateBtn.centerX = self.previewView.centerX;
        [_demarcateSaveView addSubview:saveDemarcateBtn];
        
        //重新标定
        UIButton *resetDemarcateBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(_demarcateSaveView.width - 30 - 60, (_demarcateSaveView.height - 20) / 2.0, 60, 20) normalTitle:[MILocalData appLanguage:@"camera_key_1"] normalTitleColor:UIColorFromRGBWithAlpha(0x333333, 1) highlightedTitleColor:nil selectedColor:nil titleFont:15 normalImage:nil highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(resetDemarcate:)];
        [_demarcateSaveView addSubview:resetDemarcateBtn];
    }
    
    return _demarcateSaveView;
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _type = 0;
        [self setupUI];
        [self registerNotification];
    }
    
    return self;
}

#pragma mark - 配置UI
- (void)setupUI {
    lastScale = 1.0;
    minScale = 1.0;
    maxScale = 10.0;
    
    self.previewView = [[MIVideoPreview alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
    doubleTap.numberOfTapsRequired = 2;
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] init];
    pinch.delegate = self;
    [pinch addTarget:self action:@selector(pinchTouch:)];
    [self.previewView addGestureRecognizer:pinch];
    [self.previewView addGestureRecognizer:tap];
    [self.previewView addGestureRecognizer:doubleTap];
    [tap requireGestureRecognizerToFail:doubleTap];
    
    [self addSubview:self.previewView];
    [self.previewView addSubview:self.focusView];
    [self.previewView addSubview:self.exposureView];
    
    [self configFocalSliderUI];
    [self configRulerUI];
    [self configTopViewUI];
    [self configMiddleUI];
    [self configBottomUI];
}

//配置顶部视图
- (void)configTopViewUI {
//    UILabel *appLab = [MIUIFactory createLabelWithCenter:CGPointMake(self.centerX, 25) withBounds:CGRectMake(0, 0, self.width, 50) withText:@"TipScope" withFont:20 withTextColor:[UIColor whiteColor] withTextAlignment:NSTextAlignmentCenter];
//    appLab.font = [UIFont captionFontWithName:@"custom" size:20];
//    [self addSubview:appLab];
    
    UIImageView *appIcon = [[UIImageView alloc] initWithFrame:CGRectMake(self.width - 63 - 15, 22, 63, 11)];
    appIcon.image = [UIImage imageNamed:@"img_camera_logo_nor"];
    [self addSubview:appIcon];
    
    _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _backBtn.bounds = CGRectMake(0, 0, 20, 20);
    _backBtn.center = CGPointMake(30, 30);
    [_backBtn setEnlargeEdge:15];
    [_backBtn setImage:[UIImage imageNamed:@"icon_review_close_nor"] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_backBtn];
}

//配置中间视图
- (void)configMiddleUI {

    //手电筒
    _torchBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(self.width - 30 - 18, self.height - 110 - 175, 30, 30) normalTitle:nil normalTitleColor:nil highlightedTitleColor:nil selectedColor:nil titleFont:0 normalImage:[UIImage imageNamed:@"icon_camera_flash_sel"] highlightedImage:nil selectedImage:[UIImage imageNamed:@"icon_camera_flash_nor"] touchUpInSideTarget:self action:@selector(torchClick:)];
    [self addSubview:_torchBtn];
    
    //刻度尺
    _rulerBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(self.width - 30 - 18, self.height - 110 - 130, 30, 30) normalTitle:nil normalTitleColor:nil highlightedTitleColor:nil selectedColor:nil titleFont:0 normalImage:[UIImage imageNamed:@"icon_camera_rule_sel"] highlightedImage:nil selectedImage:[UIImage imageNamed:@"icon_camera_rule_nor"] touchUpInSideTarget:self action:@selector(clickRulerBtn:)];
    [self addSubview:_rulerBtn];
}

//配置底部视图
- (void)configBottomUI {
    
    _bottomV = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 110, self.width, 110)];
    _bottomV.backgroundColor = [UIColor clearColor];
    [self addSubview:_bottomV];

    //拍视频按钮
    _videoBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(0, 0, 70, 70) normalTitle:nil normalTitleColor:nil highlightedTitleColor:nil selectedColor:nil titleFont:0 normalImage:[UIImage imageNamed:@"icon_camera_video_nor"] highlightedImage:nil selectedImage:[UIImage imageNamed:@"icon_camera_video_sel"] touchUpInSideTarget:self action:@selector(recordVideo:)];
    _videoBtn.center = CGPointMake(_bottomV.centerX, 55);
    _videoBtn.hidden = YES;
    [_bottomV addSubview:_videoBtn];
    
    //拍照片按钮
    _photoBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(0, 0, 70, 70) normalTitle:nil normalTitleColor:nil highlightedTitleColor:nil selectedColor:nil titleFont:0 normalImage:[UIImage imageNamed:@"icon_camera_shoot_nor"] highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(takePhoto:)];
    _photoBtn.center = CGPointMake(_bottomV.centerX, 55);
    [_bottomV addSubview:_photoBtn];
    
    //缩略图
    _coverBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(0, 0, 40, 32) normalTitle:nil normalTitleColor:nil highlightedTitleColor:nil selectedColor:nil titleFont:0 normalImage:[UIImage imageNamed:@"icon_camera_photoIcon_nor"] highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(reviewCoverImage:)];
    _coverBtn.center = CGPointMake(50 + 20, 55);
    [_bottomV addSubview:_coverBtn];
    
    //拍照按钮
    _shootBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(0, 0, 44, 30) normalTitle:nil normalTitleColor:nil highlightedTitleColor:nil selectedColor:nil titleFont:0 normalImage:[UIImage imageNamed:@"icon_camera_videoIcon_nor"] highlightedImage:nil selectedImage:[UIImage imageNamed:@"icon_camera_videoIcon_sel"] touchUpInSideTarget:self action:@selector(selectPhotoOrVideo:)];
    _shootBtn.center = CGPointMake(_bottomV.width - 50 - 20, 55);
    _shootBtn.selected = YES;
    [_bottomV addSubview:_shootBtn];
}

//配置变焦条
- (void)configFocalSliderUI {
    
    _reduceV = [[UIImageView alloc] initWithFrame:CGRectMake(25, self.height - 216, 8, 1)];
    _reduceV.image = [UIImage imageNamed:@"icon_shoot_focal_reduce"];
    [self addSubview:_reduceV];
    
    _addV = [[UIImageView alloc] initWithFrame:CGRectMake(25, 129, 8, 8)];
    _addV.image = [UIImage imageNamed:@"icon_shoot_focal_add"];
    [self addSubview:_addV];
    
    _focalSliderView = [[UISlider alloc] initWithFrame:CGRectMake(0, 129 + 8 + 8 - 10 + (self.height - 137 - 217 - 16) / 2.0, self.height - 137 - 217 - 16, 20)];
    _focalSliderView.centerX = _reduceV.centerX;
    CGAffineTransform rotation = CGAffineTransformMakeRotation(-M_PI/2);
    [_focalSliderView setTransform:rotation];
    [_focalSliderView setThumbImage:[UIImage imageNamed:@"icon_camera_circle_normal"] forState:UIControlStateNormal];
    _focalSliderView.minimumTrackTintColor = [UIColor whiteColor];
    _focalSliderView.maximumTrackTintColor = [UIColor whiteColor];
    _focalSliderView.minimumValue = 1;
    _focalSliderView.maximumValue = 10;
    [_focalSliderView addTarget:self action:@selector(changeFocal:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_focalSliderView];
}

//配置刻度尺
- (void)configRulerUI {
    _rulerBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, MIScreenWidth, MIScreenHeight)];
    _rulerBgView.hidden = YES;
    _rulerBgView.backgroundColor = [UIColor clearColor];
    _rulerBgView.userInteractionEnabled = NO;
    [self insertSubview:_rulerBgView belowSubview:_focalSliderView];
    
    _unitLab = [MIUIFactory createLabelWithCenter:CGPointMake(_rulerBgView.centerX, _rulerBgView.height - 81 - 70) withBounds:CGRectMake(0, 0, self.width, 18) withText:@"1 mm" withFont:10 withTextColor:[UIColor whiteColor] withTextAlignment:NSTextAlignmentCenter];
    [_rulerBgView addSubview:_unitLab];
    
    _totalLab = [MIUIFactory createLabelWithCenter:CGPointMake(_rulerBgView.centerX, _rulerBgView.height - 59 - 70) withBounds:CGRectMake(0, 0, self.width, 8) withText:@"total 1 mm" withFont:8 withTextColor:[UIColor whiteColor] withTextAlignment:NSTextAlignmentCenter];
    [_rulerBgView addSubview:_totalLab];
    
    _rulerView = [[UIView alloc] init];
    _rulerView.backgroundColor = [UIColor whiteColor];
    [_rulerBgView addSubview:_rulerView];
    WSWeak(weakSelf);
    [_rulerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.rulerBgView);
        make.top.mas_equalTo(weakSelf.unitLab.mas_bottom).offset(5);
        make.height.mas_equalTo(@1);
        make.width.mas_equalTo(@([MILocalData getCurrentDemarcateInfo] * weakSelf.focalSliderView.value));
    }];
    
    UIView *leftV = [[UIView alloc] init];
    leftV.backgroundColor = [UIColor whiteColor];
    [_rulerView addSubview:leftV];
    [leftV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.rulerView).offset(0);
        make.bottom.mas_equalTo(weakSelf.rulerView.mas_top).offset(0);
        make.height.mas_equalTo(@3);
        make.width.mas_equalTo(@1);
    }];

    UIView *rightV = [[UIView alloc] init];
    rightV.backgroundColor = [UIColor whiteColor];
    [_rulerView addSubview:rightV];
    [rightV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.rulerView).offset(0);
        make.bottom.mas_equalTo(weakSelf.rulerView.mas_top).offset(0);
        make.height.mas_equalTo(@3);
        make.width.mas_equalTo(@1);
    }];
    
    [self drawDividingLine];
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)appDidEnterBackground {
    _torchBtn.selected = NO;
}

#pragma mark - 事件响应
- (void)goBack:(UIButton *)sender {
    if (!self.recordTitle.hidden) {
        WSWeak(weakSelf)
        [MICustomAlertView showAlertViewWithFrame:MIScreenBounds alertTitle:[MILocalData appLanguage:@"personal_key_11"] alertMessage:[MILocalData appLanguage:@"other_key_18"] leftAction:^(void) {
            
        } rightAction:^(void) {
            if ([weakSelf.delegate respondsToSelector:@selector(goBackAction:)]) {
                [weakSelf.delegate goBackAction:weakSelf];
            }
        }];
    } else {
        if ([_delegate respondsToSelector:@selector(goBackAction:)]) {
            [_delegate goBackAction:self];
        }
    }
}

- (void)clickRulerBtn:(UIButton *)sender {

    if (!_rulerBgView.hidden) {
        _rulerBgView.hidden = YES;
        sender.selected = !sender.selected;
    } else {
        WSWeak(weakSelf);
        CGFloat length = [MILocalData getCurrentDemarcateInfo];
        //还未进行相机标定
        if (length == 0) {
            NSString *message = [NSString stringWithFormat:@"%@\n%@\n%@", [MILocalData appLanguage:@"help_key_15"], [MILocalData appLanguage:@"help_key_16"], [MILocalData appLanguage:@"help_key_17"]];
            [MIDemarcateAlertView showAlertViewWithFrame:MIScreenBounds alertTitle:[MILocalData appLanguage:@"help_key_3"] alertMessage:message leftTitle:[MILocalData appLanguage:@"personal_key_13"] rightTitle:[MILocalData appLanguage:@"login_key_16"] leftAction:^(BOOL alert) {
                
            } rightAction:^(BOOL alert) {
                if (alert) {
                    [weakSelf executeCameraDemarcate:MIDemarcateReset];
                }
            }];
        } else {
            [MIDemarcateAlertView showAlertViewWithFrame:MIScreenBounds alertTitle:[MILocalData appLanguage:@"personal_key_11"] alertMessage:[MILocalData appLanguage:@"camera_key_2"] leftTitle:[MILocalData appLanguage:@"camera_key_3"] rightTitle:[MILocalData appLanguage:@"camera_key_4"] leftAction:^(BOOL alert) {
                
                if (alert) {
                    NSString *message = [NSString stringWithFormat:@"%@\n%@\n%@", [MILocalData appLanguage:@"help_key_15"], [MILocalData appLanguage:@"help_key_16"], [MILocalData appLanguage:@"help_key_17"]];
                    [MIDemarcateAlertView showAlertViewWithFrame:MIScreenBounds alertTitle:[MILocalData appLanguage:@"help_key_3"] alertMessage:message leftTitle:[MILocalData appLanguage:@"personal_key_13"] rightTitle:[MILocalData appLanguage:@"login_key_16"] leftAction:^(BOOL alert) {
                        
                    } rightAction:^(BOOL alert) {
                        if (alert) {
                            [weakSelf executeCameraDemarcate:MIDemarcateReset];
                        }
                    }];
                }
            } rightAction:^(BOOL alert) {
                
                if (!alert) {
                    weakSelf.rulerBgView.hidden = NO;
                    sender.selected = !sender.selected;
                }
            }];
        }
    }
}

- (void)pinchTouch:(UIPinchGestureRecognizer *)ges {
    if (_isDemarcating) {
        return;
    }
    
    if (lastScale > maxScale || lastScale < minScale) {
        return;
    }
    
    //视频拍摄中
    if (_rulerBtn.hidden && _torchBtn.hidden) {
        return;
    }

    lastScale *= ges.scale;
    ges.scale = 1.0;
    lastScale = MIN(lastScale, 10);
    lastScale = MAX(1, lastScale);
    
    _focalSliderView.value = lastScale;
    
    if ([self.delegate respondsToSelector:@selector(setDeviceZoomFactor:zoomFactor:)]) {
        [self.delegate setDeviceZoomFactor:self zoomFactor:lastScale];
    }
    
    [_rulerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(@([MILocalData getCurrentDemarcateInfo] * self->lastScale));
    }];
    [self drawDividingLine];
}

//聚焦
- (void)tapAction:(UIGestureRecognizer *)tap {

    if (_isDemarcating) {
        if (_startV && _endV) {
            return;
        }
        
        CGPoint point = [tap locationInView:self.previewView];
        
        if (!_startV) {
            _startV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
            _startV.center = point;
            _startV.backgroundColor = [UIColor redColor];
            _startV.layer.cornerRadius = 2.5;
            _startV.layer.masksToBounds = YES;
            [self.previewView addSubview:_startV];
        } else {
            _endV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
            _endV.center = point;
            _endV.backgroundColor = [UIColor redColor];
            _endV.layer.cornerRadius = 2.5;
            _endV.layer.masksToBounds = YES;
            [self.previewView addSubview:_endV];
            
            [self drawDemarcateLine];
        }
    } else {
        if ([_delegate respondsToSelector:@selector(focusAction:point:succ:fail:)]) {
            CGPoint point = [tap locationInView:self.previewView];
            [self runFocusAnimation:self.focusView point:point];
            [_delegate focusAction:self point:[self.previewView captureDevicePointForPoint:point] succ:nil fail:^(NSError *error) {
                [MIToastAlertView showAlertViewWithMessage:error.localizedDescription];
            }];
        }
    }
}

//曝光
- (void)doubleTapAction:(UIGestureRecognizer *)tap {
    if (_isDemarcating) {
        return;
    }
    
    if ([_delegate respondsToSelector:@selector(exposAction:point:succ:fail:)]) {
        CGPoint point = [tap locationInView:self.previewView];
        [self runFocusAnimation:self.exposureView point:point];
        [_delegate exposAction:self point:[self.previewView captureDevicePointForPoint:point] succ:nil fail:^(NSError *error) {
            [MIToastAlertView showAlertViewWithMessage:error.localizedDescription];
        }];
    }
}

//录制视频
- (void)recordVideo:(UIButton *)btn {
    
    self.recordTitle.text = @"00:00";
    btn.selected = !btn.selected;
    if (btn.selected) {
        self.recordTitle.hidden = NO;
        _recordSecond = 0;
        [self.recordTimer fire];
        _torchBtn.hidden = YES;
        _rulerBtn.hidden = YES;
        _focalSliderView.hidden = YES;
        _reduceV.hidden = YES;
        _addV.hidden = YES;
        
        UIImage *waterImage = [self getCurrentWaterImage:YES];
        if ([_delegate respondsToSelector:@selector(startRecordVideoAction:waterImage:)]) {
            [_delegate startRecordVideoAction:self waterImage:waterImage];
        }
    } else {
        self.recordTitle.hidden = YES;
        [_recordTimer invalidate];
        _recordTimer = nil;
        _torchBtn.hidden = NO;
        _rulerBtn.hidden = NO;
        _focalSliderView.hidden = NO;
        _reduceV.hidden = NO;
        _addV.hidden = NO;
        
        if ([_delegate respondsToSelector:@selector(stopRecordVideoAction:waterImage:)]) {
            [_delegate stopRecordVideoAction:self waterImage:nil];
        }
    }
}

//拍照
- (void)takePhoto:(UIButton *)btn {
    UIImage *waterImage = [self getCurrentWaterImage:NO];
    if ([_delegate respondsToSelector:@selector(takePhotoAction:waterImage:)]) {
        [_delegate takePhotoAction:self waterImage:waterImage];
    }
}

- (void)selectPhotoOrVideo:(UIButton *)sender {
    if (!self.recordTitle.hidden) {
        [MIHudView showMsg:[MILocalData appLanguage:@"other_key_19"]];
        return;
    }
    
    sender.selected = !sender.selected;
    _photoBtn.hidden = !sender.selected;
    _videoBtn.hidden = sender.selected;
    _type = (sender.selected ? 0 : 1);
}

//手电筒
- (void)torchClick:(UIButton *)btn {
    if ([_delegate respondsToSelector:@selector(torchLightAction:succ:fail:)]) {
        [_delegate torchLightAction:self succ:^{
            self->_torchBtn.selected = !self->_torchBtn.selected;
        } fail:^(NSError *error) {
            [MIToastAlertView showAlertViewWithMessage:error.localizedDescription];
        }];
    }
}

//预览图片
- (void)reviewCoverImage:(UIButton *)btn {
    if (!self.recordTitle.hidden) {
        [MIHudView showMsg:[MILocalData appLanguage:@"other_key_19"]];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(reviewCoverImageOrVideo:resourceType:)]) {
        [self.delegate reviewCoverImageOrVideo:self resourceType:_type];
    }
}

//对焦
- (void)changeFocal:(UISlider *)slider {
    if ([self.delegate respondsToSelector:@selector(setDeviceZoomFactor:zoomFactor:)]) {
        [self.delegate setDeviceZoomFactor:self zoomFactor:slider.value];
    }
    
    [_rulerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(@([MILocalData getCurrentDemarcateInfo] * slider.value));
    }];
    [self drawDividingLine];
}

//取消标定
- (void)cancelDemarcate:(UIButton *)sender {
    [self executeCameraDemarcate:MIDemarcateCancel];
}

//保存标定
- (void)saveDemarcate:(UIButton *)sender {
    if (!_endV) {
        return;
    }
    
    CGFloat length = sqrt(pow(fabs(_endV.center.x - _startV.center.x), 2) + pow(fabs(_endV.center.y - _startV.center.y), 2)) / _focalSliderView.value;
    [MILocalData saveCurrentDemarcateInfo:length];
    [self drawDividingLine];
    
    _rulerBgView.hidden = NO;
    _rulerBtn.selected = !_rulerBtn.selected;
    
    WSWeak(weakSelf);
    [_rulerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(@([MILocalData getCurrentDemarcateInfo] * weakSelf.focalSliderView.value));
    }];
    
    [self executeCameraDemarcate:MIDemarcateSave];
}

//重新标定
- (void)resetDemarcate:(UIButton *)sender {
    [self executeCameraDemarcate:MIDemarcateReset];
}

#pragma mark - Private methods
//聚焦、曝光动画
- (void)runFocusAnimation:(UIView *)view point:(CGPoint)point {
    view.center = point;
    view.hidden = NO;
    [UIView animateWithDuration:0.15f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        view.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
    } completion:^(BOOL complete) {
        double delayInSeconds = 0.5f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            view.hidden = YES;
            view.transform = CGAffineTransformIdentity;
        });
    }];
}

//自动聚焦、曝光动画
- (void)runResetAnimation {
    self.focusView.center = CGPointMake(self.previewView.width/2, self.previewView.height/2);
    self.exposureView.center = CGPointMake(self.previewView.width/2, self.previewView.height/2);;
    self.exposureView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    self.focusView.hidden = NO;
    self.focusView.hidden = NO;
    [UIView animateWithDuration:0.15f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.focusView.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
        self.exposureView.layer.transform = CATransform3DMakeScale(0.7, 0.7, 1.0);
    } completion:^(BOOL complete) {
        double delayInSeconds = 0.5f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.focusView.hidden = YES;
            self.exposureView.hidden = YES;
            self.focusView.transform = CGAffineTransformIdentity;
            self.exposureView.transform = CGAffineTransformIdentity;
        });
    }];
}

- (void)recordDurationOfVideo:(NSTimer *)sender {
    _recordSecond ++;
    if (_recordSecond > 600) {
        [self recordVideo:_videoBtn];
        [MIToastAlertView showAlertViewWithMessage:[MILocalData appLanguage:@"other_key_20"]];
        return;
    }
    
    NSInteger m = (_recordSecond % 600) / 10;
    NSInteger s = (_recordSecond % 600) % 10;
    NSString *mString = m > 9?[NSString stringWithFormat:@"%ld",(long)m]:[NSString stringWithFormat:@"0%ld",(long)m];
    NSString *sString = s > 9?[NSString stringWithFormat:@"%ld",(long)s]:[NSString stringWithFormat:@"0%ld",(long)s];
    self.recordTitle.text = [NSString stringWithFormat:@"%@:%@", mString, sString];
}

//执行相机标定
- (void)executeCameraDemarcate:(MIDemarcateType)type {
    BOOL execute = (type == MIDemarcateReset ? YES : NO);
    
//    if (execute) {
//        self.previewView.frame = CGRectMake(0, 0, self.width, self.height - 60);
//    } else {
//        self.previewView.frame = CGRectMake(0, 0, self.width, self.height - 110);
//    }
    
    _isDemarcating = execute;
    _backBtn.hidden = execute;
    _torchBtn.hidden = execute;
    _rulerBtn.hidden = execute;
    _bottomV.hidden = execute;
    _focalSliderView.hidden = execute;
    _reduceV.hidden = execute;
    _addV.hidden = execute;
    self.demarcateSaveView.hidden = !execute;
    
    [_startV removeFromSuperview];
    _startV = nil;
    [_endV removeFromSuperview];
    _endV = nil;
    [_demarcateLayer removeFromSuperlayer];
    _demarcateLayer = nil;
}

//绘制刻度线
- (void)drawDividingLine {
    CGFloat length = [MILocalData getCurrentDemarcateInfo] * _focalSliderView.value;
    if (length == 0) {
        return;
    }
    
    NSInteger num = ceil(length / 30.0);
    CGFloat width = length / (num * 1.0);
    
    for (UIView *v in _rulerView.subviews) {
        if (v.tag == 100) {
            [v removeFromSuperview];
        }
    }
    
    for (NSInteger i = 1; i <= num - 1; i++) {
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(i * width, -2, 1, 2)];
        v.backgroundColor = [UIColor whiteColor];
        v.tag = 100;
        [_rulerView addSubview:v];
    }
    
    CGFloat unit = 1 / (num * 1.0);
    _unitLab.text = [NSString stringWithFormat:@"%.2f mm/gird", unit];
}

- (UIImage *)getCurrentWaterImage:(BOOL)isVideo {
    if ([MILocalData getOpenRuleWatermark]) {
        if (_rulerBgView.hidden) {
            return nil;
        } else {
            UIImage *waterImage = [UIImage getImageFromView:_rulerBgView inRect:_rulerBgView.bounds];
            
            if ([_delegate respondsToSelector:@selector(getCurrentVideoOrientation:)]) {
                AVCaptureVideoOrientation orientation = [_delegate getCurrentVideoOrientation:self];
                //横屏,home键在左方
                if (orientation == AVCaptureVideoOrientationLandscapeLeft) {
                    waterImage = [UIImage image:waterImage rotation:UIImageOrientationRight];
                    if (isVideo) {
                        waterImage = nil;
                    }
                }
                
                //横屏,home键在右方
                if (orientation == AVCaptureVideoOrientationLandscapeRight) {
                    waterImage = [UIImage image:waterImage rotation:UIImageOrientationLeft];
                    if (isVideo) {
                        waterImage = nil;
                    }
                }
            }
            
            return waterImage;
        }
    } else {
        return nil;
    }
}

#pragma mark - 绘制标定线段
- (void)drawDemarcateLine {
    CGMutablePathRef dotteShapePath = CGPathCreateMutable();
    _demarcateLayer = [CAShapeLayer layer];
    [_demarcateLayer setStrokeColor:[[UIColor redColor] CGColor]];
    _demarcateLayer.lineWidth = 1.0f ;
    
    //第一个3代表线段的长度，第二个3代表间隙的长度
    NSArray *dotteShapeArr = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:3],[NSNumber numberWithInt:3], nil];
    [_demarcateLayer setLineDashPattern:dotteShapeArr];
    CGPathMoveToPoint(dotteShapePath, NULL, _startV.center.x ,_startV.center.y);
    CGPathAddLineToPoint(dotteShapePath, NULL, _endV.center.x, _endV.center.y);
    [_demarcateLayer setPath:dotteShapePath];
    CGPathRelease(dotteShapePath);
    
    [self.previewView.layer addSublayer:_demarcateLayer];
    [self setAnimationWithShapeLay:_demarcateLayer Time:1];
}

- (void)setAnimationWithShapeLay:(CAShapeLayer *)layer Time:(CGFloat)duration {
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = duration;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    [layer addAnimation:pathAnimation forKey:nil];
}

#pragma mark - public methods
- (void)changeTorch:(BOOL)on {
    _torchBtn.selected = on;
}

- (void)refreshCoverImage:(UIImage *)image {
//    [_coverBtn setImage:image forState:UIControlStateNormal];
}

#pragma mark - invalidate methods
//取消
- (void)cancel:(UIButton *)btn {
    if ([_delegate respondsToSelector:@selector(cancelAction:)]) {
        [_delegate cancelAction:self];
    }
}

//转换前后摄像头
- (void)switchCameraClick:(UIButton *)btn {
    if ([_delegate respondsToSelector:@selector(swicthCameraAction:succ:fail:)]) {
        [_delegate swicthCameraAction:self succ:nil fail:^(NSError *error) {
            [MIToastAlertView showAlertViewWithMessage:error.localizedDescription];
        }];
    }
}

//闪光灯
- (void)flashClick:(UIButton *)btn {
    if ([_delegate respondsToSelector:@selector(flashLightAction:succ:fail:)]) {
        [_delegate flashLightAction:self succ:^{
            //self->_flashBtn.selected = !self->_flashBtn.selected;
            self->_torchBtn.selected = NO;
        } fail:^(NSError *error) {
            [MIToastAlertView showAlertViewWithMessage:error.localizedDescription];
        }];
    }
}

//自动聚焦和曝光
- (void)focusAndExposureClick:(UIButton *)btn {
    if ([_delegate respondsToSelector:@selector(autoFocusAndExposureAction:succ:fail:)]) {
        [_delegate autoFocusAndExposureAction:self succ:^{
//            [MIToastAlertView showAlertViewWithMessage:@"自动聚焦曝光设置成功"];
        } fail:^(NSError *error) {
            [MIToastAlertView showAlertViewWithMessage:error.localizedDescription];
        }];
    }
}

- (void)resetCoverBtnImageWithAssetPath:(NSString *)path {

//    if (path == nil) {
//        [_coverBtn setImage:[UIImage imageNamed:@"home_btn_album"] forState:UIControlStateNormal];
//    } else {
//        UIImage *image;
//
//        if ([path.pathExtension isEqualToString:@"png"]) {
//            image = [UIImage imageWithContentsOfFile:path];
//        } else {
//            AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:path]];
//            image = [MIHelpTool fetchThumbnailWithAVAsset:asset curTime:0];
//        }
//
//        [_coverBtn setImage:image forState:UIControlStateNormal];
//    }
}

- (void)resetFocusSliderValue:(CGFloat)value {
    
}

#pragma mark - UIGestureRecognizerDelegate
//允许多个手势同时操作,默认为NO
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
