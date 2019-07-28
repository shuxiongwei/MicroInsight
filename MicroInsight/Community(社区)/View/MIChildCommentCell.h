//
//  MIChildCommentCell.h
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/17.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MIChildCommentModel;
@interface MIChildCommentCell : UITableViewCell

@property (nonatomic, strong) MIChildCommentModel *model;

@property (nonatomic, copy) void (^clickUserIcon)(MIChildCommentModel *childModel);
@property (nonatomic, copy) void (^clickPraiseComment)(void);

@end

NS_ASSUME_NONNULL_END
