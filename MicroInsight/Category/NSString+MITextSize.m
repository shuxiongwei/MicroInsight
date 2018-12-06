//
//  NSString+MITextSize.m
//  MicroInsight
//
//  Created by J on 2018/12/4.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "NSString+MITextSize.h"

@implementation NSString (MITextSize)

/**
 *  动态计算文字的宽高（单行）
 *  @param font 文字的字体
 *  @return 计算的宽高
 */
- (CGSize)sizeWithFont:(UIFont *)font
{
    CGSize theSize;
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    theSize = [self sizeWithAttributes:attributes];
    // 向上取整
    theSize.width = ceil(theSize.width);
    theSize.height = ceil(theSize.height);
    return theSize;
}

@end
