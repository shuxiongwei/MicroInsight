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

@property (nonatomic, copy) NSString *contentId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *contentType;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *cover_url;
@property (nonatomic, copy) NSString *video_url;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, copy) NSArray<MICommunityTagModel *> *tags;

@end

@interface MICommunityDetailModel : MIBaseModel

@property (nonatomic, copy) NSString *contentId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *width;
@property (nonatomic, copy) NSString *height;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *goodNum;
@property (nonatomic, copy) NSString *commentNum;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, copy) NSArray<MICommunityTagModel *> *tags;
@property (nonatomic, assign) BOOL isLike;

@end

@interface MICommunityCommentModel : MIBaseModel

@property (nonatomic, copy) NSString *contentId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *createdAt;

@end

NS_ASSUME_NONNULL_END
