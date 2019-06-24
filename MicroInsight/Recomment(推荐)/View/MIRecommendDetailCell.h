//
//  MIRecommendDetailCell.h
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/15.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MITweetSectionModel;
@interface MIRecommendDetailCell : UITableViewCell

@property (nonatomic, strong) MITweetSectionModel *model;
@property (nonatomic, copy) void (^clickPlayBtn)(NSString *videoUrl);
@property (nonatomic, copy) void (^clickImageView)(NSString *imgPath);

@end

NS_ASSUME_NONNULL_END
