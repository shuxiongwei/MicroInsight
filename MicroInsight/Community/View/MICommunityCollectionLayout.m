//
//  MICommunityCollectionLayout.m
//  MicroInsight
//
//  Created by leon on 16/3/8.
//  Copyright © 2016年 leon. All rights reserved.
//

#import "MICommunityCollectionLayout.h"


@implementation MICommunityCollectionLayout

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
  
    self.minimumLineSpacing = 10;
    self.minimumInteritemSpacing = 10;
    UIEdgeInsets inset = UIEdgeInsetsMake(5.0, 10.0, 5.0, 10.0);
    self.sectionInset = inset;
    CGFloat width = (MIScreenWidth - 3 * 10) / 2.0;
    self.itemSize = CGSizeMake(width, width * 148.0 / 180.0);
}

@end
