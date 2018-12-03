//
//  MIAlbumCell.m
//  MicroInsight
//
//  Created by Jonphy on 2018/11/20.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "MIAlbumCell.h"

@implementation MIAlbumCell

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];

}

- (void)setIsSelected:(BOOL)isSelected{
    
    _selectedTagImgView.hidden = !isSelected;
    _shadeView.hidden = !isSelected;
}

@end
