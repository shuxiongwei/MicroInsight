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

@property (nonatomic, strong) MICommunityListModel *communityModel;
@property (nonatomic, copy) void (^praiseBlock)(MICommunityListModel *model);

@end

NS_ASSUME_NONNULL_END
