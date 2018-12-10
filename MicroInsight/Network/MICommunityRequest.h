//
//  MICommunityRequest.h
//  MicroInsight
//
//  Created by Jonphy on 2018/12/10.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MIBaseRequest.h"
#import "MICommunityVideoInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface MICommunityRequest : MIBaseRequest

- (NSURLSessionTask *)videoInfoWithVideoId:(NSString *)videoID SuccessResponse:(void(^)(MICommunityVideoInfo *info))success failureResponse:(MINetworkRequestFailure)failure;

@end

NS_ASSUME_NONNULL_END
