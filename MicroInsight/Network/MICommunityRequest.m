//
//  MICommunityRequest.m
//  MicroInsight
//
//  Created by Jonphy on 2018/12/10.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "MICommunityRequest.h"

@implementation MICommunityRequest

- (NSURLSessionTask *)videoInfoWithVideoId:(NSString *)videoID SuccessResponse:(void (^)(MICommunityVideoInfo *info))success failureResponse:(MINetworkRequestFailure)failure{
    
    NSString *path = @"video/detail";
    return [self POST:path parameters:nil downProgress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dic = responseObject;
        MICommunityVideoInfo *info = [MIModelMapper modelWithDictionary:dic[@"data"] modelClass:[MICommunityVideoInfo class]];
        success(info);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        failure(error);
    }];
}

@end
