//
//  MICommunityVideoInfo.m
//  MicroInsight
//
//  Created by J on 2018/12/10.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "MICommunityVideoInfo.h"

@implementation MIVideoTag

@end

@implementation MIPlayerInfo

@end

@implementation MICommunityVideoInfo

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"videoId" : @"id"};
}

@end