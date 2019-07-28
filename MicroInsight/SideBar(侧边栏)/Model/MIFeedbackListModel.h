//
//  MIFeedbackListModel.h
//  MicroInsight
//
//  Created by 舒雄威 on 2019/7/14.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MIFeedbackListModel : MIBaseModel

@property (nonatomic, copy) NSString *feedback;
@property (nonatomic, copy) NSString *type; //0:用户反馈，1:官方回复
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *created_at;

@property (nonatomic, assign) BOOL isSelf;

- (CGRect)timeFrame;
- (CGRect)logoFrame;
- (CGRect)messageFrame;
- (CGFloat)cellHeight;
- (CGRect)pointFrame;

@end

NS_ASSUME_NONNULL_END
