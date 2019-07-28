//
//  MILetterListModel.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/7/9.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MILetterListModel.h"
#import "YYText.h"

@implementation MILetterListModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"modelId" : @"id"};
}

- (CGRect)timeFrame {
    CGRect rect  = CGRectZero;
    CGSize size = [self labelAutoCalculateRectWith:self.created_at Font:[UIFont systemFontOfSize:9] MaxSize:CGSizeMake(MAXFLOAT, 17)];
    
    CGRect logoRect = [self logoFrame];
    CGRect messageRect = [self messageFrame];
    CGRect imageRect = [self imageFrame];
    
    CGFloat y = 0;
    if (messageRect.size.height > 0) {
        y = messageRect.origin.y + messageRect.size.height + 10;
    }
    if (imageRect.size.height > 0) {
        y = imageRect.origin.y + imageRect.size.height + 10;
    }
    
    if (self.isSelf) {
        rect = CGRectMake(logoRect.origin.x - size.width - 10, y, size.width, 20);
    } else {
        rect = CGRectMake(logoRect.origin.x + logoRect.size.width + 10, y, size.width, 20);
    }
    
    return rect;
}

- (CGRect)logoFrame {
    CGRect rect = CGRectZero;
    if (self.isSelf) {
        rect = CGRectMake(MIScreenWidth - 50, 20, 40, 40);
    } else {
        rect = CGRectMake(10, 20, 40, 40);
    }
    
    return rect;
}

- (CGRect)messageFrame {
    CGRect rect = CGRectZero;
    if ([self.type isEqualToString:@"6"]) {
        return rect;
    }

    CGRect logoRect = [self logoFrame];
    CGFloat maxWith = MIScreenWidth * 0.5 - 68;
    CGFloat width = [MIHelpTool measureSingleLineStringWidthWithString:self.content font:[UIFont systemFontOfSize:12]];
    if (width > maxWith) {
        width = maxWith;
    }

    CGFloat height = [MIHelpTool measureMutilineStringHeightWithString:self.content font:[UIFont systemFontOfSize:12] width:width];
    NSArray *lines = [self getSeparatedLinesArrayWithContentWidth:width text:self.content font:[UIFont systemFontOfSize:12]];
    height += (lines.count + 2) * 5;
    width += 20;

    if (self.isSelf) {
        rect = CGRectMake(MIScreenWidth - width - 68, logoRect.origin.y, width, height > 40 ? height : 40);
    } else {
        rect = CGRectMake(68, logoRect.origin.y, width, height > 40 ? height : 40);
    }
    
    return rect;
}

- (CGRect)imageFrame {
    CGRect rect = CGRectZero;
    if ([self.type isEqualToString:@"3"]) {
        return rect;
    }
    
    CGRect logoRect = [self logoFrame];
    CGSize imageSize = [self.image imageShowSize];
    
    if (self.isSelf) {
        rect = CGRectMake(MIScreenWidth - imageSize.width - 60, logoRect.origin.y, imageSize.width, imageSize.height);
    } else {
        rect = CGRectMake(60, logoRect.origin.y, imageSize.width, imageSize.height);
    }
    
    return rect;
}

- (CGRect)pointFrame {
    CGRect rect = CGRectZero;
    CGRect logoRect = [self logoFrame];
    
    if (self.isSelf) {
       rect = CGRectMake(MIScreenWidth - 60 - 8, logoRect.origin.y + (logoRect.size.height - 13) / 2.0, 8, 13);
    } else {
        rect = CGRectMake(60, logoRect.origin.y + (logoRect.size.height - 13) / 2.0, 8, 13);
    }
    
    return rect;
}

- (CGFloat)cellHeight {
    return [self messageFrame].size.height + [self imageFrame].size.height + [self timeFrame].size.height + 30;
}

- (CGSize)labelAutoCalculateRectWith:(NSString *)text
                                Font:(UIFont *)textFont
                             MaxSize:(CGSize)maxSize {
    
    NSDictionary *attributes = @{NSFontAttributeName: textFont};
    CGRect rect = [text boundingRectWithSize:maxSize
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:attributes
                                     context:nil];
    return rect.size;
}

- (YYTextLayout *)getContentHeightWithStr:(NSString *)contentStr font:(CGFloat)font lineSpace:(CGFloat)lineSpace maxRow:(CGFloat)maxRow width:(CGFloat)width {
    
    NSMutableAttributedString *introText = [[NSMutableAttributedString alloc] initWithString:contentStr];
    introText.yy_font = [UIFont systemFontOfSize:font];
    introText.yy_lineSpacing = lineSpace;
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

- (NSArray *)getSeparatedLinesArrayWithContentWidth:(CGFloat)width
                                               text:(NSString *)text
                                               font:(UIFont *)font {

    CTFontRef myFont = CTFontCreateWithName((__bridge CFStringRef)([font fontName]), [font pointSize], NULL);
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:text];
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)myFont range:NSMakeRange(0, attStr.length)];
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attStr);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, width, 100000));
    
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    NSMutableArray *linesArray = [[NSMutableArray alloc]init];
    
    for (id line in lines) {
        CTLineRef lineRef = (__bridge CTLineRef )line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        
        NSString *lineString = [text substringWithRange:range];
        [linesArray addObject:lineString];
    }
    
    return (NSArray *)linesArray;
}

@end
