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

@end


@implementation MIMessageListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [_userIconBtn round:20 RectCorners:UIRectCornerAllCorners];
    [_numLab round:9 RectCorners:UIRectCornerAllCorners];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(MIMessageListModel *)model {
    _model = model;
    
    if (model.type == MIMessageTypeNone) {
        _numLab.hidden = YES;
        _timeLab.hidden = YES;
        _extendBtn.hidden = NO;
        [_userIconBtn setImage:[UIImage imageNamed:@"icon_message_app_nor"] forState:UIControlStateNormal];
        _titleLab.text = @"官方推送";
    } else {
        if (model.type == MIMessageTypePush) {
            [_userIconBtn setImage:[UIImage imageNamed:@"icon_message_app_nor"] forState:UIControlStateNormal];
            
            _titleLab.text = @"官方推送";
            _contentLab.text = model.title;
        } else {
            NSString *imgUrl = [NSString stringWithFormat:@"%@?x-oss-process=image/resize,m_fill,h_40,w_40", model.avatar];
            [_userIconBtn sd_setImageWithURL:[NSURL URLWithString:imgUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"icon_personal_head_nor"]];
            
            NSString *title = model.nickname;
            if (model.type == MIMessageTypeComment || model.type == MIMessageTypeCommentComment) {
                title = [NSString stringWithFormat:@"%@评论了你的", model.nickname];
            } else if (model.type == MIMessageTypePraise || model.type == MIMessageTypeCommentPraise) {
                title = [NSString stringWithFormat:@"%@赞了你", model.nickname];
            }
            _titleLab.text = title;
            _contentLab.text = model.comContent;
        }
        
        _numLab.hidden = NO;
        _timeLab.hidden = NO;
        _extendBtn.hidden = YES;
        
        NSArray *strs = [model.created_at componentsSeparatedByString:@" "];
        NSDate *date = [NSDate date:model.created_at WithFormat:@"yyyy-MM-dd"];
        if ([date isToday]) {
            _timeLab.text = strs.lastObject;
        } else if ([date isYesterday]) {
            _timeLab.text = @"昨天";
        } else {
            _timeLab.text = strs.firstObject;
        }
    }
}

- (void)setMessageCount:(NSInteger)count {
    if (count == 0) {
        _numLab.hidden = YES;
    } else {
        _numLab.hidden = NO;
        _numLab.text = [NSString stringWithFormat:@"%ld", count];
    }
}

@end
