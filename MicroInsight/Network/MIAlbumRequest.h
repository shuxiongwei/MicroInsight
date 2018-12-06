//
//  MIAlbumRequest.h
//  MicroInsight
//
//  Created by J on 2018/12/3.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "MIBaseRequest.h"
#import "MIUploadVidoInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface MIAlbumRequest : MIBaseRequest

- (NSURLSessionTask *)themeListWithSuccessResponse:(MINetworkRequestSuccessArray)success failureResponse:(MINetworkRequestFailure)failure;

- (NSURLSessionTask *)uploadPhotoWithFile:(NSData *)file title:(NSString *)title tags:(NSArray *)tags SuccessResponse:(MINetworkRequestSuccessVoid)success failureResponse:(MINetworkRequestFailure)failure;

- (NSURLSessionTask *)videoInfoWithTitle:(NSString *)title SuccessResponse:(void(^)(MIUploadVidoInfo *info))success failureResponse:(MINetworkRequestFailure)failure;

@end

NS_ASSUME_NONNULL_END
