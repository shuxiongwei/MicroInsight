//
//  MIRequestManager.h
//  MicroInsight
//
//  Created by 舒雄威 on 2018/12/3.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN

@interface MIRequestManager : AFHTTPSessionManager

/**
 创建数据请求的单例
 
 @return 单例
 */
+ (MIRequestManager *)sharedManager;

/**
 GET请求
 
 @param path 路径
 @param params 参数
 @param completed 完成回调
 */
+ (void)getApi:(NSString *)path parameters:(id)params completed:(void(^)(id jsonData, NSError *error))completed;

/**
 POST请求
 
 @param path 路径
 @param params 参数
 @param completed 完成回调
 */
+ (void)postApi:(NSString *)path parameters:(id)params completed:(void(^)(id jsonData, NSError *error))completed;

#pragma mark - 注册
/**
 注册

 @param username 用户名
 @param password 密码
 @param completed 完成回调
 */
+ (void)registerWithUsername:(NSString *)username password:(NSString *)password completed:(void (^)(id jsonData, NSError *error))completed;

#pragma mark - 登录
/**
 登录

 @param username 用户名
 @param password 密码
 @param completed 完成回调
 */
+ (void)loginWithUsername:(NSString *)username password:(NSString *)password completed:(void (^)(id jsonData, NSError *error))completed;

@end

NS_ASSUME_NONNULL_END
