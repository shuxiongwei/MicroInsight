//
//  MICameraView.h
//  MicroInsight
//
//  Created by 佰道聚合 on 2017/7/5.
//  Copyright © 2017年 cyd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MIVideoPreview.h"

@class MICameraView;
@protocol MICameraViewDelegate <NSObject>
@optional;

/**
 返回

 @param cameraView 自身
 */
- (void)goBackAction:(MICameraView *)cameraView;

/**
 转换摄像头

 @param cameraView 自身
 @param succ 成功回调
 @param fail 失败回调
 */
- (void)swicthCameraAction:(MICameraView *)cameraView succ:(void(^)(void))succ fail:(void(^)(NSError *error))fail;

/**
 闪光灯

 @param cameraView 自身
 @param succ 成功回调
 @param fail 失败回调
 */
- (void)flashLightAction:(MICameraView *)cameraView succ:(void(^)(void))succ fail:(void(^)(NSError *error))fail;

/**
 补光
 
 @param cameraView 自身
 @param succ 成功回调
 @param fail 失败回调
 */
- (void)torchLightAction:(MICameraView *)cameraView succ:(void(^)(void))succ fail:(void(^)(NSError *error))fail;

/**
 聚焦
 
 @param cameraView 自身
 @param succ 成功回调
 @param fail 失败回调
 */
- (void)focusAction:(MICameraView *)cameraView point:(CGPoint)point succ:(void(^)(void))succ fail:(void(^)(NSError *error))fail;

/**
 曝光
 
 @param cameraView 自身
 @param succ 成功回调
 @param fail 失败回调
 */
- (void)exposAction:(MICameraView *)cameraView point:(CGPoint)point succ:(void(^)(void))succ fail:(void(^)(NSError *error))fail;

/**
 自动聚焦、曝光
 
 @param cameraView 自身
 @param succ 成功回调
 @param fail 失败回调
 */
- (void)autoFocusAndExposureAction:(MICameraView *)cameraView succ:(void(^)(void))succ fail:(void(^)(NSError *error))fail;

/**
 取消
 
 @param cameraView 自身
 */
- (void)cancelAction:(MICameraView *)cameraView;

/**
 拍照
 
 @param cameraView 自身
 */
- (void)takePhotoAction:(MICameraView *)cameraView waterImage:(nullable UIImage *)waterImage;

- (AVCaptureVideoOrientation)getCurrentVideoOrientation:(MICameraView *)cameraView;

/**
 停止录视频
 
 @param cameraView 自身
 */
- (void)stopRecordVideoAction:(MICameraView *)cameraView waterImage:(nullable UIImage *)waterImage;

/**
 开始录视频
 
 @param cameraView 自身
 */
- (void)startRecordVideoAction:(MICameraView *)cameraView waterImage:(nullable UIImage *)waterImage;

/**
 改变拍摄类型
 
 @param cameraView 自身
 @param type 拍摄类型
 */
- (void)didChangeTypeAction:(MICameraView *)cameraView type:(NSInteger)type;

/**
 预览图片或视频
 
 @param cameraView 自身
 @param type 资源类型
 */
- (void)reviewCoverImageOrVideo:(MICameraView *)cameraView resourceType:(NSInteger)type;

/**
 设置相机的变焦参数

 @param cameraView 自身
 @param factor 变焦参数
 */
- (void)setDeviceZoomFactor:(MICameraView *)cameraView zoomFactor:(CGFloat)factor;

/**
 设置相机的对焦参数

 @param cameraView 自身
 @param factor 对焦参数
 */
- (void)setDeviceFocusFactor:(MICameraView *)cameraView focusFactor:(CGFloat)factor;

/**
 设置手电筒亮度参数

 @param cameraView 自身
 @param factor 亮度参数
 */
- (void)setDeviceForchFactor:(MICameraView *)cameraView focusFactor:(CGFloat)factor;

- (void)setDeviceExposureDurationAndIsoFactor:(MICameraView *)cameraView durationFactor:(CGFloat)duration isoFactor:(CGFloat)iso;

/**
 设置曝光倾斜

 @param cameraView 自身
 @param factor 倾斜参数
 */
- (void)setDeviceExposureBiasFactor:(MICameraView *)cameraView biasFactor:(CGFloat)factor;

/**
 设置白平衡增益
 
 @param cameraView 自身
 @param red 红
 @param green 绿
 @param blue 蓝
 */
- (void)setDeviceBalanceFactor:(MICameraView *)cameraView redFactor:(CGFloat)red greenFactor:(CGFloat)green blueFactor:(CGFloat)blue;

/**
 获取曝光的最小和最大时长
 
 @param cameraView 自身
 @return 返回值
 */
- (CGPoint)getDeviceMinAndMaxExposureDurationFactor:(MICameraView *)cameraView;

/**
 获取曝光的最小和最大ISO参数
 
 @param cameraView 自身
 @return 返回值
 */
- (CGPoint)getDeviceMinAndMaxExposureIsoFactor:(MICameraView *)cameraView;

/**
 获取曝光的最小和最大倾斜
 
 @param cameraView 自身
 @return 返回值
 */
- (CGPoint)getDeviceMinAndMaxExposureBiasFactor:(MICameraView *)cameraView;

/**
 获取最大的白平衡增益
 
 @param cameraView 自身
 @return 返回值
 */
- (CGFloat)getDeviceMaxBalanceFactor:(MICameraView *)cameraView;

@end

@interface MICameraView : UIView

@property(nonatomic, weak) id <MICameraViewDelegate> delegate;
@property(nonatomic, strong, readonly) MIVideoPreview *previewView;
@property(nonatomic, assign, readonly) NSInteger type; // 0：拍照 1：视频

/**
 改变手电筒

 @param on 关或开
 */
- (void)changeTorch:(BOOL)on;

/**
 刷新预览图片
 */
- (void)resetCoverBtnImageWithAssetPath:(NSString *)path;

- (void)resetFocusSliderValue:(CGFloat)value;

@end
