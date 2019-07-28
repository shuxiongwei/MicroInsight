//
//  MICommentAlertView.h
//  MicroInsight
//
//  Created by 舒雄威 on 2019/7/17.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MICommentAlertView : UIView

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet UIButton *reportBtn;
@property (weak, nonatomic) IBOutlet UIButton *blackBtn;
@property (nonatomic, copy) void (^alertType)(NSInteger type);

+ (instancetype)commentAlertView;

@end

NS_ASSUME_NONNULL_END
