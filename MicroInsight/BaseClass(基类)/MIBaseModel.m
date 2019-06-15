//
//  MIBaseModel.m
//  MicroInsight
//
//  Created by 舒雄威 on 2018/12/5.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "MIBaseModel.h"
#import "YYText.h"

@implementation MIBaseModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

- (YYTextLayout *)getContentHeightWithStr:(NSString *)contentStr
                                    width:(CGFloat)width
                                     font:(CGFloat)font
                                lineSpace:(CGFloat)lineSpace
                                   maxRow:(CGFloat)maxRow {
    
    NSMutableAttributedString *introText = [[NSMutableAttributedString alloc] initWithString:contentStr];
    introText.yy_font = [UIFont systemFontOfSize:font];
    introText.yy_lineSpacing = lineSpace;
    //    introText.yy_maximumLineHeight = 60;
    introText.yy_alignment = NSTextAlignmentLeft;
    introText.yy_lineBreakMode = NSLineBreakByWordWrapping;
    
    YYTextContainer *container = [[YYTextContainer alloc] init];
    container.size = CGSizeMake(width, CGFLOAT_MAX);
    if (maxRow != 0) {
        container.maximumNumberOfRows = maxRow;
    }
    
    YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:introText];
    return layout;
}

@end
