//
//  MIFeedbackListCell.h
//  MicroInsight
//
//  Created by 舒雄威 on 2019/7/14.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MIFeedbackListModel;
@interface MIFeedbackListCell : UITableViewCell

@property (nonatomic, strong) MIFeedbackListModel *model;

+ (instancetype)cellWithTableView:(UITableView *)tableView
                      letterModel:(MIFeedbackListModel *)model;

@end

NS_ASSUME_NONNULL_END
