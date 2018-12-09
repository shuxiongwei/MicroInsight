//
//  MILocalData.h
//  MicroInsight
//
//  Created by 舒雄威 on 2018/12/3.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MILocalData : NSObject

/**
 设置当前登录用户名

 @param username 用户名
 */
+ (void)setCurrentLoginUsername:(NSString *)username;

/**
 获取当前登录用户名

 @return 返回用户名
 */
+ (NSString *)getCurrentLoginUsername;

/**
 设置当前请求token

 @param token token
 */
+ (void)setCurrentRequestToken:(NSString *)token;

/**
 获取当前请求token

 @return 返回token
 */
+ (NSString *)getCurrentRequestToken;

/**
 获取本地的第一个图片或视频路径

 @return 返回值
 */
+ (NSString *)getFirstLocalAssetPath;

@end

NS_ASSUME_NONNULL_END
