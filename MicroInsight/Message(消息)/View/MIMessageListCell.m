//
//  MIMessageListCell.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/12.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIMessageListCell.h"
#import "UIButton+WebCache.h"
#import "MIMessageListModel.h"
#import "NSDate+Extension.h"

@interface MIMessageListCell ()

@property (weak, nonatomic) IBOutlet UIButton *userIconBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *contentLab;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UILabel *numLab;
@property (weak, nonatomic) IBOutlet UIButton *extendBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;

@end


@implementation MIMessageListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [_userIconBtn round:20 RectCorners:UIRectCornerAllCorners];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(MIMessageListModel *)model {
    _model = model;
    
    NSString *imgUrl = [NSString stringWithFormat:@"%@?x-oss-process=image/resize,m_fill,h_40,w_40", model.avatar];
    [_userIconBtn sd_setImageWithURL:[NSURL URLWithString:imgUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"icon_personal_head_nor"]];
    
    _titleLab.text = model.title;
    _contentLab.text = model.content;
    
    NSArray *strs = [model.created_at componentsSeparatedByString:@" "];
    NSDate *date = [NSDate date:model.created_at WithFormat:@"yyyy-MM-dd"];
    if ([date isToday]) {
        _timeLab.text = strs.lastObject;
    } else if ([date isYesterday]) {
        _timeLab.text = @"昨天";
    } else {
        _timeLab.text = strs.firstObject;
    }
    
//    CGFloat width = [MIHelpTool measureSingleLineStringWidthWithString:[NSString stringWithFormat:@"%ld", model.count] font:[UIFont systemFontOfSize:8]];
//    _widthConstraint.constant = width + 5;
//    _numLab.text = [NSString stringWithFormat:@"%ld", model.count];
//    [_numLab round:_widthConstraint.constant / 2.0 RectCorners:UIRectCornerAllCorners];
}

@end
