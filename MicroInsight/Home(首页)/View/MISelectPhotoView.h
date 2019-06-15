//
//  MISelectPhotoView.h
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/9.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MISelectPhotoView : UIView

@property (nonatomic, copy) void (^selectBlcok)(NSInteger type);

@end

NS_ASSUME_NONNULL_END
