//
//  MICommunityVideoInfo.h
//  MicroInsight
//
//  Created by J on 2018/12/10.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface MIVideoTag : NSObject

@property (nonatomic, copy) NSString *tag_id;
@property (nonatomic, copy) NSString *title;

@end

@interface MIPlayerInfo : NSObject

@property (nonatomic, copy) NSString *playUrl;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, copy) NSString *definition;

@end

@interface MICommunityVideoInfo : MIBaseModel

@property (nonatomic, copy) NSString *videoId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *likes;
@property (nonatomic, copy) NSString *comments;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, copy) NSArray<MIVideoTag *> *tags;
@property (nonatomic, copy) NSString *coverUrl;
@property (nonatomic, copy) NSArray<MIPlayerInfo *> *playUrlList;
@property (nonatomic, assign) BOOL isLike;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, assign) NSInteger readings;

@property (nonatomic, assign) CGFloat viewHeight; //自定义字段

@end

NS_ASSUME_NONNULL_END
