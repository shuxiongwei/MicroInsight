//
//  MIThirdPartyLoginManager.m
//  MicroInsight
//
//  Created by Jonphy on 2018/11/19.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "MIThirdPartyLoginManager.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface MIThirdPartyLoginManager () <NSURLSessionTaskDelegate>

@property (nonatomic, copy) MIThirdPartyLoginResultBlock resultBlock;
@property (nonatomic, assign) MILoginType loginType;
@property (nonatomic, strong) NSString *access_token;
@property (nonatomic, strong) TencentOAuth *tencentOAuth;
@property (nonatomic, strong) NSMutableArray *tencentPermissions;

@end

@implementation MIThirdPartyLoginManager

static MIThirdPartyLoginManager *_instance;
+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        [_instance setRegisterApps];
    });
    return _instance;
}

// 注册app
- (void)setRegisterApps {
    [FBSDKSettings setAppID:kFacebookAppId];
    // 注册Sina微博
    [WeiboSDK registerApp:kSinaAppKey];
    // 微信注册
    [WXApi registerApp:kWeixinAppId];
    
    // 注册QQ
    _tencentOAuth = [[TencentOAuth alloc] initWithAppId:kTencentAppId andDelegate:self];
    // 这个是说到时候你去qq那拿什么信息
    _tencentPermissions = [NSMutableArray arrayWithArray:@[/** 获取用户信息 */
                                                           kOPEN_PERMISSION_GET_USER_INFO,
                                                           /** 移动端获取用户信息 */
                                                           kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                                                           /** 获取登录用户自己的详细信息 */
                                                           kOPEN_PERMISSION_GET_INFO]];
}

- (void)getUserInfoWithWTLoginType:(MILoginType)type result:(MIThirdPartyLoginResultBlock)result showViewController:(UIViewController *)vc {
    _instance.resultBlock = result;
    _instance.loginType = type;
    
    if (type == MILoginTypeWeiBo) {
        WBAuthorizeRequest *request = [WBAuthorizeRequest request];
        request.redirectURI = kSinaRedirectURI;
        [WeiboSDK sendRequest:request];
    } else if (type == MILoginTypeTencent) {
        [_instance.tencentOAuth authorize:_instance.tencentPermissions];
    } else if (type == MILoginTypeWeiXin) {
        SendAuthReq *req =[[SendAuthReq alloc] init];
        if ([WXApi isWXAppInstalled]) {
            req.scope = @"snsapi_userinfo" ;
            [WXApi sendReq:req];
        } else {
            [WXApi sendAuthReq:req viewController:vc delegate:self];
        }
    } else if (type == MILoginTypeFacebook) {
        [self fetchFaceBookToken:vc];
    }
}

- (void)shareByWXWithTitle:(NSString *)title description:(NSString *)description imageUrl:(NSString *)imageUrl videoUrl:(NSString *)videoUrl isVideo:(BOOL)isVideo {
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;

    if (isVideo) { //视频
        // 多媒体消息中包含的视频数据对象
        WXVideoObject *videoObject = [WXVideoObject object];
        // 视频网页的url地址
        videoObject.videoUrl = videoUrl;
        // 视频lowband网页的url地址
        videoObject.videoLowBandUrl = videoUrl;
    } else { //图片
        // 设置消息缩略图的方法
//        [message setThumbImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]]];
        // 多媒体消息中包含的图片数据对象
        WXImageObject *imageObject = [WXImageObject object];
        // 图片真实数据内容
        imageObject.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        // 多媒体数据对象，可以为WXImageObject，WXMusicObject，WXVideoObject，WXWebpageObject等
        message.mediaObject = imageObject;
    }

    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneTimeline;// 分享到朋友圈
    [WXApi sendReq:req];
}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp {
    
    //登录
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        if (resp.errCode == 0) {  //成功。
            SendAuthResp *aresp = (SendAuthResp *)resp;
//            [self getWeiXinUserInfoWithCode:aresp.code];
            
            NSDictionary *paramter = @{@"code" : aresp.code};
            self.resultBlock(paramter, nil);
        } else {
            if (self.resultBlock) {
                self.resultBlock(nil, @"授权失败");
            }
        }
    }
    
    //分享
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        if (resp.errCode == 0) {
            [MIToastAlertView showAlertViewWithMessage:@"分享成功"];
        }
    }
}

- (void)getWeiXinUserInfoWithCode:(NSString *)code {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSBlockOperation *getAccessTokenOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSString * urlStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",kWeixinAppId,kWeixinAppSecret,code];
        NSURL * url = [NSURL URLWithString:urlStr];
        NSString *responseStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData *responseData = [responseStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        self.access_token = [dic objectForKey:@"access_token"];
    }];
    
    NSBlockOperation * getUserInfoOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSString *urlStr =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",self.access_token,kWeixinAppId];
        NSURL * url = [NSURL URLWithString:urlStr];
        NSString *responseStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData *responseData = [responseStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        NSDictionary *paramter = @{@"openId" : dic[@"openid"],
                                   @"accessToken":self.access_token};
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.resultBlock(paramter, nil);
        }];
    }];
    
    [getUserInfoOperation addDependency:getAccessTokenOperation];
    [queue addOperation:getAccessTokenOperation];
    [queue addOperation:getUserInfoOperation];
}

#pragma mark - TencentLoginDelegate
- (void)tencentDidLogin {
    [_tencentOAuth getUserInfo];
}

- (void)getUserInfoResponse:(APIResponse *)response {
    if (response.retCode == URLREQUEST_SUCCEED) {
        NSDictionary *paramter = @{@"openId" : [_tencentOAuth openId],
                                   @"accessToken":[_tencentOAuth accessToken]};
        
        if (self.resultBlock) {
            self.resultBlock(paramter, nil);
        }
    } else {
        self.resultBlock(nil, @"授权失败");
    }
}

- (void)tencentDidLogout {
    
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    
}

- (void)tencentDidNotNetWork {
    
}

#pragma mark - WeiboSDKDelegate
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {
    
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    NSLog(@"token %@", [(WBAuthorizeResponse *) response accessToken]);
    NSLog(@"uid %@", [(WBAuthorizeResponse *) response userID]);
    
    [self getWeiBoUserInfo:[(WBAuthorizeResponse *) response userID] token:[(WBAuthorizeResponse *) response accessToken]];
}

- (void)getWeiBoUserInfo:(NSString *)uid token:(NSString *)token {
    NSString *url =[NSString stringWithFormat:@"https://api.weibo.com/2/users/show.json?uid=%@&access_token=%@&source=%@",uid,token,kSinaAppKey];
    NSURL *zoneUrl = [NSURL URLWithString:url];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    // 创建任务
    NSURLSessionDataTask * task = [session dataTaskWithRequest:[NSURLRequest requestWithURL:zoneUrl] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSLog(@"%@", [NSThread currentThread]);
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSLog(@"%@",dic);
    
        NSDictionary *paramter = @{@"openId" : [dic valueForKeyPath:@"idstr"],
                                   @"accessToken":token};
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (self.resultBlock) {
                self.resultBlock(paramter, nil);
            }
        }];
    }];
    
    // 启动任务
    [task resume];
}

#pragma mark - facebook
- (void)fetchFaceBookToken:(UIViewController *)vc {
    
    WSWeak(weakSelf)
    
    FBSDKAccessToken *fbToken = [FBSDKAccessToken currentAccessToken];
    // 已有token，且在有效期范围内
    if (fbToken.tokenString && [fbToken.expirationDate compare:[NSDate date]] != NSOrderedAscending) {
        [self fetchFaceBookUserinfo:fbToken.userID];
        return;
    }

    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    // 设置请求权限，公开的权限为@"public_profile",@"email",@"user_friends"，其它权限均需要facebook通过审核后使用
    [login logInWithReadPermissions: @[@"public_profile",@"email",@"user_friends"]
                 fromViewController:vc
                            handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                
                                if (!error) {
                                    if (!result.isCancelled) {
                                        
                                        // 第一步：拿到了token
                                        // 第二步：获取用户信息
                                        [weakSelf fetchFaceBookUserinfo:result.token.userID];
                                    } else {
                                        [MIHudView showMsg:@"Facebook登录取消了"];
                                    }
                                } else {
                                    
                                }
                                
                            }];
}

- (void)fetchFaceBookUserinfo:(NSString *)userId {

    // 关于权限及字段详见：https://developers.facebook.com/docs/facebook-login/permissions
    // 设置请求的字段，很重要的
    NSDictionary *params = @{@"fields": @"id, name, first_name, last_name, age_range, link, gender, locale, picture, timezone, updated_time, verified, email, birthday"};
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                                                   parameters:params
                                                                   HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        
        if (error) {
            NSLog(@"Error: %@",error);
        } else if (result) {
            NSLog(@"UserInfo: %@",result);
            if ([result isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary *dict = (NSDictionary *)result;
                if (self.resultBlock) {
                    self.resultBlock(dict, nil);
                }
            }
        }
    }];
}

@end
