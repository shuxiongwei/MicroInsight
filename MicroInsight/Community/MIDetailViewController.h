//
//  MIDetailViewController.h
//  MicroInsight
//
//  Created by 舒雄威 on 2018/12/5.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MIDetailViewController : MIBaseViewController

@property (nonatomic, copy) NSString *contentId;
@property (nonatomic, assign) NSInteger contentType;

@end

NS_ASSUME_NONNULL_END
