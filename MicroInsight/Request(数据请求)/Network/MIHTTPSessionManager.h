//
//  POHTTPSessionManager.h
//  PublicOpinion
//
//  Created by Jonphy on 2018/11/8.
//  Copyright © 2018 Xiamen Juhu Network Techonology Co.,Ltd. All rights reserved.
//

#import "AFNetworking.h"

@interface MIHTTPSessionManager : AFHTTPSessionManager

/**
 创建数据请求的单例
 
 @return 单例
 */
+ (instancetype)shareManager;

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

@end
