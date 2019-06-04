//
//  POBaseRequest.h
//  PublicOpinion
//
//  Created by Jonphy on 2018/11/8.
//  Copyright © 2018 Xiamen Juhu Network Techonology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "MIModelMapper.h"
#import "YYModel.h"

typedef void (^MINetworkRequestSuccessArray)(NSArray *modelList, NSString *message);
typedef void (^MINetworkRequestSuccessContent)(NSString *content,NSString *message);
typedef void (^MINetworkRequestSuccessVoid)(NSString *message);
typedef void (^MINetworkRequestFailure)(NSError *error);
typedef void (^MINetworkSessionSuccess)(NSURLSessionDataTask * task, id responseObject);
typedef void (^MINetworkSessionFailure)(NSURLSessionDataTask * task, NSError * error);


@interface MIBaseRequest : NSObject

- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                 downProgress:(void (^)(NSProgress *progress))downProgress
                      success:(MINetworkSessionSuccess)success
                      failure:(MINetworkSessionFailure)failure ;

- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
                  downProgress:(void (^)(NSProgress *progress))downProgress
                       success:(MINetworkSessionSuccess)success
                       failure:(MINetworkSessionFailure)failure;

- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
                  downProgress:(void (^)(NSProgress *progress))downProgress
     constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                       success:(MINetworkSessionSuccess)success
                       failure:(MINetworkSessionFailure)failure;


@end
