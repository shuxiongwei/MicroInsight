//
//  MIRequestManager.m
//  MicroInsight
//
//  Created by 舒雄威 on 2018/12/3.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "MIRequestManager.h"

static NSString * const requestUrl = @"http://122.14.225.235:8080/tipscope/api/web/index.php";
static NSString * const registerUrl = @"/site/register";
static NSString * const loginUrl = @"/site/login";
static NSString * const communityListUrl = @"/node/list";
static NSString * const communityDetailUrl = @"/image/detail";
static NSString * const communityCommentUrl = @"/image/comment-list";
static NSString * const praiseUrl = @"/image/like";
static NSString * const commentUrl = @"/image/comment";

@implementation MIRequestManager

+ (MIRequestManager *)sharedManager {
    static MIRequestManager *manager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        manager = [[MIRequestManager alloc] init];
    });
    
    return manager;
}

+ (void)getApi:(NSString *)path parameters:(id)params completed:(void (^)(id jsonData, NSError *error))completed {
    
    [[MIRequestManager sharedManager] GET:path parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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

    [[MIRequestManager sharedManager] POST:path parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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

+ (void)registerWithUsername:(NSString *)username password:(NSString *)password completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"username"] = username;
    params[@"password"] = password;

    NSString *url = [requestUrl stringByAppendingString:registerUrl];
    [MIRequestManager postApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        NSDictionary *data = jsonData[@"data"];
        NSDictionary *user = data[@"user"];
        [MILocalData setCurrentLoginUsername:user[@"username"]];
        [MILocalData setCurrentRequestToken:user[@"token"]];
        
        completed(jsonData, error);
    }];
}

+ (void)loginWithUsername:(NSString *)username password:(NSString *)password completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"username"] = username;
    params[@"password"] = password;
    
    NSString *url = [requestUrl stringByAppendingString:loginUrl];
    [MIRequestManager postApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)getCommunityDataListWithSearchTitle:(NSString *)title requestToken:(NSString *)token page:(NSInteger)page pageSize:(NSInteger)pageSize completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"title"] = title;
    params[@"token"] = token;
    params[@"page"] = @(page);
    params[@"pageSize"] = @(pageSize);
    
    NSString *url = [requestUrl stringByAppendingString:communityListUrl];
    [MIRequestManager getApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)getCommunityDetailDataWithContentId:(NSString *)contentId requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"imageId"] = @(contentId.integerValue);
    params[@"token"] = token;
    
    NSString *url = [requestUrl stringByAppendingString:communityDetailUrl];
    [MIRequestManager getApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)getCommunityCommentListWithContentId:(NSString *)contentId requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"imageId"] = @(contentId.integerValue);
    params[@"token"] = token;
    
    NSString *url = [requestUrl stringByAppendingString:communityCommentUrl];
    [MIRequestManager getApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)praiseWithContentId:(NSString *)contentId requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"imageId"] = @(contentId.integerValue);
    params[@"token"] = token;
    
    NSString *url = [requestUrl stringByAppendingString:praiseUrl];
    [MIRequestManager getApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)commentWithContentId:(NSString *)contentId content:(NSString *)content requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"imageId"] = @(contentId.integerValue);
    params[@"content"] = content;
    params[@"token"] = token;
    
    NSString *url = [requestUrl stringByAppendingString:commentUrl];
    [MIRequestManager getApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

@end
