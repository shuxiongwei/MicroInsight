
//
//  POBaseRequest.m
//  PublicOpinion
//
//  Created by Jonphy on 2018/11/8.
//  Copyright © 2018 Xiamen Juhu Network Techonology Co.,Ltd. All rights reserved.
//

#import "MIBaseRequest.h"
#import "MIHTTPSessionManager.h"
#import "SVProgressHUD.h"
#import "MINetworkConstant.h"
#import "MILocalData.h"
//#import "RSAUtil.h"
//#import "CRSA.h"
#import "MJRefresh.h"

@interface MIBaseRequest ()
{
    NSString* AES_KEY;
}

@end

@implementation MIBaseRequest


- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                 downProgress:(void (^)(NSProgress *progress))downProgress
                      success:(MINetworkSessionSuccess)success
                      failure:(MINetworkSessionFailure)failure{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:parameters];
    NSString *token = [MILocalData getCurrentRequestToken];
    if (token.length > 0) {
        
        [dic setObject:token forKey:@"token"];
    }
    return [[MIHTTPSessionManager shareManager] GET:URLString parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        success(task,responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(task,error);
    }];
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
                  downProgress:(void (^)(NSProgress *progress))downProgress
                       success:(MINetworkSessionSuccess)success
                       failure:(MINetworkSessionFailure)failure{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:parameters];
    NSString *token = [MILocalData getCurrentRequestToken];
    if (token.length > 0) {
        
       URLString = [URLString stringByAppendingString:[NSString stringWithFormat:@"?token=%@",token]];
    }

//    NSError *error;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&error];
//    NSString *string = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    CRSA *c = [CRSA shareInstance];
//    [c writePukWithKey:ApiRSAPubKey];
//    NSString *encryptStr = [c encryptByRsaWith:string keyType:KeyTypePublic];
//
//    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
//    NSString *appVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
//
//    id dataDic = @{@"version" : appVersion,@"platform" : AppPlatform, @"data" : encryptStr};
//
//    if ([dic.allKeys containsObject:@"method"]) {
//        dataDic = [self jsonStringWithPrettyPrint:NO withDictionary:dataDic];
//        [POHTTPSessionManager shareManager].requestSerializer = [AFJSONRequestSerializer serializer];
//    }else{
//        [POHTTPSessionManager shareManager].requestSerializer = [AFHTTPRequestSerializer serializer];
//    }
//
//    if (![URLString isEqualToString:ApiAuctionWebSocketUrPOase] && ![URLString isEqualToString:@"auctionListInfo"] && ![URLString isEqualToString:@"airdropinfo/getList"] && ![URLString isEqualToString:@"versioninfo/getVersion"]) {
//            [SVProgressHUD show];
//    }

    return [[MIHTTPSessionManager shareManager] POST:URLString parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    
        success(task,responseObject);
//        DLog(@"successResponse");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(task,error);
//        DLog(@"failureResponse");
    }];
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
                  downProgress:(void (^)(NSProgress *progress))downProgress
     constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                       success:(MINetworkSessionSuccess)success
                       failure:(MINetworkSessionFailure)failure{
    
    return [[MIHTTPSessionManager shareManager] POST:URLString parameters:parameters constructingBodyWithBlock:block progress:downProgress success:success failure:failure];
}


@end
