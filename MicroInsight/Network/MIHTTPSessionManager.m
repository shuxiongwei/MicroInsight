
//
//  POHTTPSessionManager.m
//  PublicOpinion
//
//  Created by Jonphy on 2018/11/8.
//  Copyright © 2018 Xiamen Juhu Network Techonology Co.,Ltd. All rights reserved.
//

#import "MIHTTPSessionManager.h"
#import "MIHTTPResponseSerializer.h"
#import "MINetworkConstant.h"
#import "SVProgressHUD.h"
 

@implementation MIHTTPSessionManager

static MIHTTPSessionManager *manager = nil;

+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc]initWithBaseURL:[NSURL URLWithString:ApiMainUrlBase]];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.requestSerializer.timeoutInterval = 10.0;
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
        [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusNotReachable:     // 无连线
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
//                    [[NSNotificationCenter defaultCenter] postNotificationName:LBNetworkDisconnected object:nil];
                        [SVProgressHUD showErrorWithStatus:@"网络连接异常，请检查"];
                    });
                    break;
                case AFNetworkReachabilityStatusReachableViaWWAN: // 手机自带网络
//                    DLog(@"AFNetworkReachability Reachable via WWAN");
//                    [[NSNotificationCenter defaultCenter] postNotificationName:LBNetworkConnected object:nil];
                    break;
                case AFNetworkReachabilityStatusReachableViaWiFi: // WiFi
//                    DLog(@"AFNetworkReachability Reachable via WiFi");
//                    [[NSNotificationCenter defaultCenter] postNotificationName:LBNetworkConnected object:nil];
                    break;
                case AFNetworkReachabilityStatusUnknown:          // 未知网络
                default:
//                    DLog(@"AFNetworkReachability Unknown");
                    break;
            }
            
        }];
        manager.responseSerializer = [MIHTTPResponseSerializer serializer];
        [manager.reachabilityManager startMonitoring];
    });
    return manager;
}

+ (void)getApi:(NSString *)path parameters:(id)params completed:(void (^)(id jsonData, NSError *error))completed {
    
    [[MIHTTPSessionManager shareManager] GET:path parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if (httpResponse.statusCode == 200) { //成功
            if ([responseObject isKindOfClass:[NSData class]]) {
                responseObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completed) {
                    completed(responseObject, nil);
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completed) {
                    completed(nil, nil);
                }
            });
        }
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (completed) {
                completed(nil, error);
            }
        });
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}

+ (void)postApi:(NSString *)path parameters:(id)params completed:(void (^)(id jsonData, NSError *error))completed {

    [[MIHTTPSessionManager shareManager] POST:path parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if (httpResponse.statusCode == 200) {
            if ([responseObject isKindOfClass:[NSData class]]) {
                responseObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completed) {
                    completed(responseObject, nil);
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completed)
                    completed(nil, nil);
            });
        }
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (completed) {
                completed(nil, error);
            }
        });
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                               uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                             downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                            completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))completionHandler{
    void (^errorProcessBlock)(NSURLResponse *, id, NSError *) = ^(NSURLResponse *response, id responseObject, NSError *error) {
        
        NSLog(@"NSHTTPCookieStorage COOKIE %@ ",[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]);
        NSLog(@"AF response headers %@ ",request.allHTTPHeaderFields);
        
        NSError *processError = error;
        if ([error.domain isEqualToString:NSURLErrorDomain]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showErrorWithStatus:@"网络请求失败"];
            });
            NSMutableDictionary *userInfo = [error.userInfo mutableCopy];
            userInfo[NSLocalizedDescriptionKey] = ApiErrorMsgResponseParseError;
            processError = [[NSError alloc] initWithDomain:error.domain code:error.code userInfo:userInfo];
        }
        if (responseObject == nil && error == nil) {
            
            NSMutableDictionary *userInfo = [error.userInfo mutableCopy];
            userInfo[NSLocalizedDescriptionKey] = ApiErrorMsgResponseParseError;
            processError = [[NSError alloc] initWithDomain:@"nil response" code:-10240 userInfo:nil];
        }
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = responseObject;
            
            NSInteger code = [dic[@"status"] integerValue];
            NSString *msg = dic[@"msg"];
            
            //TODO
            if (code != ApiSessionSucessCode) {
                if (msg == nil) {
                    msg = @"网络请求失败";
                }
                processError = [[NSError alloc] initWithDomain:msg code:code userInfo:nil];
            }
        }
        completionHandler(response, responseObject, processError);
    };
    NSURLSessionDataTask *dataTask =  [super dataTaskWithRequest:request uploadProgress:uploadProgressBlock downloadProgress:downloadProgressBlock completionHandler:errorProcessBlock];
    return dataTask;
}

@end
