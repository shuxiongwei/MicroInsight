//
//  MIAlbumRequest.m
//  MicroInsight
//
//  Created by J on 2018/12/3.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "MIAlbumRequest.h"

@implementation MIAlbumRequest

- (NSURLSessionTask *)loginWithPhone:(NSString *)phone password:(NSString *)psw  successResponse:(MINetworkRequestSuccessVoid)success failureResponse:(MINetworkRequestFailure)failure{
    NSString *path = @"userinfo/login";
    NSDictionary *parameter = @{@"phone" : phone?:@"",@"password":psw?:@""};
    return [self POST:path parameters:parameter downProgress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dic = responseObject;
        NSDictionary *data = dic[@"data"];
        NSString *token = data[@"token"];
        NSString *upToken = data[@"uptoken"];
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        
        
//        LBUserInfo *user = [LBModelMapper modelWithDictionary:data[@"userInfo"] modelClass:[LBUserInfo class]];
//        NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:user];
//        [def setObject:userData forKey:LBUserInfoKey];
        
        NSString *msg = dic[@"msg"];
        success(msg);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        failure(error);
    }];
}

@end
