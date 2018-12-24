//
//  MICommunityCell.m
//  MicroInsight
//
//  Created by Jonphy on 2018/11/19.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "MICommunityCell.h"

@implementation MICommunityCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.layer.cornerRadius = 3;
    self.layer.masksToBounds = YES;
    _userIcon.layer.cornerRadius = 10;
    _userIcon.layer.masksToBounds = YES;
}

@end
