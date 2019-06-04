//
//  MIThemeCell.m
//  MicroInsight
//
//  Created by Jonphy on 2018/11/21.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "MIThemeCell.h"
#import "MicroInsight-Swift.h"

@implementation MIThemeCell

- (void)awakeFromNib {
    [super awakeFromNib];

}

- (void)setSelected:(BOOL)selected {
    
    if (selected) {
        [_bgBtn setButtonCustomBackgroudImageWithBtn:_bgBtn fromColor:UIColorFromRGBWithAlpha(0x72B3E2, 1) toColor:UIColorFromRGBWithAlpha(0x6DD1CC, 1)];
    } else {
        [_bgBtn setBackgroundImage:nil forState:UIControlStateNormal];
    }
}

@end
