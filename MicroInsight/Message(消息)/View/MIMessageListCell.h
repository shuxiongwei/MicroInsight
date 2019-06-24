//
//  MIMessageListCell.h
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/12.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MIMessageListModel;
@interface MIMessageListCell : UITableViewCell

@property (nonatomic, strong) MIMessageListModel *model;

- (void)setMessageCount:(NSInteger)count;

@end

NS_ASSUME_NONNULL_END
