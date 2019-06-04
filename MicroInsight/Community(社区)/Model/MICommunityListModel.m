//
//  MICommunityListModel.m
//  MicroInsight
//
//  Created by 舒雄威 on 2018/12/4.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "MICommunityListModel.h"

@implementation MICommunityTagModel

@end


@implementation MICommunityListModel

+ (NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{@"tags" : [MICommunityTagModel class]};
}

@end


@implementation MICommunityDetailModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"contentId" : @"id"};
}

@end


@implementation MICommunityCommentModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"contentId" : @"id"};
}

@end



