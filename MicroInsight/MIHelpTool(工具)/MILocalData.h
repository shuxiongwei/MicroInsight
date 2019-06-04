//
//  MILocalData.h
//  MicroInsight
//
//  Created by 舒雄威 on 2018/12/3.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//多语言
static NSString * const appLanguage = @"appLanguage";
static NSString * const languageMapping = @"languageMapping"; //语言映射关系
#define QSAppLanguage(key)  [[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:appLanguage]] ofType:@"lproj"]] localizedStringForKey:(key) value:nil table:@"Language"]

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

/**
 保存当前相机的标定信息

 @param length 长度(代表1mm)
 */
+ (void)saveCurrentDemarcateInfo:(CGFloat)length;

/**
 获取当前相机的标定信息

 @return 返回值
 */
+ (CGFloat)getCurrentDemarcateInfo;

/**
 设置app的语言
 
 @param lan 语言类型
 */
+ (void)setAppLanguage:(NSString *)lan;

/**
 获取app的语言类型
 
 @return 返回语言类型
 */
+ (NSString *)getAppLanguage;

/**
 设置语言映射
 */
+ (void)setLanguageMapping;

/**
 获取语言映射关系
 
 @return 返回值
 */
+ (NSDictionary *)getLanguageMapping;

/**
 获取app的语言名称
 
 @return 返回语言映射关系
 */
+ (NSString *)getCurrentAppLangugeName;

+ (NSString *)appLanguage:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
