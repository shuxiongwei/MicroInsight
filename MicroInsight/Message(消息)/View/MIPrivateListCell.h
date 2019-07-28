//
//  MIPrivateListCell.h
//  MicroInsight
//
//  Created by 舒雄威 on 2019/7/10.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MILetterListModel;
@interface MIPrivateListCell : UITableViewCell

@property (nonatomic, copy) void (^tapImageView)(NSString *imageUrl);

+ (instancetype)cellWithTableView:(UITableView *)tableView
                      letterModel:(MILetterListModel *)model;

@end

NS_ASSUME_NONNULL_END
