//
//  UIButton+Extension.h
//  MicroInsight
//
//  Created by 舒雄威 on 2018/8/23.
//  Copyright © 2018年 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>

// 定义一个枚举（包含了四种类型的button）
typedef NS_ENUM(NSUInteger, MIButtonEdgeInsetsStyle) {
    MIButtonEdgeInsetsStyleTop,    // image在上，label在下
    MIButtonEdgeInsetsStyleLeft,   // image在左，label在右
    MIButtonEdgeInsetsStyleBottom, // image在下，label在上
    MIButtonEdgeInsetsStyleRight   // image在右，label在左
};

@interface UIButton (Extension)

- (void)setEnlargeEdge:(CGFloat)size;

- (void)setEnlargeEdgeWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left;

- (void)layoutButtonWithEdgeInsetsStyle:(MIButtonEdgeInsetsStyle)style
                        imageTitleSpace:(CGFloat)space;

@end
