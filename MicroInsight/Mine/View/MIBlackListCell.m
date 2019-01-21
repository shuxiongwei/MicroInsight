//
//  MIBlackListCell.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/1/19.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIBlackListCell.h"

@implementation MIBlackListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _imgView.layer.cornerRadius = 15;
    _imgView.layer.masksToBounds = YES;
    _cancelLab.layer.borderWidth = 1;
    _cancelLab.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _cancelLab.layer.cornerRadius = 5;
    _cancelLab.layer.masksToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
