//
//  UIImage+Extension.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/22.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "UIImage+Extension.h"

#define MAX_IMAGE_W 141.0
#define MAX_IMAGE_H 228.0

@implementation UIImage (Extension)

+ (UIImage *)getImageFromView:(UIView *)orgView inRect:(CGRect)rect {
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    UIGraphicsBeginImageContextWithOptions(orgView.bounds.size, NO, scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    
    
    
    [orgView.layer renderInContext:context];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    //把像素rect 转化为点rect（如无转化则按原图像素取部分图片）
    
    CGFloat x= rect.origin.x*scale,y=rect.origin.y*scale,w=rect.size.width*scale,h=rect.size.height*scale;
    
    CGRect dianRect = CGRectMake(x, y, w, h);
    
    
    
    //截取部分图片并生成新图片
    
    CGImageRef sourceImageRef = [image CGImage];
    
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, dianRect);
    
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:scale orientation:UIImageOrientationUp];
    
    return newImage;
    
}

+ (UIImage *)addWaterImageWithImage:(UIImage *)image waterImage:(UIImage *)waterImage waterImageRect:(CGRect)rect {
    
    //1.获取图片
    
    //2.开启上下文
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
    //3.绘制背景图片
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    //绘制水印图片到当前上下文
    [waterImage drawInRect:rect];
    //4.从上下文中获取新图片
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    //5.关闭图形上下文
    UIGraphicsEndImageContext();
    //返回图片
    return newImage;
}

//图片旋转(quartz2D绘画出的图片相较oc绘画出的图片是反转的)
+ (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation {
    CGRect rect;
    CGFloat rotate = 0.0;
    CGFloat scaleX = 1.0;
    CGFloat scaleY = 1.0;
    CGFloat translateX = 0;
    CGFloat translateY = 0;
    
    switch (orientation) {
        case UIImageOrientationLeft:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate = 3 * M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    CGContextScaleCTM(context, scaleX, scaleY);
    
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    return newImage;
}

/*
 判断图片长度&宽度
 */
- (CGSize)imageShowSize {
    CGFloat imageWith = self.size.width;
    CGFloat imageHeight = self.size.height;
    CGFloat maxWidth = MIScreenWidth / 2.0;
    CGFloat maxHeight = MIScreenWidth / 2.0;
    if (imageWith >= imageHeight) {
        if (imageWith > maxWidth){
             return CGSizeMake(maxWidth, imageHeight * maxWidth / imageWith);
        } else {
            return self.size;
        }
    } else {
        if (imageHeight > maxHeight) {
            return CGSizeMake(imageWith * maxWidth / imageHeight, maxWidth);
        } else {
            return self.size;
        }
    }

    return CGSizeZero;
}

@end
