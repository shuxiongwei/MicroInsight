//
//  QZShareMgr.m
//  QZSQ
//
//  Created by yedexiong20 on 2019/2/22.
//  Copyright © 2019年 XMZY. All rights reserved.
//

#import "QZShareMgr.h"
#import "MyPhotoSheetView.h"
#import "SDWebImageDownloader.h"

static QZShareMgr *_manager;

@interface QZShareMgr ()

@end

@implementation QZShareMgr

//单例创建
+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
    });
    return _manager;
}

- (void)setShareAppKey {
    [[UMSocialManager defaultManager] setUmSocialAppkey:kUMAppKey];
    //微信
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:kWeixinAppId appSecret:kWeixinAppSecret redirectURL:@""];
    // 新浪
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:kSinaAppKey  appSecret:kSinaAppSecret redirectURL:@""];
    // QQ
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:kTencentAppId  appSecret:nil redirectURL:@""];
}

//分享弹框
- (void)showShareType:(QZShareType)shareType inVC:(UIViewController *)vc{
    NSArray *titles;
    NSArray *imgs;
    
    if (shareType == QZShareTypeNormal) {
        titles = @[@"微信好友", @"朋友圈", @"微博", @"QQ", @"QQ空间"];
        imgs = @[@"icon_share_weixin_nor",  @"icon_share_friends_nor",@"icon_share_weibo_nor",@"icon_share_qq_nor",@"icon_share_space_nor"];
    }
    
    MyPhotoSheetView *sheetView = [MyPhotoSheetView shareViewWithTitles:titles imgs:imgs title:nil];
    if (vc) {
        self.shareVC = vc;
        [sheetView showInView:vc.view];
    } else {
        [sheetView show];
    }
    
    WSWeak(weakSelf)
    __block UMSocialPlatformType platformType;
    
    sheetView.SheetActionBlock = ^(NSString *title) {
        if (weakSelf.shareActiondBlock) {
            weakSelf.shareActiondBlock(title);
        }
        if ([title isEqualToString:@"朋友圈"]) {
            platformType = UMSocialPlatformType_WechatTimeLine;
            [weakSelf shareWebPageOrImgToPlatformType:platformType];
        } else if ([title isEqualToString:@"微信"]) {
            platformType = UMSocialPlatformType_WechatSession;
            [weakSelf shareWebPageOrImgToPlatformType:platformType];
        } else if ([title isEqualToString:@"QQ"]) {
            platformType = UMSocialPlatformType_QQ;
            [weakSelf shareWebPageOrImgToPlatformType:platformType];
        } else if ([title isEqualToString:@"QQ空间"]) {
            platformType = UMSocialPlatformType_Qzone;
            [weakSelf shareWebPageOrImgToPlatformType:platformType];
        } else if ([title isEqualToString:@"微博"]) {
            platformType = UMSocialPlatformType_Sina;
            [weakSelf shareWebPageOrImgToPlatformType:platformType];
        } else if ([title isEqualToString:@"举报"]) {

        }
    };
}

//新闻cell分享
- (void)shareActionWithType:(ShareType)type title:(NSString *)title content:(NSString *)content webUrl:(NSString *)webUrl img:(UIImage *)img {
    //点击回调
    if (self.shareActiondBlock) {
        self.shareActiondBlock(@(type));
    }
    
    self.title = title;
    self.content = content;
    self.shareWebUrl = webUrl;
    self.shareImg = img;
    
    UMSocialPlatformType platformType;
    if (type == ShareTypeWechat) { // 微信
        platformType = UMSocialPlatformType_WechatSession;
    }else if (type == ShareTypeFriend) { //朋友圈
        platformType = UMSocialPlatformType_WechatTimeLine;
    }else if (type == ShareTypeQQ) { //QQ
        platformType = UMSocialPlatformType_QQ;
    }else { //新浪
        platformType = UMSocialPlatformType_Sina;
    }
    [self shareWebPageOrImgToPlatformType:platformType];
}

//分享成功后的方法
- (void)shareFinished:(HttpSuccess)finished {
    self.shareFinishedBlock = finished;
}

//点击分享
- (void)shareActionBlock:(HttpSuccess)actionBlock {
    self.shareActiondBlock = actionBlock;
}

//分享图片
- (void)shareImageWithShareType:(ShareType)shareType {
    UMSocialPlatformType type;
    
    if (shareType == ShareTypeWechat) {
        type = UMSocialPlatformType_WechatSession;
    }else if (shareType == ShareTypeFriend) {
        type = UMSocialPlatformType_WechatTimeLine;
    }else if (shareType == ShareTypeQQ) {
        type = UMSocialPlatformType_QQ;
    }else if (shareType == ShareTypeSina) {
        type = UMSocialPlatformType_Sina;
    }else {
        type = UMSocialPlatformType_Qzone;
    }
    
    [self shareImageToPlatformType:type];
}

//传递url时下载图片
- (void)setShareImgUrl:(NSString *)shareImgUrl {
    _shareImgUrl = shareImgUrl;
    WSWeak(weakSelf)
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:shareImgUrl] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        if (image) {
            weakSelf.shareImg = image;
        }else {
            if (weakSelf.defaultShareImg) {
                weakSelf.shareImg = weakSelf.defaultShareImg;
            }else {
                weakSelf.shareImg = [UIImage imageNamed:@"750"];
            }
        }
    }];
}

#pragma mark - 分享网页/图片
- (void)shareWebPageOrImgToPlatformType:(UMSocialPlatformType)platformType {
    if (self.shareWebUrl) {
        [self shareWebPageToPlatformType:platformType];
    } else {
        [self shareImageToPlatformType:platformType];
    }
}

- (void)shareWebPageToPlatformType:(UMSocialPlatformType)platformType {
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //创建网页内容对象
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:self.title descr:self.content thumImage:self.shareImg];
    //设置网页地址
    shareObject.webpageUrl = self.shareWebUrl;
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    WSWeak(weakSelf)
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self.shareVC completion:^(id data, NSError *error) {
        if (error) {
            
        } else {
            if (weakSelf.shareFinishedBlock) {
                weakSelf.shareFinishedBlock(data);
            }
        }
        [weakSelf resetData];
    }];
}

- (void)shareImageToPlatformType:(UMSocialPlatformType)platformType {
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //创建图片内容对象
    UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
    //如果有缩略图，则设置缩略图
    shareObject.thumbImage = [UIImage imageNamed:@"appIcon_lineup"];
    if (self.shareImg) {
        [shareObject setShareImage:self.shareImg];
    }else {
        [shareObject setShareImage:self.shareImgUrl];
    }
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    WSWeak(weakSelf)
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self.shareVC completion:^(id data, NSError *error) {
        if (error) {
            
        }else{
            
            if (weakSelf.shareFinishedBlock) {
                weakSelf.shareFinishedBlock(data);
            }
        }
        [weakSelf resetData];
    }];
}

//分享完成后，清除数据，避免复用了
- (void)resetData {
    self.shareImg = nil;
    self.shareImgUrl = nil;
    self.shareVC = nil;
    self.title = nil;
    self.content = nil;
    self.shareWebUrl = nil;
    self.defaultShareImg = nil;
    self.sendFriendDic = nil;
    self.pasteStr = nil;
    self.reportName = nil;
    self.reportUserId = nil;
    self.defendantId = nil;
}

@end
