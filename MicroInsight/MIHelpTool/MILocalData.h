//
//  MILocalData.h
//  MicroInsight
//
//  Created by 舒雄威 on 2018/12/3.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MIUserInfoModel;
@interface MILocalData : NSObject

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

/**
 保存当前登录用户信息

 @param info 用户信息
 */
+ (void)saveCurrentLoginUserInfo:(nullable MIUserInfoModel *)info;

/**
 获取当前登录用户信息

 @return 用户信息
 */
+ (MIUserInfoModel *)getCurrentLoginUserInfo;

/**
 判断是否已经登录

 @return 返回值
 */
+ (BOOL)hasLogin;

@end

NS_ASSUME_NONNULL_END
