//
//  MIPraiseCell.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/14.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIPraiseCell.h"

@interface MIPraiseCell ()

@property (weak, nonatomic) IBOutlet UIButton *userIconBtn;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLab;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UIButton *praiseBtn;

@end

@implementation MIPraiseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [_userIconBtn round:20 RectCorners:UIRectCornerAllCorners];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(MIPraiseModel *)model {
    _model = model;
    
    NSString *imgUrl = [NSString stringWithFormat:@"%@?x-oss-process=image/resize,m_fill,h_40,w_40", model.avatar];
    [_userIconBtn sd_setImageWithURL:[NSURL URLWithString:imgUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"icon_personal_head_nor"]];
    
    _nicknameLab.text = model.nickname;
    NSArray *strs = [model.created_at componentsSeparatedByString:@" "];
    _timeLab.text = strs.firstObject;
    
//    [_praiseBtn setTitle:[NSString stringWithFormat:@"%ld", model.likes] forState:UIControlStateNormal];
}

- (IBAction)clickUserIconBtn:(UIButton *)sender {
    if (self.clickUserIcon) {
        self.clickUserIcon([_model.user_id integerValue]);
    }
}

- (IBAction)clickPraiseBtn:(UIButton *)sender {
    
}

@end
