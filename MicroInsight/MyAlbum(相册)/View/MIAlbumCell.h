//
//  MIAlbumCell.h
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/20.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MIAlbumCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UILabel *durationLab;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIView *maskView;

@end

NS_ASSUME_NONNULL_END
