//
//  MIAlbumRequest.m
//  MicroInsight
//
//  Created by J on 2018/12/3.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "MIAlbumRequest.h"
#import "MITheme.h"

@implementation MIAlbumRequest

- (NSURLSessionTask *)themeListWithSuccessResponse:(MINetworkRequestSuccessArray)success failureResponse:(MINetworkRequestFailure)failure{
    NSString *path = @"tag/index";
    return [self GET:path parameters:nil downProgress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dic = responseObject;
        NSArray *array = dic[@"data"][@"list"];
        
        NSArray *list = [MIModelMapper modelArrayWithJsonArray:array modelClass:[MITheme class]];
        success(list,nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        failure(error);
    }];
}

@end
