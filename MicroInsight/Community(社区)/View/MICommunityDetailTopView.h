//
//  MICommunityDetailTopView.h
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/8.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MICommunityDetailTopView : UIView

@property (nonatomic, strong) id model;
@property (nonatomic, copy) void (^clickUserIcon)(NSInteger userId);

@end

NS_ASSUME_NONNULL_END
