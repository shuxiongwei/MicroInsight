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

- (NSURLSessionTask *)uploadPhotoWithFile:(NSData *)file title:(NSString *)title tags:(NSArray *)tags SuccessResponse:(MINetworkRequestSuccessVoid)success failureResponse:(MINetworkRequestFailure)failure{
    
    NSString *path = @"image/upload";
    NSDictionary *parameters = @{@"file" : file, @"title" : title, @"tags" : tags};
    return [self POST:path parameters:parameters downProgress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dic = responseObject;
        NSString *msg = dic[@"message"];
        success(msg);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        failure(error);
    }];
}

- (NSURLSessionTask *)videoInfoWithTitle:(NSString *)title SuccessResponse:(void (^)(MIUploadVidoInfo * _Nonnull))success failureResponse:(MINetworkRequestFailure)failure{
    
    NSString *path = @"credential/generate-upload-video-sts";
    return [self POST:path parameters:nil downProgress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dic = responseObject;        
        MIUploadVidoInfo *info = [MIModelMapper modelWithDictionary:dic[@"data"] modelClass:[MIUploadVidoInfo class]];
        success(info);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        failure(error);
    }];
}

@end
