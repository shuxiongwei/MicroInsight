//
//  MIThemeCell.m
//  MicroInsight
//
//  Created by Jonphy on 2018/11/21.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "MIThemeCell.h"

@implementation MIThemeCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super initWithCoder:aDecoder]) {
        
        _themLb.layer.borderColor = [UIColor whiteColor].CGColor;
        _themLb.layer.cornerRadius = CGRectGetHeight(_themLb.bounds) / 2;
        _themLb.layer.borderWidth = 1;
    }
    return self;
}


- (void)setSelected:(BOOL)selected{
    
    if (selected) {
        
        _themLb.layer.borderColor = [UIColor clearColor].CGColor;
        _themLb.backgroundColor = MIColor(241, 56, 10);
    }else{
        _themLb.layer.borderColor = [UIColor whiteColor].CGColor;
        _themLb.backgroundColor = [UIColor blackColor];
    }
}

@end
