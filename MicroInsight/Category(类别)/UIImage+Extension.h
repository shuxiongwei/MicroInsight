//
//  UIImage+Extension.h
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/22.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Extension)

/**
 将view转成图片

 @param orgView view
 @param rect 范围
 @return 返回值
 */
+ (UIImage *)getImageFromView:(UIView *)orgView inRect:(CGRect)rect;

/**
 图片添加水印图片

 @param image 图片
 @param waterImage 水印图片
 @param rect 水印图片范围
 @return 返回值
 */
+ (UIImage *)addWaterImageWithImage:(UIImage *)image waterImage:(UIImage *)waterImage waterImageRect:(CGRect)rect;

+ (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation;

- (CGSize)imageShowSize;

@end

NS_ASSUME_NONNULL_END
