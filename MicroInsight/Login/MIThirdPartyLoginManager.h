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
- (void)getUserInfoWithWTLoginType:(MILoginType)type result:(MIThirdPartyLoginResultBlock)result;

@end
