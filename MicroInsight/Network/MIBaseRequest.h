//
//  POBaseRequest.h
//  PublicOpinion
//
//  Created by Jonphy on 2018/11/8.
//  Copyright © 2018 Xiamen Juhu Network Techonology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
//#import "POModelMapper.h"
#import "YYModel.h"

typedef void (^PONetworkRequestSuccessArray)(NSArray *modelList, NSString *message);
typedef void (^PONetworkRequestSuccessContent)(NSString *content,NSString *message);
typedef void (^PONetworkRequestSuccessVoid)(NSString *message);
typedef void (^PONetworkRequestFailure)(NSError *error);
typedef void (^PONetworkSessionSuccess)(NSURLSessionDataTask * task, id responseObject);
typedef void (^PONetworkSessionFailure)(NSURLSessionDataTask * task, NSError * error);


@interface MIBaseRequest : NSObject

- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                 downProgress:(void (^)(NSProgress *progress))downProgress
                      success:(PONetworkSessionSuccess)success
                      failure:(PONetworkSessionFailure)failure ;

- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
                  downProgress:(void (^)(NSProgress *progress))downProgress
                       success:(PONetworkSessionSuccess)success
                       failure:(PONetworkSessionFailure)failure;

- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
                  downProgress:(void (^)(NSProgress *progress))downProgress
     constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                       success:(PONetworkSessionSuccess)success
                       failure:(PONetworkSessionFailure)failure;


@end
