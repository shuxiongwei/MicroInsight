//
//  MICommentVC.h
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/8.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MICommentType) {
    MICommentTypeCommunity,  //社区作品的评论
    MICommentTypeTweet,      //推文作品的评论
};

@class MICommunityListModel;
@class MICommentModel;
@interface MICommentVC : UIViewController

@property (nonatomic, assign) NSInteger contentId;
@property (nonatomic, assign) NSInteger contentType; //0:图片，1:视频
@property (nonatomic, assign) MICommentType commentType;

@property (nonatomic, copy) void (^clickUserIcon)(NSInteger userId);
@property (nonatomic, copy) void (^clickShowAllChildComment)(MICommentModel *model);
@property (nonatomic, copy) void (^clickParentComment)(MICommentModel *model);

- (void)refreshView;

@end

NS_ASSUME_NONNULL_END
