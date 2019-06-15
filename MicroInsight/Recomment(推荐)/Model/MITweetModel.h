//
//  MITweetModel.h
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/14.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MITweetModel : MIBaseModel

@property (nonatomic, assign) NSInteger modelId;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, assign) NSInteger readings;
@property (nonatomic, assign) NSInteger likes;
@property (nonatomic, assign) NSInteger comments;
@property (nonatomic, assign) BOOL isLike;

@end


@interface MITweetSectionModel : MIBaseModel

@property (nonatomic, assign) NSInteger modelId;
@property (nonatomic, assign) NSInteger tweet_id;
@property (nonatomic, assign) NSInteger section_id;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *type; //类型（1、文本，2、图片，3、视频）
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, assign) CGFloat contentHeight;

@end

NS_ASSUME_NONNULL_END
