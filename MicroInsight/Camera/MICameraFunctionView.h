//
//  MICameraFunctionView.h
//  MicroInsight
//
//  Created by 舒雄威 on 2018/8/30.
//  Copyright © 2018年 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MICameraFunctionView;
@protocol MICameraFunctionViewDelegate <NSObject>
@optional;

/**
 获取曝光的最小和最大时长
 
 @param func 自身
 @return 返回值
 */
- (CGPoint)getDeviceMinAndMaxExposureDurationFactor:(MICameraFunctionView *)func;

/**
 获取曝光的最小和最大ISO参数
 
 @param func 自身
 @return 返回值
 */
- (CGPoint)getDeviceMinAndMaxExposureIsoFactor:(MICameraFunctionView *)func;

/**
 获取曝光的最小和最大倾斜

 @param func 自身
 @return 返回值
 */
- (CGPoint)getDeviceMinAndMaxExposureBiasFactor:(MICameraFunctionView *)func;

/**
 获取最大的白平衡增益
 
 @param func 自身
 @return 返回值
 */
- (CGFloat)getDeviceMaxBalanceFactor:(MICameraFunctionView *)func;

@end


@interface MICameraFunctionView : UIView

@property (nonatomic, copy) void (^changeTorchFactor)(CGFloat factor);
@property (nonatomic, copy) void (^changeFocalFactor)(CGFloat factor);
@property (nonatomic, copy) void (^changeFocusFactor)(CGFloat factor);
@property (nonatomic, copy) void (^changeExposureDurationAndIsoFactor)(CGFloat duration, CGFloat iso);
@property (nonatomic, copy) void (^changeExposureBiasFactor)(CGFloat factor);
@property (nonatomic, copy) void (^changeBalanceFactor)(CGFloat red, CGFloat green, CGFloat blue);

- (instancetype)initWithFrame:(CGRect)frame delegate:(id)delegate;

@end
