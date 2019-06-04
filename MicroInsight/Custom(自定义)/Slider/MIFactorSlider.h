//
//  MIFactorSlider.h
//  MicroInsight
//
//  Created by 舒雄威 on 17/8/10.
//  Copyright © 2017年 Yoya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OMSliderBar.h"

@interface MIFactorSlider : UIView

@property (weak, nonatomic) IBOutlet OMSliderBar *sliderBar;
@property (weak, nonatomic) IBOutlet UIView *videoProgress;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sliderBarConstant;
@property (nonatomic, assign) CGFloat maxFactor; //镜头最大放大倍数

@property (nonatomic, copy) void (^sliderBarDidTrack)(CGFloat x);
@property (nonatomic, copy) void (^sliderBarDidEndTrack)(CGFloat x);

- (void)refreshCurrentFactor:(CGFloat)factor;

@end
