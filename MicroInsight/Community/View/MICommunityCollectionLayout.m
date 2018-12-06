//
//  MICommunityCollectionLayout.m
//  MicroInsight
//
//  Created by leon on 16/3/8.
//  Copyright © 2016年 leon. All rights reserved.
//

#import "MICommunityCollectionLayout.h"

static const float kLineCellCount = 2.0;

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
  
    self.minimumLineSpacing = 5;
    self.minimumInteritemSpacing = 5;
    UIEdgeInsets inset = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
    self.sectionInset = inset;
    CGFloat width = (MIScreenWidth - 3 * 5) / 2.0;
    self.itemSize = CGSizeMake(width, width * 148.0 / 180.0);
}

@end
