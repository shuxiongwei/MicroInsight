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

/**
 获取短信验证码
 
 @param mobile 手机号
 @param type 类型：0-注册 1-绑定手机 2-验证码登录 3-忘记密码 4-重置密码
 @param completed 完成回调
 */
+ (void)getMessageVerificationCodeWithMobile:(NSString *)mobile type:(NSInteger)type completed:(void (^)(id jsonData, NSError *error))completed;

/**
 手机号注册

 @param mobile 手机号
 @param password 密码
 @param verifyToken 短信验证token
 @param verifyCode 短信验证码
 @param completed 完成回调
 */
+ (void)registerWithMobile:(NSString *)mobile password:(NSString *)password verifyToken:(NSString *)verifyToken verifyCode:(NSString *)verifyCode completed:(void (^)(id jsonData, NSError *error))completed;

#pragma mark - 登录
/**
 账号密码登录

 @param username 用户名
 @param password 密码
 @param completed 完成回调
 */
+ (void)loginWithUsername:(NSString *)username password:(NSString *)password completed:(void (^)(id jsonData, NSError *error))completed;

/**
 QQ登录

 @param openId openId
 @param token accessToken
 @param completed 完成回调
 */
+ (void)loginByQQWithOpenId:(NSString *)openId accessToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed;

/**
 微信登录

 @param code code
 @param completed 完成回调
 */
+ (void)loginByWXWithCode:(NSString *)code completed:(void (^)(id jsonData, NSError *error))completed;

/**
 facebook登录
 
 @param dic 参数
 @param completed 完成回调
 */
+ (void)loginByFacebookWithDic:(NSDictionary *)dic completed:(void (^)(id jsonData, NSError *error))completed;

/**
 账号密码登录
 
 @param username 用户名
 @param password 密码
 @param verifyToken 短信验证token
 @param verifyCode 短信验证码
 @param completed 完成回调
 */
+ (void)forgetPasswordLoginWithUsername:(NSString *)username password:(NSString *)password verifyToken:(NSString *)verifyToken verifyCode:(NSString *)verifyCode completed:(void (^)(id jsonData, NSError *error))completed;

/**
 验证码登录

 @param mobile 手机号
 @param verifyToken 短信验证token
 @param verifyCode 短信验证码
 @param completed 完成回掉
 */
+ (void)loginWithMobile:(NSString *)mobile verifyToken:(NSString *)verifyToken verifyCode:(NSString *)verifyCode completed:(void (^)(id jsonData, NSError *error))completed;

#pragma mark - 社区
/**
 获取社区数据列表

 @param title 检索条件
 @param token token
 @param page 当前页数
 @param pageSize 每页条数
 @param mine 是：个人作品，否：全部作品
 @param completed 完成回调
 */
+ (void)getCommunityDataListWithSearchTitle:(NSString *)title requestToken:(NSString *)token page:(NSInteger)page pageSize:(NSInteger)pageSize isMine:(BOOL)mine completed:(void (^)(id jsonData, NSError *error))completed;


/**
 获取他人作品

 @param userId 用户id
 @param token token
 @param page 当前页数
 @param pageSize 每页条数
 @param completed 完成回调
 */
+ (void)getOtherCommunityDataListWithUserId:(NSInteger)userId requestToken:(NSString *)token page:(NSInteger)page pageSize:(NSInteger)pageSize completed:(void (^)(id jsonData, NSError *error))completed;

/**
 获取社区详情数据

 @param contentId 图片id
 @param token token
 @param completed 完成回调
 */
+ (void)getCommunityDetailDataWithContentId:(NSString *)contentId requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed;

/**
 获取社区详情数据
 
 @param contentId 作品id
 @param contentType 作品类型(0:图片，1:视频)
 @param token token
 @param completed 完成回调
 */
+ (void)getCommunityDetailDataWithContentId:(NSInteger)contentId contentType:(NSInteger)contentType requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed;

/**
 获取评论列表

 @param contentId 图片id
 @param contentType 类型(0:图片，1:视频)
 @param token token
 @param completed 完成回调
 */
+ (void)getCommunityCommentListWithContentId:(NSString *)contentId contentType:(NSInteger)contentType requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed;

/**
 评论

 @param contentId 图片id
 @param contentType 类型(0:图片，1:视频)
 @param content 内容
 @param token token
 @param completed 完成回调
 */
+ (void)commentWithContentId:(NSString *)contentId contentType:(NSInteger)contentType content:(NSString *)content requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed;

/**
 点赞
 
 @param contentId 图片id
 @param contentType 类型(0:图片，1:视频)
 @param token token
 @param completed 完成回调
 */
+ (void)praiseWithContentId:(NSInteger)contentId contentType:(NSInteger)contentType requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed;

/**
 图片上传

 @param file 文件
 @param fileName 文件名称
 @param path 文件路径
 @param title 标题
 @param tags 主题列表
 @param token token
 @param completed 完成回调
 */
+ (void)uploadImageWithFile:(NSString *)file fileName:(NSString *)fileName filePath:(NSString *)path title:(NSString *)title tags:(NSArray *)tags requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed;

/**
 视频上传

 @param title 标题
 @param videoId 阿里云视频id
 @param tags 主题列表
 @param token token
 @param completed 完成回调
 */
+ (void)uploadVideoWithTitle:(NSString *)title videoId:(NSString *)videoId tags:(NSArray *)tags requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed;

/**
 敏感词检测

 @param content 需要检测的内容
 @param completed 完成回调
 */
+ (void)checkSensitiveWord:(NSString *)content completed:(void (^)(id jsonData, NSError *error))completed;

/**
 用户举报

 @param userId 用户id
 @param content 举报内容
 @param token token
 @param completed 完成回调
 */
+ (void)reportUseWithUserId:(NSString *)userId reportContent:(NSString *)content requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed;

#pragma mark - 个人中心
/**
 获取当前登录的用户信息

 @param token token
 @param completed 完成回调
 */
+ (void)getCurrentLoginUserInfoWithRequestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed;

/**
 修改用户信息

 @param nickname 昵称
 @param gender 性别
 @param birthday 生日
 @param token token
 @param completed 完成回调
 */
+ (void)modifyUserInfoWithNickname:(NSString *)nickname gender:(NSString *)gender birthday:(NSString *)birthday requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed;

/**
 修改用户信息
 
 @param nickname 昵称
 @param gender 性别
 @param birthday 生日
 @param profession 职业
 @param token token
 @param completed 完成回调
 */
+ (void)modifyUserInfoWithNickname:(NSString *)nickname gender:(NSInteger)gender birthday:(NSString *)birthday profession:(NSString *)profession requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed;

/**
 上传用户头像

 @param file 文件
 @param fileName 文件名称
 @param avatar 头像
 @param token token
 @param completed 完成回调
 */
+ (void)uploadUserAvatarWithFile:(NSString *)file fileName:(NSString *)fileName avatar:(UIImage *)avatar requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed;

/**
 拉黑

 @param userId 用户id
 @param token token
 @param completed 完成回调
 */
+ (void)addBlackListWithUserId:(NSString *)userId requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed;

/**
 取消拉黑

 @param userId 用户id
 @param token token
 @param completed 完成回调
 */
+ (void)cancelBlackListWithUserId:(NSString *)userId requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed;

/**
 获取黑名单

 @param token token
 @param completed 完成回调
 */
+ (void)getBlackListWithRequestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed;

/**
 获取其他用户信息
 
 @param token token
 @param completed 完成回调
 */
+ (void)getOtherUserInfoWithUserId:(NSInteger)userId requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed;

#pragma mark - 推荐
/**
 获取推荐列表

 @param title 搜索标题
 @param token token
 @param page 当前页码
 @param pageSize 每页条数
 @param completed 完成回掉
 */
+ (void)getRecommendDataListWithSearchTitle:(NSString *)title requestToken:(NSString *)token page:(NSInteger)page pageSize:(NSInteger)pageSize completed:(void (^)(id jsonData, NSError *error))completed;

/**
 获取单条推文信息
 
 @param sweetId 推文id
 @param token token
 @param completed 完成回掉
 */
+ (void)getSingleTweetWithId:(NSInteger)TweetId requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed;

#pragma mark - 消息
/**
 获取所有未读的消息

 @param token token
 @param completed 完成回掉
 */
+ (void)getAllNotReadMessageWithRequestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed;

#pragma mark - 评论(新版)
/**
 获取评论列表
 
 @param contentId 内容id
 @param contentType 类型(0:图片，1:视频)
 @param token token
 @param completed 完成回调
 */
+ (void)getCommunityCommentsWithContentId:(NSInteger )contentId contentType:(NSInteger)contentType requestToken:(NSString *)token completed:(void (^)(id jsonData, NSError *error))completed;

@end

NS_ASSUME_NONNULL_END
