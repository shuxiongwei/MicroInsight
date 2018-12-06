//
//  MIThemeCell.m
//  MicroInsight
//
//  Created by Jonphy on 2018/11/21.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "MIThemeCell.h"

@implementation MIThemeCell


- (void)awakeFromNib{
    [super awakeFromNib];
    
    _themLb.layer.borderColor = [UIColor whiteColor].CGColor;
    _themLb.layer.cornerRadius = 30 / 2;
    _themLb.layer.borderWidth = 1;
    _themLb.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected{
    
    if (selected) {
        
        _themLb.layer.borderColor = [UIColor clearColor].CGColor;
        _themLb.backgroundColor = MIColor(241, 56, 100);
        
    }else{
        _themLb.layer.borderColor = [UIColor whiteColor].CGColor;
        _themLb.backgroundColor = [UIColor blackColor];
    }
}

@end
