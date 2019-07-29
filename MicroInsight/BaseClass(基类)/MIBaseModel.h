//
//  MIBaseModel.h
//  MicroInsight
//
//  Created by 舒雄威 on 2018/12/5.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QSDatabase.h"

NS_ASSUME_NONNULL_BEGIN

@class YYTextLayout;
@interface MIBaseModel : QSDatabase

/**
 获取文本的高度

 @param contentStr 文本内容
 @param width 文字显示宽度
 @param font 字体
 @param lineSpace 行距
 @param maxRow 最大行数
 @return 返回gao du zhi高度值
 */
- (YYTextLayout *)getContentHeightWithStr:(NSString *)contentStr
                                    width:(CGFloat)width
                                     font:(CGFloat)font
                                lineSpace:(CGFloat)lineSpace
                                   maxRow:(CGFloat)maxRow;

@end

NS_ASSUME_NONNULL_END
