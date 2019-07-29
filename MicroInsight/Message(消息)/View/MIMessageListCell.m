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

- (void)setModel:(MIMessageModel *)model {
    _model = model;
    
    if (model.messageModel.type == MIMessageTypeNone) {
        _numLab.hidden = YES;
        _timeLab.hidden = YES;
        _extendBtn.hidden = NO;
        [_userIconBtn setImage:[UIImage imageNamed:@"icon_message_app_nor"] forState:UIControlStateNormal];
        _titleLab.text = [MILocalData appLanguage:@"other_key_3"];
    } else {
        if (model.messageModel.type == MIMessageTypePush) {
            [_userIconBtn setImage:[UIImage imageNamed:@"icon_message_app_nor"] forState:UIControlStateNormal];
            
            _titleLab.text = [MILocalData appLanguage:@"other_key_3"];
            _contentLab.text = model.messageModel.title;
        } else {
            NSString *imgUrl = [NSString stringWithFormat:@"%@?x-oss-process=image/resize,m_fill,h_40,w_40", model.messageModel.avatar];
            [_userIconBtn sd_setImageWithURL:[NSURL URLWithString:imgUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"icon_personal_head_nor"]];
            
            NSString *title = model.messageModel.nickname;
            if (model.messageModel.type == MIMessageTypeComment || model.messageModel.type == MIMessageTypeCommentComment) {
                title = [NSString stringWithFormat:@"%@ 评论了你", model.messageModel.nickname];
            } else if (model.messageModel.type == MIMessageTypePraise || model.messageModel.type == MIMessageTypeCommentPraise) {
                title = [NSString stringWithFormat:@"%@ 赞了你", model.messageModel.nickname];
            } else if (model.messageModel.type == MIMessageTypeLetter || model.messageModel.type == MIMessageTypeLetterImage) {
                title = [NSString stringWithFormat:@"%@ 私信了你", model.messageModel.nickname];
            }
            _titleLab.text = title;
            _contentLab.text = model.messageModel.comContent;
            
            if (model.messageModel.type == MIMessageTypeLetter) {
                _contentLab.text = model.messageModel.content;
            }
            
            if (model.messageModel.type == MIMessageTypeLetterImage) {
                _contentLab.text = [NSString stringWithFormat:@"%@给你发送了图片", model.messageModel.nickname];
            }
        }
        
        _numLab.hidden = NO;
        _timeLab.hidden = NO;
        _extendBtn.hidden = YES;
        
        NSArray *strs = [model.messageModel.created_at componentsSeparatedByString:@" "];
        NSDate *date = [NSDate date:model.messageModel.created_at WithFormat:@"yyyy-MM-dd"];
        if ([date isToday]) {
            _timeLab.text = strs.lastObject;
        } else if ([date isYesterday]) {
            _timeLab.text = [MILocalData appLanguage:@"other_key_4"];
        } else {
            _timeLab.text = strs.firstObject;
        }
    }
}

- (void)setMessageModel:(MIMessageListModel *)messageModel {
    _messageModel = messageModel;
    
    if (messageModel.type == MIMessageTypeNone) {
        _numLab.hidden = YES;
        _timeLab.hidden = YES;
        _extendBtn.hidden = NO;
        [_userIconBtn setImage:[UIImage imageNamed:@"icon_message_app_nor"] forState:UIControlStateNormal];
        _titleLab.text = [MILocalData appLanguage:@"other_key_3"];
    } else {
        if (messageModel.type == MIMessageTypePush) {
            [_userIconBtn setImage:[UIImage imageNamed:@"icon_message_app_nor"] forState:UIControlStateNormal];
            
            _titleLab.text = [MILocalData appLanguage:@"other_key_3"];
            _contentLab.text = messageModel.title;
        } else {
            NSString *imgUrl = [NSString stringWithFormat:@"%@?x-oss-process=image/resize,m_fill,h_40,w_40", messageModel.avatar];
            [_userIconBtn sd_setImageWithURL:[NSURL URLWithString:imgUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"icon_personal_head_nor"]];
            
            NSString *title = messageModel.nickname;
            if (messageModel.type == MIMessageTypeComment || messageModel.type == MIMessageTypeCommentComment) {
                title = [NSString stringWithFormat:@"%@ 评论了你的", messageModel.nickname];
            } else if (messageModel.type == MIMessageTypePraise || messageModel.type == MIMessageTypeCommentPraise) {
                title = [NSString stringWithFormat:@"%@ 赞了你", messageModel.nickname];
            } else if (messageModel.type == MIMessageTypeLetter || messageModel.type == MIMessageTypeLetterImage) {
                title = [NSString stringWithFormat:@"%@ 私信了你", messageModel.nickname];
            }
            _titleLab.text = title;
            _contentLab.text = messageModel.comContent;
            
            if (messageModel.type == MIMessageTypeLetter) {
                _contentLab.text = messageModel.content;
            }
            
            if (messageModel.type == MIMessageTypeLetterImage) {
                _contentLab.text = [NSString stringWithFormat:@"%@给你发送了图片", messageModel.nickname];
            }
        }
        
        _numLab.hidden = NO;
        _timeLab.hidden = NO;
        _extendBtn.hidden = YES;
        
        NSArray *strs = [messageModel.created_at componentsSeparatedByString:@" "];
        NSDate *date = [NSDate date:messageModel.created_at WithFormat:@"yyyy-MM-dd"];
        if ([date isToday]) {
            _timeLab.text = strs.lastObject;
        } else if ([date isYesterday]) {
            _timeLab.text = [MILocalData appLanguage:@"other_key_4"];
        } else {
            _timeLab.text = strs.firstObject;
        }
    }
}

- (void)setMessageCount:(NSInteger)count {
    if (count <= 0) {
        _numLab.hidden = YES;
    } else {
        _numLab.hidden = NO;
        _numLab.text = [NSString stringWithFormat:@"%ld", count];
    }
}

@end
