//
//  MIReportView.h
//  MicroInsight
//
//  Created by 舒雄威 on 2019/1/10.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MIReportView : UIView

@property (nonatomic, copy) void(^selectReportContent)(NSString *content);

@end

NS_ASSUME_NONNULL_END
