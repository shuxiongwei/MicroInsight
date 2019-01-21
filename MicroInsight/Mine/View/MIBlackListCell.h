//
//  MIBlackListCell.h
//  MicroInsight
//
//  Created by 舒雄威 on 2019/1/19.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MIBlackListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *cancelLab;

@end

NS_ASSUME_NONNULL_END
