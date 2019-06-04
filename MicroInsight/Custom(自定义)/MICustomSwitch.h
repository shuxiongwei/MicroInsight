//
//  MICustomSwitch.h
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/11.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MICustomSwitch : UIControl

@property (nonatomic, assign, getter = isOn) BOOL on;
@property (nonatomic, strong) UIColor *onTintColor;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) UIColor *thumbTintColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) NSString *onText;
@property (nonatomic, strong) NSString *offText;
@property (nonatomic, assign) NSInteger switchKnobSize;

- (void)setOn:(BOOL)on animated:(BOOL)animated;
- (instancetype)initWithFrame:(CGRect)frame
                      onColor:(UIColor *)onColor
                     offColor:(UIColor *)offColor
                         font:(UIFont *)font
                     ballSize:(NSInteger)ballSize;

@end

NS_ASSUME_NONNULL_END
