//
//  MIMessageListModel.h
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/12.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MIMessageType) {
    MIMessageTypePush = 0,           //官方推送
    MIMessageTypeComment,            //评论
    MIMessageTypePraise,             //点赞
    MIMessageTypeLetter,             //私信
    MIMessageTypeCommentPraise,      //评论点赞
    MIMessageTypeCommentComment      //评论评论
};

@interface MIMessageListModel : MIBaseModel

@property (nonatomic, assign) NSInteger modelId;
@property (nonatomic, assign) NSInteger user_send_id; //发送消息用户ID
@property (nonatomic, assign) NSInteger user_receive_id; //接收消息用户ID
@property (nonatomic, assign) NSInteger content_id; //内容ID
@property (nonatomic, assign) NSInteger content_type; //内容类型
@property (nonatomic, assign) MIMessageType type; //消息类型
@property (nonatomic, assign) NSInteger status; //状态，已读或未读
@property (nonatomic, copy) NSString *content; //消息内容（私信）
@property (nonatomic, copy) NSString *created_at; //创建时间
@property (nonatomic, copy) NSString *update_at; //创建时间
@property (nonatomic, assign) NSInteger comment_id; //评论ID
@property (nonatomic, copy) NSString *nickname; //昵称
@property (nonatomic, copy) NSString *avatar; //图像地址
@property (nonatomic, copy) NSString *title; //标题
@property (nonatomic, copy) NSString *comContent; //评论内容

@end

NS_ASSUME_NONNULL_END
