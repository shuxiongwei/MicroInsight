//
//  MICommentCell.h
//  MicroInsight
//
//  Created by 舒雄威 on 2018/12/5.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MICommentModel;
@class MIChildCommentModel;
@interface MICommentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *userBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UILabel *commentLab;
@property (weak, nonatomic) IBOutlet UIButton *supportBtn;
@property (weak, nonatomic) IBOutlet UITableView *commentTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (nonatomic, strong) MICommentModel *model;

@property (nonatomic, copy) void (^clickUserIcon)(MIChildCommentModel *model);
@property (nonatomic, copy) void (^clickShowAllChildComment)(MICommentModel *model);
@property (nonatomic, copy) void (^clickPraiseComment)(void);
@property (nonatomic, copy) void (^longPressComment)(MICommentModel *model);

@end

NS_ASSUME_NONNULL_END
