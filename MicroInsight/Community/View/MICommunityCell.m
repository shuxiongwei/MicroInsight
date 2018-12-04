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
    
    _imgView.layer.cornerRadius = 3;
    _imgView.layer.masksToBounds = YES;
}

@end
