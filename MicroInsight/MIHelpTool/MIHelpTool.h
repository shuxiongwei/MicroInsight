//
//  MIHelpTool.h
//  MicroInsight
//
//  Created by 舒雄威 on 2018/7/10.
//  Copyright © 2018年 舒雄威. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MIHelpTool : NSObject

/**
 创建时间戳

 @return 返回值
 */
+ (NSString *)timeStampSecond;

/**
 获取沙盒document路径

 @return 返回值
 */
+ (NSString *)getDocumentPath;

+ (NSString *)assetsPath;

+ (NSString *)createAssetsPath;

/**
 根据文件名创建文件夹

 @param component 文件名
 @return 返回值
 */
+ (NSString *)createFolderWithLastComponent:(NSString *)component;

/**
 测量单行文本的宽度
 
 @param str 文本内容
 @param font 字体大小
 @return 返回宽度
 */
+ (CGFloat)measureSingleLineStringWidthWithString:(NSString *)str font:(UIFont *)font;

/**
 测量文本高度
 
 @param str 文本内容
 @param font 字体大小
 @param width 文本宽度
 @return 返回高度
 */
+ (CGFloat)measureMutilineStringHeightWithString:(NSString *)str font:(UIFont *)font width:(CGFloat)width;

/**
 获取视频指定时间点的画面帧

 @param asset 视频资源
 @param curTime 时间点
 @return 返回值
 */
+ (UIImage *)fetchThumbnailWithAVAsset:(AVAsset *)asset curTime:(CGFloat)curTime;

+ (BOOL) isBlankString:(NSString *)str;

/**
 判断 字母、数字、中文
 
 @param str 输入的字符串
 @return 返回值
 */
+ (BOOL)isInputRuleAndNumber:(NSString *)str;

/**
 获得maxLength长度的字符
 
 @param string 输入的字符串
 @return 返回值
 */
+ (NSString *)getSubString:(NSString*)string;

/**
 判断字符串是否含有emoji
 
 @param str 输入的字符串
 @return 返回值
 */
+ (BOOL)hasEmoji:(NSString *)str;

/**
 过滤字符串中的emoji
 
 @param text 输入的字符串
 @return 返回值
 */
+ (NSString *)disable_emoji:(NSString *)text;

/**
 日期转换成字符串
 
 @param date 日期
 @param format 转换格式(如@"yyyy-MM-dd HH:mm:ss")
 @return 返回值
 */
+ (NSString *)converDate:(NSDate *)date toStringByFormat:(NSString *)format;

/**
 时间字符串转日期
 
 @param string 时间字符串
 @param format 转化格式
 @return 返回值
 */
+ (NSDate *)converString:(NSString *)string toDateByFormat:(NSString *)format;

@end
