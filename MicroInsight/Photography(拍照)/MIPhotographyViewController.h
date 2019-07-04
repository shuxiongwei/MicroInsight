//
//  ViewController.h
//  MicroInsight
//
//  Created by 舒雄威 on 2018/7/10.
//  Copyright © 2018年 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MIPhotographyViewController;
@protocol MIPhotographyViewControllerDelegate <NSObject>

/**
 拍摄图片

 @param vc 自己
 @param imgPath 图片路径
 */
- (void)photographyViewController:(MIPhotographyViewController *)vc shootPicture:(NSString *)imgPath;

/**
 拍摄视频

 @param vc 自己
 @param videoPath 视频路径
 */
- (void)photographyViewController:(MIPhotographyViewController *)vc shootVideo:(NSString *)videoPath;

@end

@interface MIPhotographyViewController : MIBaseViewController

@property (nonatomic, weak) id <MIPhotographyViewControllerDelegate> delegate;

/* 入口(默认是0，从首页进入；为1时代表从社区首页进入) */
@property (nonatomic, assign) NSInteger pushFrom;

@end

