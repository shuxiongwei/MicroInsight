//
//  MIRequestManager.m
//  MicroInsight
//
//  Created by 舒雄威 on 2018/12/3.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "MIRequestManager.h"

//测试地址
static NSString * const requestUrl = @"http://122.14.225.235:8080/test/api/web/index.php";
//正式地址
//static NSString * const requestUrl = @"https://api.tipscope.com";
static NSString * const registerUrl = @"/site/register";
static NSString * const messageCodeUrl = @"/site/send-sms-verify-code";
static NSString * const mobileRegisterUrl = @"/site/register-mobile";
static NSString * const loginUrl = @"/site/login";
static NSString * const loginByQQUrl = @"/site/qq-login";
static NSString * const loginByWXUrl = @"/site/weixin-login";
static NSString * const communityListUrl = @"/node/list";
static NSString * const myCommunityListUrl = @"/node/my";
static NSString * const communityDetailUrl = @"/image/detail";
static NSString * const communityCommentUrl = @"/node/comment-list";
static NSString * const praiseUrl = @"/node/like";
static NSString * const commentUrl = @"/node/comment";
static NSString * const uploadImageUrl = @"/image/upload";
static NSString * const uploadVideoUrl = @"/video/create";
static NSString * const checkSensitiveWordUrl = @"/site/check-sensitive-word";
static NSString * const reportUserUrl = @"/user-report/report";
static NSString * const modifyUserInfoUrl = @"/user/update-profile";
static NSString * const uploadUserAvatarUrl = @"/user/upload-avatar";
static NSString * const getUserInfoUrl = @"/user/info";
static NSString * const addBlackListUrl = @"/user-black/add";
static NSString * const cancelBlackListUrl = @"/user-black/cancel";
static NSString * const blackListUrl = @"/user-black/list";
static NSString * const forgetPasswordUrl = @"/site/forget-login";
static NSString * const loginByAuthCodeUrl = @"/site/login-mobile";

@implementation MIRequestManager

+ (MIRequestManager *)sharedManager {
    static MIRequestManager *manager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        manager = [[MIRequestManager alloc] init];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"multipart/form-data", @"application/json", @"text/html", @"image/jpeg", @"image/png", @"application/octet-stream", @"text/json", nil];
    });
    
    return manager;
}

+ (void)getApi:(NSString *)path parameters:(id)params completed:(void (^)(id jsonData, NSError *error))completed {
    
    [[MIRequestManager sharedManager] GET:path parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSLog(@"AFHTTPSessionManager GET responseURL:%@",httpResponse.URL);
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
        NSLog(@"AFHTTPSessionManager GET responseURL:%@",httpResponse.URL);
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
        
        completed(jsonData, error);
    }];
}

+ (void)registerWithMobile:(NSString *)mobile password:(NSString *)password verifyToken:(NSString *)verifyToken verifyCode:(NSString *)verifyCode completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"mobile"] = mobile;
    params[@"password"] = password;
    params[@"verifyToken"] = verifyToken;
    params[@"verifyCode"] = verifyCode;
    
    NSString *url = [requestUrl stringByAppendingString:mobileRegisterUrl];
    [MIRequestManager postApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)getMessageVerificationCodeWithMobile:(NSString *)mobile type:(NSInteger)type completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"mobile"] = mobile;
    params[@"type"] = @(type);
    
    NSString *url = [requestUrl stringByAppendingString:messageCodeUrl];
    [MIRequestManager postApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
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

+ (void)loginByQQWithOpenId:(NSString *)openId accessToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"openId"] = openId;
    params[@"accessToken"] = token;
    
    NSString *url = [requestUrl stringByAppendingString:loginByQQUrl];
    [MIRequestManager postApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)loginByWXWithCode:(NSString *)code completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"code"] = code;
    
    NSString *url = [requestUrl stringByAppendingString:loginByWXUrl];
    [MIRequestManager postApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)forgetPasswordLoginWithUsername:(NSString *)username password:(NSString *)password verifyToken:(NSString *)verifyToken verifyCode:(NSString *)verifyCode completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"mobile"] = username;
    params[@"password"] = password;
    params[@"verifyToken"] = verifyToken;
    params[@"verifyCode"] = verifyCode;
    
    NSString *url = [requestUrl stringByAppendingString:forgetPasswordUrl];
    [MIRequestManager postApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)loginWithMobile:(NSString *)mobile verifyToken:(NSString *)verifyToken verifyCode:(NSString *)verifyCode completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"mobile"] = mobile;
    params[@"verifyToken"] = verifyToken;
    params[@"verifyCode"] = verifyCode;
    
    NSString *url = [requestUrl stringByAppendingString:forgetPasswordUrl];
    [MIRequestManager postApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)getCommunityDataListWithSearchTitle:(NSString *)title requestToken:(NSString *)token page:(NSInteger)page pageSize:(NSInteger)pageSize isMine:(BOOL)mine completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"title"] = title;
    params[@"token"] = token;
    params[@"page"] = @(page);
    params[@"pageSize"] = @(pageSize);
    
    NSString *url = [requestUrl stringByAppendingString:communityListUrl];
    if (mine) {
        url = [requestUrl stringByAppendingString:myCommunityListUrl];
    }
    
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

+ (void)getCommunityCommentListWithContentId:(NSString *)contentId contentType:(NSInteger)contentType requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"contentId"] = @(contentId.integerValue);
    params[@"contentType"] = @(contentType);
    params[@"token"] = token;
    
    NSString *url = [requestUrl stringByAppendingString:communityCommentUrl];
    [MIRequestManager getApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)praiseWithContentId:(NSString *)contentId contentType:(NSInteger)contentType requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"contentType"] = @(contentType);
    params[@"contentId"] = @(contentId.integerValue);
    
    NSString *url = [requestUrl stringByAppendingString:praiseUrl];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?token=%@", token]];
    [MIRequestManager postApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)commentWithContentId:(NSString *)contentId contentType:(NSInteger)contentType content:(NSString *)content requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"contentId"] = @(contentId.integerValue);
    params[@"contentType"] = @(contentType);
    params[@"content"] = content;
    
    NSString *url = [requestUrl stringByAppendingString:commentUrl];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?token=%@", token]];
    [MIRequestManager postApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)uploadImageWithFile:(NSString *)file fileName:(NSString *)fileName filePath:(NSString *)path title:(NSString *)title tags:(NSArray *)tags requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"title"] = title;
    params[@"tags"] = tags;
    
    NSString *url = [requestUrl stringByAppendingString:uploadImageUrl];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?token=%@", token]];
    
    //[MIRequestManager sharedManager].responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"multipart/form-data", @"application/json", @"text/html", @"image/jpeg", @"image/png", @"application/octet-stream", @"text/json", nil];
    
    [[MIRequestManager sharedManager] POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        UIImage *img = [UIImage imageWithContentsOfFile:path];
        NSData *datas = UIImageJPEGRepresentation(img, 0.1);
        [formData appendPartWithFileData:datas name:file fileName:fileName mimeType:@"image/jpg"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completed(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completed(nil, error);
    }];
}

+ (void)uploadVideoWithTitle:(NSString *)title videoId:(NSString *)videoId tags:(NSArray *)tags requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"title"] = title;
    params[@"aliyunVideoId"] = videoId;
    params[@"tags"] = tags;
    
    NSString *url = [requestUrl stringByAppendingString:uploadVideoUrl];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?token=%@", token]];
    
    [MIRequestManager postApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)checkSensitiveWord:(NSString *)content completed:(void (^)(id _Nonnull, NSError * _Nonnull))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"text"] = content;
    
    NSString *url = [requestUrl stringByAppendingString:checkSensitiveWordUrl];
    [MIRequestManager postApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)reportUseWithUserId:(NSString *)userId reportContent:(NSString *)content requestToken:(NSString *)token completed:(void (^)(id _Nonnull, NSError * _Nonnull))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userId"] = userId;
    params[@"content"] = content;
    
    NSString *url = [requestUrl stringByAppendingString:reportUserUrl];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?token=%@", token]];
    
    [MIRequestManager postApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)getCurrentLoginUserInfoWithRequestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = token;
    
    NSString *url = [requestUrl stringByAppendingString:getUserInfoUrl];
    [MIRequestManager getApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)modifyUserInfoWithNickname:(NSString *)nickname gender:(NSString *)gender birthday:(NSString *)birthday requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"nickname"] = nickname;
    params[@"gender"] = @(gender.integerValue);
    params[@"birthday"] = birthday;
    
    NSString *url = [requestUrl stringByAppendingString:modifyUserInfoUrl];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?token=%@", token]];
    
    [MIRequestManager postApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)uploadUserAvatarWithFile:(NSString *)file fileName:(NSString *)fileName avatar:(UIImage *)avatar requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSString *url = [requestUrl stringByAppendingString:uploadUserAvatarUrl];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?token=%@", token]];
    
    [[MIRequestManager sharedManager] POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {

        NSData *datas = UIImageJPEGRepresentation(avatar, 0.5);
        [formData appendPartWithFileData:datas name:file fileName:fileName mimeType:@"image/jpg"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completed(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completed(nil, error);
    }];
}

+ (void)addBlackListWithUserId:(NSString *)userId requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userId"] = userId;
    
    NSString *url = [requestUrl stringByAppendingString:addBlackListUrl];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?token=%@", token]];
    
    [MIRequestManager postApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)cancelBlackListWithUserId:(NSString *)userId requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userId"] = userId;
    
    NSString *url = [requestUrl stringByAppendingString:cancelBlackListUrl];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?token=%@", token]];
    
    [MIRequestManager postApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)getBlackListWithRequestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = token;
    
    NSString *url = [requestUrl stringByAppendingString:blackListUrl];
    [MIRequestManager getApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

@end
