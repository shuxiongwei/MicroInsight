//
//  MIPrivateLetterVC.h
//  MicroInsight
//
//  Created by 舒雄威 on 2019/7/6.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MIPrivateLetterVC : MIBaseViewController

@property (nonatomic, assign) NSInteger user_receive_id; //接收消息用户ID
@property (nonatomic, copy) NSString *avatar; //图像地址
@property (nonatomic, copy) NSString *otherAvatar; //他人图像地址
@property (nonatomic, copy) NSString *nickname; 

@end

NS_ASSUME_NONNULL_END
