//
//  QSTilePreviewView.h
//  QShoot
//
//  Created by 舒雄威 on 2018/4/19.
//  Copyright © 2018年 QiShon. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface QSTilePreviewView : UIView

@property (copy, nonatomic) NSArray *imageList;
@property (copy, nonatomic) void (^previewCurrentImage)(NSInteger index);

/**
 选中当前下标的图片

 @param index 下标
 */
- (void)selectCurrentImage:(NSInteger)index;

@end
