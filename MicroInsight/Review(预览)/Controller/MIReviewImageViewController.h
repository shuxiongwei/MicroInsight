//
//  MIReviewImageViewController.h
//  MicroInsight
//
//  Created by 舒雄威 on 2018/8/22.
//  Copyright © 2018年 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MIReviewImageViewController : MIBaseViewController

@property (nonatomic,copy) NSString *imgPath; // 不为空，则代表是网络图片
@property (nonatomic, strong) NSArray *imgList;
@property (nonatomic, assign) NSInteger curIndex;

@end
