//
//  MICommunityListModel.h
//  MicroInsight
//
//  Created by 舒雄威 on 2018/12/4.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MICommunityTagModel : MIBaseModel

@property (nonatomic, copy) NSString *tag_id;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *node_id;

@end

@interface MICommunityListModel : MIBaseModel

@property (nonatomic, assign) NSInteger contentId;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger contentType;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *coverUrl;
@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, copy) NSArray<MICommunityTagModel *> *tags;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, assign) NSInteger readings;
@property (nonatomic, assign) NSInteger likes;
@property (nonatomic, assign) NSInteger comments;
@property (nonatomic, assign) BOOL isLike;

@property (nonatomic, assign) CGFloat rowHeight;

@end

@interface MICommunityDetailModel : MIBaseModel

@property (nonatomic, assign) NSInteger contentId;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *width;
@property (nonatomic, copy) NSString *height;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *likes;
@property (nonatomic, copy) NSString *comments;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, copy) NSArray<MICommunityTagModel *> *tags;
@property (nonatomic, assign) BOOL isLike;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, assign) NSInteger readings;

@property (nonatomic, assign) CGFloat viewHeight; //自定义字段

@end

@interface MICommunityCommentModel : MIBaseModel

@property (nonatomic, copy) NSString *contentId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *avatar;

@end

@interface MIChildCommentModel : MIBaseModel

@property (nonatomic, assign) NSInteger modelId;
@property (nonatomic, assign) NSInteger content_id;
@property (nonatomic, assign) NSInteger content_type;
@property (nonatomic, assign) NSInteger user_id;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *update_at;
@property (nonatomic, copy) NSString *parent_id;
@property (nonatomic, assign) NSInteger likes;
@property (nonatomic, copy) NSString *tweet_id;

@end

@interface MICommentModel : MIBaseModel

@property (nonatomic, assign) NSInteger modelId;
@property (nonatomic, assign) NSInteger content_id;
@property (nonatomic, assign) NSInteger content_type;
@property (nonatomic, assign) NSInteger user_id;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *update_at;
@property (nonatomic, copy) NSString *parent_id;
@property (nonatomic, assign) NSInteger likes;
@property (nonatomic, copy) NSString *tweet_id;
@property (nonatomic, assign) BOOL isLike;
@property (nonatomic, assign) BOOL isBlack;
@property (nonatomic, assign) NSInteger childCount;
@property (nonatomic, copy) NSArray<MIChildCommentModel *> *child;

@property (nonatomic, assign) CGFloat rowHeight;
@property (nonatomic, assign) CGFloat commentHeight;

//获取cell的高度
- (CGFloat)getRowHeight;
//获取子评论tableview的高度
- (CGFloat)getChildCommentTableViewHeight;

@end

@interface MIPraiseModel : MIBaseModel

@property (nonatomic, copy) NSString *modelId;
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *content_id;
@property (nonatomic, copy) NSString *content_type;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *update_at;
@property (nonatomic, copy) NSString *tweet_id;
@property (nonatomic, copy) NSString *comment_id;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *avatar;

@end

NS_ASSUME_NONNULL_END
