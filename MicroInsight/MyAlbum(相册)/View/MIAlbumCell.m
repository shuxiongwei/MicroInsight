//
//  MIAlbumCell.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/20.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIAlbumCell.h"

@interface MIAlbumCell ()

@end

@implementation MIAlbumCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _durationLab.layer.cornerRadius = 10;
    _durationLab.layer.masksToBounds = YES;
    
    UILongPressGestureRecognizer *rec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self addGestureRecognizer:rec];
}

- (void)longPress:(UILongPressGestureRecognizer *)rec {
    if (self.longPress) {
        self.longPress();
    }
}

@end
