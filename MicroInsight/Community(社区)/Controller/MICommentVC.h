//
//  MICommentVC.h
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/8.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MICommunityListModel;
@class MICommentModel;
@interface MICommentVC : UIViewController

@property (nonatomic, strong) MICommunityListModel *communityModel;

@property (nonatomic, copy) void (^clickUserIcon)(NSInteger userId);
@property (nonatomic, copy) void (^clickCommentReplay)(MICommentModel *model);

@end

NS_ASSUME_NONNULL_END
