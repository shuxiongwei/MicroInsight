//
//  MICameraView.m
//  MicroInsight
//
//  Created by 佰道聚合 on 2017/7/5.
//  Copyright © 2017年 cyd. All rights reserved.
//

#import "MICameraView.h"
#import "MIHorizontalPickerView.h"
#import "MIHorizontalPickerViewCell.h"
#import "MIHorizontalPickerViewCellItem.h"
#import "MIFactorSlider.h"
#import "MICameraFunctionView.h"

@interface MICameraView() <MIHorizontalPickerViewDelegate, MIHorizontalPickerViewDataSource, MICameraFunctionViewDelegate>

@property(nonatomic, strong) MIVideoPreview *previewView;
@property (nonatomic, strong) UIView *bottomView;   // 下面的bar
@property (nonatomic, strong) UIView *focusView;    // 聚焦动画view
@property (nonatomic, strong) UIView *exposureView; // 曝光动画view
@property (nonatomic, strong) UIButton *torchBtn;
@property (nonatomic, strong) UIButton *photoBtn;
@property (nonatomic, strong) UIButton *videoBtn;
@property (nonatomic, strong) UIButton *coverBtn;
@property (nonatomic, strong) UILabel *recordTitle;
@property (nonatomic, strong) MIHorizontalPickerView *shootTypeMenu; //拍摄类型菜单
@property (nonatomic, strong) NSMutableArray *shootTypeList;
@property (nonatomic, strong) NSTimer *recordTimer;
@property (nonatomic, assign) NSInteger recordSecond;
@property (nonatomic, strong) MIFactorSlider *sliderView; //变焦视图
@property (nonatomic, strong) MIFactorSlider *focusSlider; //对焦视图
@property (nonatomic, strong) UISlider *focusSliderView; //对焦视图
@property (nonatomic, strong) MICameraFunctionView *functionView;

@end

@implementation MICameraView

#pragma mark - 懒加载
- (UILabel *)recordTitle {
    if (_recordTitle == nil) {
        _recordTitle = [MIUIFactory createLabelWithCenter:CGPointMake(self.width - 60, 25) withBounds:CGRectMake(0, 0, 120, 50) withText:@"00:00:00" withFont:15 withTextColor:[UIColor whiteColor] withTextAlignment:NSTextAlignmentCenter];
//        _recordTitle.backgroundColor = UIColorFromRGBWithAlpha(000000, 0.5);
        [self addSubview:_recordTitle];
    }
    
    return _recordTitle;
}

- (UIView *)bottomView {
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 80, self.width, 80)];
//        _bottomView.backgroundColor = UIColorFromRGBWithAlpha(000000, 0.7);
    }
    return _bottomView;
}

- (UIView *)focusView {
    if (_focusView == nil) {
        _focusView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 150, 150.0f)];
        _focusView.backgroundColor = [UIColor clearColor];
        _focusView.layer.borderColor = [UIColor blueColor].CGColor;
        _focusView.layer.borderWidth = 1.0f;
        _focusView.hidden = YES;
    }
    return _focusView;
}

- (UIView *)exposureView {
    if (_exposureView == nil) {
        _exposureView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 150, 150.0f)];
        _exposureView.backgroundColor = [UIColor clearColor];
        _exposureView.layer.borderColor = [UIColor purpleColor].CGColor;
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

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _type = 1;
        [self setupUI];
        [self configTopViewUI];
        [self configShootTypeMenuUI];
//        [self configFactorSliderUI];
//        [self configFocusSliderUI];
        [self registerNotification];
    }
    
    return self;
}

#pragma mark - 配置UI
- (void)setupUI {
    self.previewView = [[MIVideoPreview alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapAction:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.previewView addGestureRecognizer:tap];
    [self.previewView addGestureRecognizer:doubleTap];
    [tap requireGestureRecognizerToFail:doubleTap];
    
    [self addSubview:self.previewView];
    [self addSubview:self.bottomView];
    [self.previewView addSubview:self.focusView];
    [self.previewView addSubview:self.exposureView];
    
    //视频按钮
    _videoBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(0, 0, 66, 66) normalTitle:nil normalTitleColor:nil highlightedTitleColor:nil selectedColor:nil titleFont:0 normalImage:[UIImage imageNamed:@"icon_record_btn_normal"] highlightedImage:nil selectedImage:[UIImage imageNamed:@"icon_stop_record_normal"] touchUpInSideTarget:self action:@selector(recordVideo:)];
    _videoBtn.center = CGPointMake(self.bottomView.centerX, self.bottomView.height / 2.0);
    _videoBtn.hidden = YES;
    [self.bottomView addSubview:_videoBtn];
    
    //拍照按钮
    _photoBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(0, 0, 66, 66) normalTitle:nil normalTitleColor:nil highlightedTitleColor:nil selectedColor:nil titleFont:0 normalImage:[UIImage imageNamed:@"icon_camera_click_normal"] highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(takePhoto:)];
    _photoBtn.center = CGPointMake(self.bottomView.centerX, self.bottomView.height / 2.0);
    [self.bottomView addSubview:_photoBtn];
    
    //手电筒
    _torchBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(self.bottomView.width - 30 - 50 - 54, (self.bottomView.height - 44) / 2.0, 34, 44) normalTitle:nil normalTitleColor:nil highlightedTitleColor:nil selectedColor:nil titleFont:0 normalImage:[UIImage imageNamed:@"btn_shoot_flash_nor"] highlightedImage:nil selectedImage:[UIImage imageNamed:@"btn_shoot_flash_sel"] touchUpInSideTarget:self action:@selector(torchClick:)];
    [self.bottomView addSubview:_torchBtn];
    
    //功能按钮
    UIButton *funcBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(self.bottomView.width - 30 - 50, (self.bottomView.height - 50) / 2.0, 50, 50) normalTitle:nil normalTitleColor:nil highlightedTitleColor:nil selectedColor:nil titleFont:0 normalImage:[UIImage imageNamed:@"btn_shoot_func_nor"] highlightedImage:nil selectedImage:[UIImage imageNamed:@"btn_shoot_func_sel"] touchUpInSideTarget:self action:@selector(clickFunctionBtn:)];
    [self.bottomView addSubview:funcBtn];
    
    _coverBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(30, (self.bottomView.height - 50) / 2.0, 50, 50) normalTitle:nil normalTitleColor:nil highlightedTitleColor:nil selectedColor:nil titleFont:0 normalImage:nil highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(reviewCoverImage:)];
    _coverBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    _coverBtn.layer.cornerRadius = 3;
    _coverBtn.layer.masksToBounds = YES;
    [self.bottomView addSubview:_coverBtn];
}

- (void)configTopViewUI {
    UILabel *appLab = [MIUIFactory createLabelWithCenter:CGPointMake(self.centerX, 25) withBounds:CGRectMake(0, 0, self.width, 50) withText:@"TipScope" withFont:20 withTextColor:[UIColor whiteColor] withTextAlignment:NSTextAlignmentCenter];
    appLab.font = [UIFont captionFontWithName:@"custom" size:20];
    [self addSubview:appLab];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.bounds = CGRectMake(0, 0, 20, 20);
    backBtn.center = CGPointMake(25, 25);
    [backBtn setImage:[UIImage imageNamed:@"icon_review_close_nor"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:backBtn];
}

- (void)configShootTypeMenuUI {
    
    NSArray *list = @[@"照片", @"视频"];
    _shootTypeList = [NSMutableArray arrayWithCapacity:list.count];
    for (NSInteger i = 0; i < list.count; i++) {
        MIHorizontalPickerViewCellItem *item = [[MIHorizontalPickerViewCellItem alloc] init];
        item.title = list[i];
        [_shootTypeList addObject:item];
    }
    
    CGFloat x = 0;
    CGFloat y = self.height - 110;
    CGFloat width = self.width;
    CGFloat height = 30;
    CGRect frame = CGRectMake(x, y, width, height);
    
    _shootTypeMenu = [[MIHorizontalPickerView alloc] initWithFrame:frame capacityOfDisplayCell:6 delegate:self dataSource:self];
//    _shootTypeMenu.backgroundColor = UIColorFromRGBWithAlpha(000000, 0.7);
    _shootTypeMenu.delegate = self;
    _shootTypeMenu.dataSource = self;
    [self addSubview:_shootTypeMenu];
}

- (void)configFactorSliderUI {
    _sliderView = [[MIFactorSlider alloc] initWithFrame:CGRectMake(60, self.height - 160, self.width - 70, 40)];
    _sliderView.maxFactor = 5;
    [self addSubview:_sliderView];
    
    WSWeak(weakSelf);
    _sliderView.sliderBarDidTrack = ^(CGFloat x) {
        if ([weakSelf.delegate respondsToSelector:@selector(setDeviceZoomFactor:zoomFactor:)]) {
            [weakSelf.delegate setDeviceZoomFactor:weakSelf zoomFactor:x + 1];
        }
    };
    
    _sliderView.sliderBarDidEndTrack = ^(CGFloat x) {
        if ([weakSelf.delegate respondsToSelector:@selector(setDeviceZoomFactor:zoomFactor:)]) {
            [weakSelf.delegate setDeviceZoomFactor:weakSelf zoomFactor:x + 1];
        }
    };
    
    UILabel *factorLab = [MIUIFactory createLabelWithCenter:CGPointMake(30, _sliderView.centerY) withBounds:CGRectMake(0, 0, 40, 20) withText:@"放大" withFont:13 withTextColor:[UIColor blackColor] withTextAlignment:NSTextAlignmentCenter];
    factorLab.backgroundColor = [UIColor whiteColor];
    factorLab.layer.cornerRadius = 5;
    factorLab.layer.masksToBounds = YES;
    [self addSubview:factorLab];
}

//- (void)configFocusSliderUI {
//    _focusSlider = [[MIFactorSlider alloc] initWithFrame:CGRectMake(60, self.height - 200, self.width - 70, 40)];
//    _focusSlider.maxFactor = 1;
//    [self addSubview:_focusSlider];
//
//    WSWeak(weakSelf);
//    _focusSlider.sliderBarDidTrack = ^(CGFloat x) {
//        if ([weakSelf.delegate respondsToSelector:@selector(setDeviceFocusFactor:focusFactor:)]) {
//            [weakSelf.delegate setDeviceFocusFactor:weakSelf focusFactor:x];
//        }
//    };
//
//    _focusSlider.sliderBarDidEndTrack = ^(CGFloat x) {
//        if ([weakSelf.delegate respondsToSelector:@selector(setDeviceFocusFactor:focusFactor:)]) {
//            [weakSelf.delegate setDeviceFocusFactor:weakSelf focusFactor:x];
//        }
//    };
//
//    UILabel *focusLab = [MIUIFactory createLabelWithCenter:CGPointMake(30, _focusSlider.centerY) withBounds:CGRectMake(0, 0, 40, 20) withText:@"调焦" withFont:13 withTextColor:[UIColor blackColor] withTextAlignment:NSTextAlignmentCenter];
//    focusLab.backgroundColor = [UIColor whiteColor];
//    focusLab.layer.cornerRadius = 5;
//    focusLab.layer.masksToBounds = YES;
//    [self addSubview:focusLab];
//}

- (void)configFocusSliderUI {
    
    UILabel *focusLab = [MIUIFactory createLabelWithCenter:CGPointMake(30, CGRectGetMinY(_sliderView.frame) - 30) withBounds:CGRectMake(0, 0, 40, 20) withText:@"调焦" withFont:13 withTextColor:[UIColor blackColor] withTextAlignment:NSTextAlignmentCenter];
    focusLab.backgroundColor = [UIColor whiteColor];
    focusLab.layer.cornerRadius = 5;
    focusLab.layer.masksToBounds = YES;
    [self addSubview:focusLab];
    
    _focusSliderView = [[UISlider alloc] initWithFrame:CGRectMake(15, 50 + (CGRectGetMinY(focusLab.frame) - 70) / 2.0, CGRectGetMinY(focusLab.frame) - 70, 20)];
    _focusSliderView.centerX = focusLab.centerX;
    CGAffineTransform rotation = CGAffineTransformMakeRotation(-M_PI/2);
    [_focusSliderView setTransform:rotation];
    [_focusSliderView setThumbImage:[UIImage imageNamed:@"icon_camera_circle_normal"] forState:UIControlStateNormal];
    _focusSliderView.minimumTrackTintColor = [UIColor whiteColor];
    _focusSliderView.maximumTrackTintColor = [UIColor whiteColor];
    _focusSliderView.minimumValue = 0;
    _focusSliderView.maximumValue = 1;
    [_focusSliderView addTarget:self action:@selector(changeFocus:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_focusSliderView];
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)appDidEnterBackground {
    _torchBtn.selected = NO;
}

#pragma mark - 事件响应
- (void)goBack:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(goBackAction:)]) {
        [_delegate goBackAction:self];
    }
}

//聚焦
- (void)tapAction:(UIGestureRecognizer *)tap {
    if ([_delegate respondsToSelector:@selector(focusAction:point:succ:fail:)]) {
        CGPoint point = [tap locationInView:self.previewView];
        [self runFocusAnimation:self.focusView point:point];
        [_delegate focusAction:self point:[self.previewView captureDevicePointForPoint:point] succ:nil fail:^(NSError *error) {
            [MIToastAlertView showAlertViewWithMessage:error.localizedDescription];
        }];
    }
}

//曝光
- (void)doubleTapAction:(UIGestureRecognizer *)tap {
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
    _recordTitle.text = @"00:00:00";
    btn.selected = !btn.selected;
    if (btn.selected) {
        _recordSecond = 0;
        [self.recordTimer fire];
        _coverBtn.hidden = YES;
        _torchBtn.hidden = YES;
        _shootTypeMenu.hidden = YES;
        
        if ([_delegate respondsToSelector:@selector(startRecordVideoAction:)]) {
            [_delegate startRecordVideoAction:self];
        }
    } else {
        [_recordTimer invalidate];
        _recordTimer = nil;
        _coverBtn.hidden = NO;
        _torchBtn.hidden = NO;
        _shootTypeMenu.hidden = NO;
        
        if ([_delegate respondsToSelector:@selector(stopRecordVideoAction:)]) {
            [_delegate stopRecordVideoAction:self];
        }
    }
}

//拍照
- (void)takePhoto:(UIButton *)btn {
    if ([_delegate respondsToSelector:@selector(takePhotoAction:)]) {
        [_delegate takePhotoAction:self];
    }
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

//功能按钮
- (void)clickFunctionBtn:(UIButton *)btn {
    btn.selected = !btn.selected;
    if (btn.selected) {
        if (!_functionView) {
            _functionView = [[MICameraFunctionView alloc] initWithFrame:CGRectMake(0, 50, self.width, self.height - 160) delegate:self];
            [self addSubview:_functionView];
            
            WSWeak(weakSelf);
            _functionView.changeTorchFactor = ^(CGFloat factor) {
                if (factor < 0.01) {
                    weakSelf.torchBtn.selected = NO;
                } else {
                    weakSelf.torchBtn.selected = YES;
                }
                
                if ([weakSelf.delegate respondsToSelector:@selector(setDeviceForchFactor:focusFactor:)]) {
                    [weakSelf.delegate setDeviceForchFactor:weakSelf focusFactor:factor];
                }
            };
            
            _functionView.changeFocalFactor = ^(CGFloat factor) {
                if ([weakSelf.delegate respondsToSelector:@selector(setDeviceZoomFactor:zoomFactor:)]) {
                    [weakSelf.delegate setDeviceZoomFactor:weakSelf zoomFactor:factor];
                }
            };
            
            _functionView.changeFocusFactor = ^(CGFloat factor) {
                if ([weakSelf.delegate respondsToSelector:@selector(setDeviceFocusFactor:focusFactor:)]) {
                    [weakSelf.delegate setDeviceFocusFactor:weakSelf focusFactor:factor];
                }
            };
            
            _functionView.changeExposureDurationAndIsoFactor = ^(CGFloat duration, CGFloat iso) {
                if ([weakSelf.delegate respondsToSelector:@selector(setDeviceExposureDurationAndIsoFactor:durationFactor:isoFactor:)]) {
                    [weakSelf.delegate setDeviceExposureDurationAndIsoFactor:weakSelf durationFactor:duration isoFactor:iso];
                }
            };
            
            _functionView.changeExposureBiasFactor = ^(CGFloat factor) {
                if ([weakSelf.delegate respondsToSelector:@selector(setDeviceExposureBiasFactor:biasFactor:)]) {
                    [weakSelf.delegate setDeviceExposureBiasFactor:weakSelf biasFactor:factor];
                }
            };
            
            _functionView.changeBalanceFactor = ^(CGFloat red, CGFloat green, CGFloat blue) {
                if ([weakSelf.delegate respondsToSelector:@selector(setDeviceBalanceFactor:redFactor:greenFactor:blueFactor:)]) {
                    [weakSelf.delegate setDeviceBalanceFactor:weakSelf redFactor:red greenFactor:green blueFactor:blue];
                }
            };
        } else {
            _functionView.hidden = NO;
        }
    } else {
        _functionView.hidden = YES;
    }
}

//预览图片
- (void)reviewCoverImage:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(reviewCoverImageOrVideo:resourceType:)]) {
        [self.delegate reviewCoverImageOrVideo:self resourceType:_shootTypeMenu.selectedIndex];
    }
}

//对焦
- (void)changeFocus:(UISlider *)slider {
    if ([self.delegate respondsToSelector:@selector(setDeviceFocusFactor:focusFactor:)]) {
        [self.delegate setDeviceFocusFactor:self focusFactor:slider.value];
    }
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
        [MIToastAlertView showAlertViewWithMessage:@"视频录制时长不得超过1分钟"];
        return;
    }
    
    NSInteger h = _recordSecond / 600;
    NSInteger m = (_recordSecond % 600) / 10;
    NSInteger s = (_recordSecond % 600) % 10;
    NSString *hString = h > 9?[NSString stringWithFormat:@"%ld",(long)h]:[NSString stringWithFormat:@"0%ld",(long)h];
    NSString *mString = m > 9?[NSString stringWithFormat:@"%ld",(long)m]:[NSString stringWithFormat:@"0%ld",(long)m];
    NSString *sString = s > 9?[NSString stringWithFormat:@"%ld",(long)s]:[NSString stringWithFormat:@"0%ld",(long)s];
    _recordTitle.text = [NSString stringWithFormat:@"%@:%@:%@",hString,mString,sString];
}

#pragma mark - public methods
- (void)changeTorch:(BOOL)on {
    _torchBtn.selected = on;
}

- (void)refreshCoverImage:(UIImage *)image {
    [_coverBtn setImage:image forState:UIControlStateNormal];
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
            [MIToastAlertView showAlertViewWithMessage:@"自动聚焦曝光设置成功"];
        } fail:^(NSError *error) {
            [MIToastAlertView showAlertViewWithMessage:error.localizedDescription];
        }];
    }
}

- (void)resetCoverBtnImageWithAssetPath:(NSString *)path {

    if (path == nil) {
        [_coverBtn setImage:[UIImage imageNamed:@"home_btn_album"] forState:UIControlStateNormal];
    } else {
        UIImage *image;
        
        if ([path.pathExtension isEqualToString:@"png"]) {
            image = [UIImage imageWithContentsOfFile:path];
        } else {
            AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:path]];
            image = [MIHelpTool fetchThumbnailWithAVAsset:asset curTime:0];
        }
        
        [_coverBtn setImage:image forState:UIControlStateNormal];
    }
}

#pragma mark - QSHorizontalPickerViewDelegate
- (void)horizontalPickerView:(MIHorizontalPickerView *)hpv didHighlightHorizontalPickerViewCell:(MIHorizontalPickerViewCell *)hpvc atIndex:(NSInteger)index {
    
    [hpvc setHighlightState];
    
    if (index == 0) {
        _recordTitle.hidden = YES;
        _photoBtn.hidden = NO;
        _videoBtn.hidden = YES;
    } else {
        self.recordTitle.hidden = NO;
        _photoBtn.hidden = YES;
        _videoBtn.hidden = NO;
    }
    //TODO
//    [self resetCoverBtnImageWithAssetPath:<#(NSString *)#>];
}

- (void)horizontalPickerView:(MIHorizontalPickerView *)hpv didUnhighlightHorizontalPickerViewCell:(MIHorizontalPickerViewCell *)hpvc atIndex:(NSInteger)index {
    
    [hpvc setNormalState];
}

#pragma mark - QSHorizontalPickerViewDataSource
- (NSInteger)numberOfColumnInHorizontalPickerView:(MIHorizontalPickerView *)hpv {
    return _shootTypeList.count;
}

- (MIHorizontalPickerViewCell *)horizontalPickerView:(MIHorizontalPickerView *)hpv cellForColumnAtIndex:(NSInteger)index {
    
    MIHorizontalPickerViewCellItem *item = _shootTypeList[index];
    MIHorizontalPickerViewCell *cell = [[MIHorizontalPickerViewCell alloc] initWithHorizontalPickerViewCellItem:item];
    cell.currentIndex = index;
    cell.HorizontalPickerViewCellSelectBlock = ^(NSInteger index) {
        hpv.selectedIndex = index;
    };
    
    return cell;
}

#pragma mark - MICameraFunctionViewDelegate
- (CGPoint)getDeviceMinAndMaxExposureDurationFactor:(MICameraFunctionView *)func {
    return [self.delegate getDeviceMinAndMaxExposureDurationFactor:self];
}

- (CGPoint)getDeviceMinAndMaxExposureIsoFactor:(MICameraFunctionView *)func {
    return [self.delegate getDeviceMinAndMaxExposureIsoFactor:self];
}

- (CGPoint)getDeviceMinAndMaxExposureBiasFactor:(MICameraFunctionView *)func {
    return [self.delegate getDeviceMinAndMaxExposureBiasFactor:self];
}

- (CGFloat)getDeviceMaxBalanceFactor:(MICameraFunctionView *)func {
    return [self.delegate getDeviceMaxBalanceFactor:self];
}

@end
