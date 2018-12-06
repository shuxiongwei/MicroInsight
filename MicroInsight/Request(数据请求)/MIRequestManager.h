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

#pragma mark - 社区
/**
 获取社区数据列表

 @param title 检索条件
 @param token token
 @param page 当前页数
 @param pageSize 每页条数
 @param completed 完成回调
 */
+ (void)getCommunityDataListWithSearchTitle:(NSString *)title requestToken:(NSString *)token page:(NSInteger)page pageSize:(NSInteger)pageSize completed:(void (^)(id jsonData, NSError *error))completed;

/**
 获取社区详情数据

 @param contentId 图片id
 @param token token
 @param completed 完成回调
 */
+ (void)getCommunityDetailDataWithContentId:(NSString *)contentId requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed;

/**
 获取评论列表

 @param contentId 图片id
 @param token token
 @param completed 完成回调
 */
+ (void)getCommunityCommentListWithContentId:(NSString *)contentId requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed;

/**
 点赞
 
 @param contentId 图片id
 @param token token
 @param completed 完成回调
 */
+ (void)praiseWithContentId:(NSString *)contentId requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed;

@end

NS_ASSUME_NONNULL_END
