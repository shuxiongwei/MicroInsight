//
//  MICommunityDetailVC.h
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/5.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "WMStickyPageController.h"

@class MICommunityListModel;
NS_ASSUME_NONNULL_BEGIN

@interface MICommunityDetailVC : WMStickyPageController

@property (nonatomic, assign) NSInteger contentId;
@property (nonatomic, assign) NSInteger contentType; //0:图片，1:视频

@property (nonatomic, copy) void (^praiseBlock)(NSInteger comments, NSInteger likes, BOOL isLike);
/* 标识是否需要谈起键盘 */
@property (nonatomic, assign) BOOL needShowKeyboard;

@end

NS_ASSUME_NONNULL_END
