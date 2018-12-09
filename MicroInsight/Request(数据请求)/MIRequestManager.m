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
static NSString * const communityCommentUrl = @"/node/comment-list";
static NSString * const praiseUrl = @"/node/like";
static NSString * const commentUrl = @"/node/comment";
static NSString * const uploadImageUrl = @"/image/upload";

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
    
    [MIRequestManager sharedManager].responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"multipart/form-data", @"application/json", @"text/html", @"image/jpeg", @"image/png", @"application/octet-stream", @"text/json", nil];
    
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

@end
