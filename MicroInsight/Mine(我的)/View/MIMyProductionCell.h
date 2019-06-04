//
//  MIMyProductionCell.h
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/1.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MICommunityListModel;
@interface MIMyProductionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;

- (void)setCellWithModel:(MICommunityListModel *)model;

@end

NS_ASSUME_NONNULL_END
