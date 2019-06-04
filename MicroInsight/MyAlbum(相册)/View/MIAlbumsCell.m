//
//  MIAlbumCell.m
//  MicroInsight
//
//  Created by Jonphy on 2018/11/20.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "MIAlbumsCell.h"

@implementation MIAlbumsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _assetImgView.layer.cornerRadius = 3;
    _assetImgView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];

}

- (void)setIsSelected:(BOOL)isSelected{
    
    _selectedTagImgView.hidden = !isSelected;
    _shadeView.hidden = !isSelected;
}

@end
