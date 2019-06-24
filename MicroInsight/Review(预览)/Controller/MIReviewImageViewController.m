//
//  MIReviewImageViewController.m
//  MicroInsight
//
//  Created by 舒雄威 on 2018/8/22.
//  Copyright © 2018年 舒雄威. All rights reserved.
//

#import "MIReviewImageViewController.h"
#import "MIReviewImageView.h"
#import "MIAlbum.h"

@interface MIReviewImageViewController ()

@end

@implementation MIReviewImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [super configLeftBarButtonItem:nil];
    [self configNavigationBarRightButton:_curIndex];
    [self configReviewImageUI];
}

- (void)configNavigationBarRightButton:(NSInteger)index {
    
    if ([MIHelpTool isBlankString:_imgPath]) {
        MIAlbum *album = _imgList[index];
        NSString *time = [album.fileUrl.lastPathComponent stringByDeletingPathExtension];
        NSArray *list = [time componentsSeparatedByString:@"+"];
        NSString *text = [NSString stringWithFormat:@"%@ / %@", list.firstObject, list.lastObject];
        
        [super configRightBarButtonItemWithType:UIButtonTypeCustom frame:CGRectMake(0, 0, 200, 30) normalTitle:text normalTitleColor:[UIColor whiteColor] highlightedTitleColor:nil selectedColor:nil titleFont:15 normalImage:nil highlightedImage:nil selectedImage:nil touchUpInSideTarget:nil action:nil];
    } else {
        
    }
}

- (void)configReviewImageUI {
    MIReviewImageView *tileView = [[MIReviewImageView alloc] initWithFrame:self.view.frame];
    if ([MIHelpTool isBlankString:_imgPath]) {
        tileView.imageList = _imgList;
        [tileView selectCurrentImage:_curIndex];
    } else {
        MIAlbum *album = [[MIAlbum alloc] init];
        album.fileUrl = _imgPath;
        tileView.imageList = @[album];
    }
    [self.view addSubview:tileView];
    
    WSWeak(weakSelf);
    tileView.previewCurrentImage = ^(NSInteger index) {
        [weakSelf configNavigationBarRightButton:index];
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
