//
//  MIRequestManager.m
//  MicroInsight
//
//  Created by 舒雄威 on 2018/12/3.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "MIRequestManager.h"

//测试地址
//static NSString * const requestUrl = @"http://122.14.225.235:8080/test/api/web/index.php";
//正式地址
static NSString * const requestUrl = @"https://api.tipscope.com";
static NSString * const registerUrl = @"/site/register";
static NSString * const messageCodeUrl = @"/site/send-sms-verify-code";
static NSString * const mobileRegisterUrl = @"/site/register-mobile";
static NSString * const loginUrl = @"/site/login";
static NSString * const loginByQQUrl = @"/site/qq-login";
static NSString * const loginByWXUrl = @"/site/weixin-login";
static NSString * const loginByFacebookUrl = @"/site/facebook-login";
static NSString * const communityListUrl = @"/node/list";
static NSString * const myCommunityListUrl = @"/node/my";
static NSString * const otherCommunityListUrl = @"/node/visitor";
static NSString * const communityDetailUrl = @"/node/get-detail";
static NSString * const communityCommentUrl = @"/node/comment-lists";
static NSString * const communityChildCommentUrl = @"/node/get-comment";
static NSString * const praiseUrl = @"/node/like";
static NSString * const praiseCommentUrl = @"/node/comment-like";
static NSString * const commentUrl = @"/node/comment";
static NSString * const commentProductionCommentUrl = @"/node/comment-comment";
static NSString * const uploadImageUrl = @"/image/upload";
static NSString * const uploadVideoUrl = @"/video/create";
static NSString * const checkSensitiveWordUrl = @"/site/check-sensitive-word";
static NSString * const reportUserUrl = @"/user-report/report";
static NSString * const modifyUserInfoUrl = @"/user/update-profile";
static NSString * const uploadUserAvatarUrl = @"/user/upload-avatar";
static NSString * const getUserInfoUrl = @"/user/info";
static NSString * const addBlackListUrl = @"/user/blacklist";
static NSString * const cancelBlackListUrl = @"/user-black/cancel";
static NSString * const blackListUrl = @"/user-black/list";
static NSString * const forgetPasswordUrl = @"/site/forget-login";
static NSString * const loginByAuthCodeUrl = @"/site/login-mobile";
static NSString * const recommendListUrl = @"/tweet/get-tweets";
static NSString * const getAllNotReadMessageUrl = @"/message/get-messages";
static NSString * const getMessageResorceUrl = @"/message/show-comment-source";
static NSString * const getTweetMessageUrl = @"/message/get-tweet";
static NSString * const readMessageUrl = @"/message/callback";
static NSString * const getSingleTweetUrl = @"/tweet/get-tweet";
static NSString * const praiseTweetUrl = @"/tweet/like";
static NSString * const praiseTweetCommentUrl = @"/tweet/comment-like";
static NSString * const getTweetUrl = @"/tweet/tweet-comment";
static NSString * const commentTweetUrl = @"/tweet/comment";
static NSString * const commentTweetCommentUrl = @"/tweet/comment-comment";
static NSString * const tweetChildCommentUrl = @"/tweet/get-comment";
static NSString * const otherProductionListUrl = @"/user/user-info";
static NSString * const userFeedbackUrl = @"/user/feedback";

@implementation MIRequestManager

+ (MIRequestManager *)sharedManager {
    static MIRequestManager *manager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        manager = [[MIRequestManager alloc] init];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"multipart/form-data", @"application/json", @"text/html", @"image/jpeg", @"image/png", @"application/octet-stream", @"text/json", @"text/javascript", nil];
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

+ (void)loginByFacebookWithDic:(NSDictionary *)dic completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userId"] = [NSString stringWithFormat:@"%ld", [dic[@"id"] integerValue]];
    params[@"userName"] = dic[@"name"];
    if ([dic[@"gender"] isEqualToString:@"male"]) {
        params[@"gender"] = @"0";
    } else {
       params[@"gender"] = @"1";
    }
    params[@"avatar"] = [[[dic objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
    
    if (![MIHelpTool isBlankString:dic[@"email"]]) {
        params[@"email"] = dic[@"email"];
    }
    
    NSString *url = [requestUrl stringByAppendingString:loginByFacebookUrl];
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
    
    NSString *url = [requestUrl stringByAppendingString:loginByAuthCodeUrl];
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

+ (void)getOtherCommunityDataListWithUserId:(NSInteger)userId requestToken:(NSString *)token page:(NSInteger)page pageSize:(NSInteger)pageSize completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"id"] = @(userId);
    params[@"token"] = token;
    params[@"page"] = @(page);
    params[@"pageSize"] = @(pageSize);
    
    NSString *url = [requestUrl stringByAppendingString:otherCommunityListUrl];
    
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

+ (void)getCommunityDetailDataWithContentId:(NSInteger)contentId contentType:(NSInteger)contentType requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"contentId"] = @(contentId);
    params[@"contentType"] = @(contentType);
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

+ (void)getCommunityCommentAndChildCommentListWithContentId:(NSInteger)contentId contentType:(NSInteger)contentType commentId:(NSInteger)commentId requestToken:(NSString *)token page:(NSInteger)page pageSize:(NSInteger)pageSize completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"contentId"] = @(contentId);
    params[@"contentType"] = @(contentType);
    params[@"commentId"] = @(commentId);
    params[@"page"] = @(page);
    params[@"pageSize"] = @(pageSize);
    params[@"token"] = token;
    
    NSString *url = [requestUrl stringByAppendingString:communityChildCommentUrl];
    [MIRequestManager getApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)praiseWithContentId:(NSInteger)contentId contentType:(NSInteger)contentType requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"contentType"] = @(contentType);
    params[@"contentId"] = @(contentId);
    
    NSString *url = [requestUrl stringByAppendingString:praiseUrl];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?token=%@", token]];
    [MIRequestManager postApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)praiseCommunityCommentWithContentId:(NSInteger)contentId contentType:(NSInteger)contentType commentId:(NSInteger)commentId requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"contentType"] = @(contentType);
    params[@"contentId"] = @(contentId);
    params[@"commentId"] = @(commentId);
    
    NSString *url = [requestUrl stringByAppendingString:praiseCommentUrl];
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

+ (void)commentProductionCommentWithContentId:(NSInteger)contentId contentType:(NSInteger)contentType commentId:(NSInteger)commentId content:(NSString *)content requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"contentId"] = @(contentId);
    params[@"contentType"] = @(contentType);
    params[@"commentId"] = @(commentId);
    params[@"content"] = content;
    
    NSString *url = [requestUrl stringByAppendingString:commentProductionCommentUrl];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?token=%@", token]];
    [MIRequestManager postApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)uploadImageWithFile:(NSString *)file fileName:(NSString *)fileName image:(UIImage *)image title:(NSString *)title tags:(NSArray *)tags requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"title"] = title;
    params[@"tags"] = tags;
    
    NSString *url = [requestUrl stringByAppendingString:uploadImageUrl];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?token=%@", token]];
    
    //[MIRequestManager sharedManager].responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"multipart/form-data", @"application/json", @"text/html", @"image/jpeg", @"image/png", @"application/octet-stream", @"text/json", nil];
    
    [[MIRequestManager sharedManager] POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {

        NSData *datas = UIImageJPEGRepresentation(image, 0.1);
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

+ (void)modifyUserInfoWithNickname:(NSString *)nickname gender:(NSInteger)gender birthday:(NSString *)birthday profession:(NSInteger)profession requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"nickname"] = nickname;
    params[@"gender"] = @(gender);
    params[@"birthday"] = birthday;
    params[@"profession"] = @(profession);
    
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
    params[@"id"] = @(userId.integerValue);
    
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

+ (void)getOtherUserInfoWithUserId:(NSInteger)userId requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = token;
    params[@"id"] = @(userId);
    
    NSString *url = [requestUrl stringByAppendingString:otherProductionListUrl];
    [MIRequestManager getApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)getRecommendDataListWithSearchTitle:(NSString *)title requestToken:(NSString *)token page:(NSInteger)page pageSize:(NSInteger)pageSize completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"title"] = title;
    params[@"token"] = token;
    params[@"page"] = @(page);
    params[@"pageSize"] = @(pageSize);
    
    NSString *url = [requestUrl stringByAppendingString:recommendListUrl];
    
    [MIRequestManager getApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)getSingleTweetWithId:(NSInteger)tweetId requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"id"] = @(tweetId);
    params[@"token"] = token;
    
    NSString *url = [requestUrl stringByAppendingString:getSingleTweetUrl];
    
    [MIRequestManager getApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)praiseTweetWithTweetId:(NSInteger)tweetId requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"id"] = @(tweetId);

    NSString *url = [requestUrl stringByAppendingString:praiseTweetUrl];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?token=%@", token]];
    [MIRequestManager postApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)praiseTweetCommentWithTweetId:(NSInteger)tweetId commentId:(NSInteger)commentId requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"tweetId"] = @(tweetId);
    params[@"commentId"] = @(commentId);
    
    NSString *url = [requestUrl stringByAppendingString:praiseTweetCommentUrl];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?token=%@", token]];
    [MIRequestManager postApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)getTweetCommentsWithTweetId:(NSInteger )tweetId requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"id"] = @(tweetId);
    params[@"token"] = token;
    
    NSString *url = [requestUrl stringByAppendingString:getTweetUrl];
    
    [MIRequestManager getApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)commentTweetWithTweetId:(NSInteger )tweetId content:(NSString *)content requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"id"] = @(tweetId);
    params[@"content"] = content;
    
    NSString *url = [requestUrl stringByAppendingString:commentTweetUrl];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?token=%@", token]];
    [MIRequestManager postApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)commentTweetCommentWithTweetId:(NSInteger)tweetId commentId:(NSInteger)commentId content:(NSString *)content requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"tweetId"] = @(tweetId);
    params[@"commentId"] = @(commentId);
    params[@"content"] = content;
    
    NSString *url = [requestUrl stringByAppendingString:commentTweetCommentUrl];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?token=%@", token]];
    [MIRequestManager postApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)getTweetCommentAndChildCommentListWithTweetId:(NSInteger)tweetId commentId:(NSInteger)commentId requestToken:(NSString *)token page:(NSInteger)page pageSize:(NSInteger)pageSize completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"tweetId"] = @(tweetId);
    params[@"commentId"] = @(commentId);
    params[@"page"] = @(page);
    params[@"pageSize"] = @(pageSize);
    params[@"token"] = token;
    
    NSString *url = [requestUrl stringByAppendingString:tweetChildCommentUrl];
    [MIRequestManager getApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)getAllNotReadMessageWithRequestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = token;

    NSString *url = [requestUrl stringByAppendingString:getAllNotReadMessageUrl];
    
    [MIRequestManager getApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)getMessageSourceWithCommentId:(NSInteger)commentId requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"commentId"] = @(commentId);
    params[@"token"] = token;
    
    NSString *url = [requestUrl stringByAppendingString:getMessageResorceUrl];
    
    [MIRequestManager getApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)readMessageWithMessageIds:(NSArray *)messageIds requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"messageIds"] = messageIds;
    
    NSString *url = [requestUrl stringByAppendingString:readMessageUrl];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?token=%@", token]];
    [MIRequestManager postApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)getTweetMessageWithRequestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = token;
    
    NSString *url = [requestUrl stringByAppendingString:getTweetMessageUrl];
    [MIRequestManager getApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)getCommunityCommentsWithContentId:(NSInteger )contentId contentType:(NSInteger)contentType requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"contentId"] = @(contentId);
    params[@"contentType"] = @(contentType);
    params[@"token"] = token;
    
    NSString *url = [requestUrl stringByAppendingString:communityCommentUrl];
    [MIRequestManager getApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)feedbackWithContent:(NSString *)content requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"feedback"] = content;
    
    NSString *url = [requestUrl stringByAppendingString:userFeedbackUrl];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?token=%@", token]];
    [MIRequestManager postApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

+ (void)checkAppVersionCompleted:(void (^)(id jsonData, NSError *error))completed {
 
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *url = @"https://itunes.apple.com/cn/lookup?id=1433904650";

    [MIRequestManager postApi:url parameters:params completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        completed(jsonData, error);
    }];
}

@end
