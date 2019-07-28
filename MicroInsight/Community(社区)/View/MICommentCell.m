//
//  MICommentCell.m
//  MicroInsight
//
//  Created by 舒雄威 on 2018/12/5.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "MICommentCell.h"
#import "MICommunityListModel.h"
#import "UIButton+WebCache.h"

@implementation MICommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _userBtn.layer.cornerRadius = 20;
    _userBtn.layer.masksToBounds = YES;
    [_supportBtn layoutButtonWithEdgeInsetsStyle:MIButtonEdgeInsetsStyleLeft imageTitleSpace:5];
    [_commentTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    UILongPressGestureRecognizer *longRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self addGestureRecognizer:longRec];
}

- (void)setModel:(MICommentModel *)model {
    _model = model;
    _heightConstraint.constant = model.commentHeight;
    
    NSString *imgUrl = [NSString stringWithFormat:@"%@?x-oss-process=image/resize,m_fill,h_40,w_40", model.avatar];
    [_userBtn sd_setImageWithURL:[NSURL URLWithString:imgUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"icon_personal_head_nor"]];
    
    _titleLab.text = model.nickname;
    NSArray *strs = [model.created_at componentsSeparatedByString:@" "];
    _timeLab.text = strs.firstObject;
    
    [_supportBtn setTitle:[NSString stringWithFormat:@"%ld", model.likes] forState:UIControlStateNormal];
    _supportBtn.selected = model.isLike;
    
    _commentLab.text = model.content;
    
    [_commentTableView reloadData];
}

- (IBAction)clickUserIconBtn:(UIButton *)sender {
    if (self.clickUserIcon) {
        self.clickUserIcon(_model);
    }
}

- (IBAction)clickPraiseBtn:(UIButton *)sender {
    if (_model.isLike) {
        [MIHudView showMsg:[MILocalData appLanguage:@"other_key_11"]];
        return;
    }
    
    if (self.clickPraiseComment) {
        self.clickPraiseComment();
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)rec {
    if (self.longPressComment) {
        self.longPressComment(_model);
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_model.childCount > 2) {
        if (indexPath.row == 2) {
            if (self.clickShowAllChildComment) {
                self.clickShowAllChildComment(_model);
            }
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _model.childCount > 2 ? 3 : _model.childCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 22;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont systemFontOfSize:11];
    
    WSWeak(weakSelf)
    if (_model.childCount > 2) {
        if (indexPath.row < 2) {
            MIChildCommentModel *model = _model.child[indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"%@:%@", model.nickname, model.content];
            cell.textLabel.textColor = UIColorFromRGBWithAlpha(0x333333, 1);
            [cell.textLabel setAttributedStringWithText:[NSString stringWithFormat:@"%@:", model.nickname] color:UIColorFromRGBWithAlpha(0x3189C8, 1) font:11];
            [cell.textLabel yb_addAttributeTapActionWithStrings:@[model.nickname] tapClicked:^(NSString *string, NSRange range, NSInteger index) {
                
                if (weakSelf.clickUserIcon) {
                    weakSelf.clickUserIcon(model);
                }
            }];
        } else {
            cell.textLabel.text = [NSString stringWithFormat:@"共%ld条回复 >", _model.childCount];
            cell.textLabel.textColor = UIColorFromRGBWithAlpha(0x3189C8, 1);
        }
    } else {
        MIChildCommentModel *model = _model.child[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@:%@", model.nickname, model.content];
        cell.textLabel.textColor = UIColorFromRGBWithAlpha(0x333333, 1);
        [cell.textLabel setAttributedStringWithText:[NSString stringWithFormat:@"%@:", model.nickname] color:UIColorFromRGBWithAlpha(0x3189C8, 1) font:11];
        [cell.textLabel yb_addAttributeTapActionWithStrings:@[model.nickname] tapClicked:^(NSString *string, NSRange range, NSInteger index) {
            
            if (weakSelf.clickUserIcon) {
                weakSelf.clickUserIcon(model);
            }
        }];
    }
    
    return cell;
}

@end
