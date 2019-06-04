//
//  QZCustomVideoPlayer.h
//  QZSQ
//
//  Created by 舒雄威 on 2019/5/17.
//  Copyright © 2019 XMZY. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QZCustomVideoPlayer : UIView

@property (nonatomic, copy) void (^fullScreenBlock)(void); //全屏
@property (nonatomic, copy) void (^showOrHideToolBarBlock)(BOOL show); //显示或隐藏工具条

/**
 初始化

 @param frame 范围
 @param videoUrl 视频源
 @return 返回值
 */
- (instancetype)initWithFrame:(CGRect)frame videoUrl:(NSString *)videoUrl;

/**
 设置视频源

 @param videoUrl 视频源
 */
- (void)setVideoUrl:(NSString *)videoUrl;

/**
 刷新自视图范围
 */
- (void)refreshSubviewFrame;

/**
 设置播放器的播放或暂停状态
 */
- (void)setPlayerPlayOrPauseStatus;

/**
 清理
 */
- (void)clear;

@end

NS_ASSUME_NONNULL_END
