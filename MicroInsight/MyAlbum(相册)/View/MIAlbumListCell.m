//
//  MIAlbumListCell.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/29.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIAlbumListCell.h"
#import <Photos/Photos.h>
#import "MIPhotoModel.h"
#import "MIAlbumManager.h"

@interface MIAlbumListCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *albumLab;
@property (weak, nonatomic) IBOutlet UILabel *countLab;

@end


@implementation MIAlbumListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

}

- (void)setModel:(MIAlbumModel *)model {
    _model = model;
    PHAsset *asset = model.result.lastObject;

    WSWeak(weakSelf)
    [[MIAlbumManager manager] getPhotoWithAsset:asset photoSize:CGSizeMake(80, 80) completion:^(UIImage * _Nonnull photo, NSDictionary * _Nonnull info) {
        weakSelf.imgView.image = photo;
    }];

    _albumLab.text = model.name;
    _countLab.text = [NSString stringWithFormat:@"%ld", model.count];
}

@end
