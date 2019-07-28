//
//  MIPrivateImageReviewVC.h
//  MicroInsight
//
//  Created by 舒雄威 on 2019/7/9.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MIPrivateImageReviewVC : MIBaseViewController

@property (nonatomic, copy) NSArray *imageArray;
@property (nonatomic, assign) NSInteger user_receive_id; //接收消息用户ID

@end

NS_ASSUME_NONNULL_END
