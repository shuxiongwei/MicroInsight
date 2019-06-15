//
//  BSVerticalButton.m
//  百思不得姐
//
//  Created by yedexiong20 on 16/3/30.
//  Copyright © 2016年 ydx. All rights reserved.
//

#import "BSVerticalButton.h"

@implementation BSVerticalButton

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 调整图片
    self.imageView.width = self.currentImage.size.width;
    self.imageView.height = self.currentImage.size.height;
    self.imageView.x = (self.width-self.imageView.width)/2;
    self.imageView.y = 0;
    
    // 调整文字
    self.titleLabel.x = 0;
    self.titleLabel.y = self.imageView.height;
    self.titleLabel.width = self.width;
    self.titleLabel.height = self.height - self.titleLabel.y;
    
    
}


@end
