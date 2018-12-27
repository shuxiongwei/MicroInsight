//
//  MIThirdPartyLoginManager.h
//  MicroInsight
//
//  Created by Jonphy on 2018/11/19.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboSDK.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/QQApiInterface.h>


typedef NS_ENUM(NSInteger, MILoginType) {
    MILoginTypeWeiBo = 0,   // 新浪微博
    MILoginTypeTencent,      // QQ
    MILoginTypeWeiXin       // 微信
};

typedef NS_ENUM(NSInteger, MILoginWeiXinErrCode) {
    MILoginWeiXinErrCodeSuccess = 0,
    MILoginWeiXinErrCodeCancel = -2,
};

typedef void(^MIThirdPartyLoginResultBlock)(NSDictionary *loginResult, NSString *error);

@interface MIThirdPartyLoginManager : NSObject<TencentSessionDelegate, TencentLoginDelegate, WBHttpRequestDelegate, WeiboSDKDelegate, WXApiDelegate>

+ (instancetype)shareManager;

/**
 第三方登录

 @param type 登录类型
 @param result 回调
 */
- (void)getUserInfoWithWTLoginType:(MILoginType)type result:(MIThirdPartyLoginResultBlock)result;

/**
 分享到微信朋友圈

 @param title 标题
 @param description 描述
 @param imageUrl 图片地址
 @param videoUrl 视频地址
 @param isVideo 是否分享视频
 */
- (void)shareByWXWithTitle:(NSString *)title description:(NSString *)description imageUrl:(NSString *)imageUrl videoUrl:(NSString *)videoUrl isVideo:(BOOL)isVideo;

@end
