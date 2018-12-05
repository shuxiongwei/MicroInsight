//
//  MICommunityListModel.h
//  MicroInsight
//
//  Created by 舒雄威 on 2018/12/4.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MICommunityTagModel : NSObject

@property (nonatomic, copy) NSString *tag_id;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *node_id;

@end

@interface MICommunityListModel : NSObject<YYModel>

@property (nonatomic, copy) NSString *contentId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *contentType;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, copy) NSArray<MICommunityTagModel *> *tags;

@end

NS_ASSUME_NONNULL_END
