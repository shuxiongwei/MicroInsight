//
//  MICommentCell.h
//  MicroInsight
//
//  Created by 舒雄威 on 2018/12/5.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MICommentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *userBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UILabel *commentLab;

@end

NS_ASSUME_NONNULL_END
