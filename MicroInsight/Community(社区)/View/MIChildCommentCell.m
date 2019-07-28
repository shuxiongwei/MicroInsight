//
//  MIChildCommentCell.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/17.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIChildCommentCell.h"
#import "MICommunityListModel.h"

@interface MIChildCommentCell ()

@property (weak, nonatomic) IBOutlet UIButton *userIcon;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UIButton *praiseBtn;
@property (weak, nonatomic) IBOutlet UILabel *contentLab;

@end


@implementation MIChildCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [_userIcon round:20 RectCorners:UIRectCornerAllCorners];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [_praiseBtn layoutButtonWithEdgeInsetsStyle:MIButtonEdgeInsetsStyleLeft imageTitleSpace:3];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(MIChildCommentModel *)model {
    _model = model;
    
    NSString *imgUrl = [NSString stringWithFormat:@"%@?x-oss-process=image/resize,m_fill,h_40,w_40", model.avatar];
    [_userIcon sd_setImageWithURL:[NSURL URLWithString:imgUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"icon_personal_head_nor"]];
    
    _titleLab.text = model.nickname;
    NSArray *strs = [model.created_at componentsSeparatedByString:@" "];
    _timeLab.text = strs.firstObject;
    
    [_praiseBtn setTitle:[NSString stringWithFormat:@"%ld", model.likes] forState:UIControlStateNormal];
    _praiseBtn.selected = model.isLike;
    
    _contentLab.text = model.content;
}

- (IBAction)clickUserIcon:(UIButton *)sender {
    if (self.clickUserIcon) {
        self.clickUserIcon(_model);
    }
}

- (IBAction)clickPraiseBtn:(UIButton *)sender {
    if (self.clickPraiseComment) {
        self.clickPraiseComment();
    }
}

@end
