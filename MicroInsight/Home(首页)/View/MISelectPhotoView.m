//
//  MISelectPhotoView.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/9.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MISelectPhotoView.h"

@implementation MISelectPhotoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configUI];
    }
    return self;
}

- (void)configUI {
    self.backgroundColor = UIColorFromRGBWithAlpha(0x666666, 0.8);
    
    UIView *selectView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MIScreenWidth - 80, 100)];
    selectView.center = self.center;
    selectView.backgroundColor = [UIColor whiteColor];
    [selectView round:3 RectCorners:UIRectCornerAllCorners];
    [self addSubview:selectView];
    
    UIButton *shootBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shootBtn.frame = CGRectMake(30, 0, (selectView.width - 45) / 2.0, 49.5);
    [shootBtn setTitle:@"拍照" forState:UIControlStateNormal];
    [shootBtn setTitleColor:UIColorFromRGBWithAlpha(0x666666, 1) forState:UIControlStateNormal];
    shootBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    shootBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [shootBtn addTarget:self action:@selector(clickShootBtn) forControlEvents:UIControlEventTouchUpInside];
    [selectView addSubview:shootBtn];
    
    UILabel *photoLab = [[UILabel alloc] initWithFrame:CGRectMake(30 + (selectView.width - 45) / 2.0, 0, (selectView.width - 45) / 2.0, 49.5)];
    photoLab.text = @"照片或视频";
    photoLab.textColor = UIColorFromRGBWithAlpha(0x999999, 1);
    photoLab.font = [UIFont systemFontOfSize:13];
    photoLab.textAlignment = NSTextAlignmentRight;
    [selectView addSubview:photoLab];
    
    UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(0, 49.5, selectView.width, 1)];
    lineV.backgroundColor = UIColorFromRGBWithAlpha(0xD1D1D1, 1);
    [selectView addSubview:lineV];
    
    UIButton *albumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    albumBtn.frame = CGRectMake(30, 50.5, selectView.width - 60, 49.5);
    [albumBtn setTitle:@"从相册中选择" forState:UIControlStateNormal];
    [albumBtn setTitleColor:UIColorFromRGBWithAlpha(0x666666, 1) forState:UIControlStateNormal];
    albumBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    albumBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [albumBtn addTarget:self action:@selector(clickAlbumBtn) forControlEvents:UIControlEventTouchUpInside];
    [selectView addSubview:albumBtn];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSelf)];
    [self addGestureRecognizer:tap];
}

- (void)clickShootBtn {
    if (self.selectBlcok) {
        self.selectBlcok(1);
    }
    [self removeFromSuperview];
}

- (void)clickAlbumBtn {
    if (self.selectBlcok) {
        self.selectBlcok(2);
    }
    [self removeFromSuperview];
}

- (void)tapSelf {
    [self removeFromSuperview];
}

@end
