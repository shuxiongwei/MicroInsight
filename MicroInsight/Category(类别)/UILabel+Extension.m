//
//  UILabel+Extension.m
//  HXClient
//
//  Created by nacker on 16/1/11.
//  Copyright © 2016年 帶頭二哥 QQ:648959. All rights reserved.
//

#import "UILabel+Extension.h"

@implementation UILabel (Extension)

+ (UILabel *)labelWithText:(NSString *)text sizeFont:(UIFont *)sizeFont textColor:(UIColor *)textColor
{
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = sizeFont;
    label.textColor = textColor;
    return label;
}

+ (instancetype)labelWithTitle:(NSString *)title color:(UIColor *)color fontSize:(CGFloat)fontSize alignment:(NSTextAlignment)alignment {
    
    UILabel *label = [[UILabel alloc] init];
    
    label.text = title;
    label.textColor = color;
    label.font = [UIFont systemFontOfSize:fontSize];
    label.numberOfLines = 0;
    label.textAlignment = alignment;
    //    label.preferredMaxLayoutWidth =
    [label sizeToFit];
    return label;
}

- (void)setAttributedStringWithText:(NSString *)text
                              color:(UIColor *)color
                               font:(CGFloat)font {
    
    NSMutableAttributedString *attrDescribeStr = [[NSMutableAttributedString alloc] initWithString:self.text];
    [attrDescribeStr addAttribute:NSForegroundColorAttributeName value:color range:[self.text rangeOfString:text]];
    [attrDescribeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:font] range:[self.text rangeOfString:text]];
    self.attributedText = attrDescribeStr;
}

@end
