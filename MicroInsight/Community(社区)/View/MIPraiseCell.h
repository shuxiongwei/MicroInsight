//
//  MIPraiseCell.h
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/14.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MIPraiseModel;
@interface MIPraiseCell : UITableViewCell

@property (nonatomic, strong) MIPraiseModel *model;

@property (nonatomic, copy) void (^clickUserIcon)(NSInteger userId);

@end

NS_ASSUME_NONNULL_END
