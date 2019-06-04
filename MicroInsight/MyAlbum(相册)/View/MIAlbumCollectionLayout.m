//
//  MIAlbumCollectionLayout.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/21.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIAlbumCollectionLayout.h"

@implementation MIAlbumCollectionLayout

- (instancetype)init {
    
    if (self = [super init]) {
        [self configureLayout];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configureLayout];
}

- (void)configureLayout {
    self.minimumLineSpacing = 9.0;
    self.minimumInteritemSpacing = 9.0;
    UIEdgeInsets inset = UIEdgeInsetsMake(15.0, 15.0, 15.0, 15.0);
    self.sectionInset = inset;
    CGFloat width = (MIScreenWidth - 2 * 15.0 - 2 * 9.0) / 3.0;
    CGFloat height = width * 140.0 / 109.0;
    self.itemSize = CGSizeMake(width, height);
}

@end
