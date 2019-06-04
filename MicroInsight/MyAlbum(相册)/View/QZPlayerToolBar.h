//
//  QZPlayerToolBar.h
//  QZSQ
//
//  Created by 舒雄威 on 2019/5/17.
//  Copyright © 2019 XMZY. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QZPlayerToolBar : UIView

@property (nonatomic, copy) void (^playOrPauseBlock)(BOOL isPause);
@property (nonatomic, copy) void (^fullScreenBlock)(BOOL isFullScreen);
@property (nonatomic, copy) void (^changeProgressBlock)(CGFloat progress);

/**
 刷新时间条

 @param currentTime 当前时间
 @param duration 总时间
 */
- (void)refreshTimeLableWithCurrentTime:(NSTimeInterval)currentTime
                               duration:(NSTimeInterval)duration;

/**
 刷新播放或暂停按钮的状态

 @param pause 是否显示暂停
 */
- (void)refreshPlayOrPauseButtonStatus:(BOOL)pause;

/**
 获取播放按钮的状态

 @return 是否正在播放(YES：是，NO：否)
 */
- (BOOL)getPlayOrPuaseButtonStatus;

@end

NS_ASSUME_NONNULL_END
