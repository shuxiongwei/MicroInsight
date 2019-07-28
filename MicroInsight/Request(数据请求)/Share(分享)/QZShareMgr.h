//
//  QZShareMgr.h
//  QZSQ
//
//  Created by yedexiong20 on 2019/2/22.
//  Copyright © 2019年 XMZY. All rights reserved.
//  分享管理类

#import <Foundation/Foundation.h>

@protocol MIShareManagerDelete <NSObject>

@optional

/**
 举报
 */
- (void)shareManagerReportAction;

/**
 拉黑
 */
- (void)shareManagerAddBlackListAction;

/**
 复制链接
 */
- (void)shareManagerCopyLinkAction;

/**
 回到首页
 */
- (void)shareManagerGoHomeAction;

/**
 删除
 */
- (void)shareManagerDeleteAction;

@end

typedef void (^HttpSuccess)(id data);

typedef NS_ENUM(NSUInteger,QZShareType) {
    QZShareTypeNormal = 0,
    QZShareTypeOther, //别人的作品
    QZShareTypeTweet, //推文
    QZShareTypePersonal, //自己的作品
    QZShareTypeAddBlack, //个人主页右上角的扩展(拉黑)
    QZShareTypeCancelBlack, //个人主页右上角的扩展(取消拉黑)
};

typedef NS_ENUM(NSUInteger,ShareType) {
    ShareTypeWechat = 100, //微信
    ShareTypeFriend = 101, //朋友圈
    ShareTypeQQ = 102,//QQ
    ShareTypeSina = 103,//新浪
    ShareTypeQzone = 104 //QQ空间
};

@interface QZShareMgr : NSObject

@property (nonatomic, weak) id<MIShareManagerDelete> delegate;

/* 标题 */
@property (copy,nonatomic) NSString *title;
/* 内容 */
@property (copy,nonatomic) NSString *content;
/* 分享网页地址 */
@property (copy,nonatomic) NSString *shareWebUrl;
/* 分享图片地址（注：图片地址和图片只传一者，最好传url，传递时下载图片） */
@property (copy,nonatomic) NSString *shareImgUrl;
/* 分享图片（注：图片地址和图片只传一者，最好传url，传递时下载图片） */
@property (strong,nonatomic) UIImage *shareImg;
/* 占位分享图片（注：如果传入图片地址，且默认图片不为750，则须传该参数） */
@property (strong,nonatomic) UIImage *defaultShareImg;
/* 分享控制器（可不传） */
@property (weak,nonatomic) UIViewController *shareVC;
/* 发送给朋友需要传此参数 */
@property (strong,nonatomic) NSDictionary *sendFriendDic;
/* 复制内容链接 */
@property (copy,nonatomic) NSString *pasteStr;
/* 是否收藏 */
@property (assign,nonatomic) BOOL isCollect;

/* 举报需要传此参数 */
@property (nonatomic, copy) NSString *reportName;// 被举报人名字
@property (nonatomic, strong) NSString *reportUserId;//被举报人的Id
@property (nonatomic, strong) NSString *defendantId;//被举报对象Id（帖子id、人id、评论id） ———— 必填
@property (nonatomic, assign) NSInteger defendantType;//举报对象类型   ———— 必填

/* 分享成功后的回调 */
@property (copy,nonatomic) HttpSuccess shareFinishedBlock;

/* 点击了分享 */
@property (copy,nonatomic) HttpSuccess shareActiondBlock;

/* 点击二维码 */
@property (copy,nonatomic) HttpSuccess qrCodeActiondBlock;

+ (instancetype)shareManager;

//友盟基础设置
- (void)setShareAppKey;
//显示分享弹框
- (void)showShareType:(QZShareType)shareType inVC:(UIViewController *)vc;
//新闻cell分享-分享按钮直接分享
- (void)shareActionWithType:(ShareType)type title:(NSString *)title content:(NSString *)content webUrl:(NSString *)webUrl img:(UIImage *)img; 
//分享图片
- (void)shareImageWithShareType:(ShareType)shareType;
//分享成功后，需要执行其他操作使用该方法
- (void)shareFinished:(HttpSuccess)finished;

//点击分享
- (void)shareActionBlock:(HttpSuccess)actionBlock;

@end
