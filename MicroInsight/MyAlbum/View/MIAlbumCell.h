//
//  MIAlbumCell.h
//  MicroInsight
//
//  Created by Jonphy on 2018/11/20.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MIAlbumCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *assetImgView;
@property (weak, nonatomic) IBOutlet UIImageView *selectedTagImgView;
@property (weak, nonatomic) IBOutlet UILabel *durationLb;
@property (weak, nonatomic) IBOutlet UIView *shadeView;
@property (assign, nonatomic) BOOL isSelected;

@end

NS_ASSUME_NONNULL_END
