//
//  ZQImageScrawlController.h
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/19.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIBaseViewController.h"
#import "ZQUtil.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZQImageScrawlController : MIBaseViewController

@property (nonatomic, strong) UIImage *image;

- (void)addFinishBlock:(ImageBlock)block;

@end

NS_ASSUME_NONNULL_END
