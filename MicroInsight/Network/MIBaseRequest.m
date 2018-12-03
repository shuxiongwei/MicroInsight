
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

    return [[MIHTTPSessionManager shareManager] GET:URLString parameters:parameters progress:nil success:success failure:failure];
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
                  downProgress:(void (^)(NSProgress *progress))downProgress
                       success:(MINetworkSessionSuccess)success
                       failure:(MINetworkSessionFailure)failure{
    
    NSMutableDictionary *dic = parameters;
//    if ([dic.allKeys containsObject:@"token"]) {
//
//        POUserInfo *info = [POLocalManager getUserInfo];
//        if (info) {
//            dic = [NSMutableDictionary dictionaryWithDictionary:dic];
//            [dic setObject:info.userId forKey:@"userId"];
//        }
//    }
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
    
//    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
//    NSString *token = [def objectForKey:@"token"];
//    if (token.length == 0 && ![URLString isEqualToString:tokenRequestApi]) {
//        [SVProgressHUD showErrorWithStatus:@"token失效，请杀掉进程重启应用"];
//        return nil;
//    }
//    NSMutableDictionary *mutDictionary = [NSMutableDictionary dictionaryWithDictionary:parameters];
//    mutDictionary[@"_t"] = token;
//    NSString *encodedString = [self desEncoderWithParameter:mutDictionary];
//    NSDictionary *encodeDic = @{@"_param":mutDictionary};
    return [[MIHTTPSessionManager shareManager] POST:URLString parameters:parameters constructingBodyWithBlock:block progress:downProgress success:success failure:failure];
}


@end
