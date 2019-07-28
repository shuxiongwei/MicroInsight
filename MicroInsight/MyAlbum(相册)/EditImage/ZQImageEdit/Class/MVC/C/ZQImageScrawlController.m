//
//  ZQImageScrawlController.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/19.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "ZQImageScrawlController.h"
#import "EditOperatingToolBar.h"
#import "QSScrawlView.h"

@interface ZQImageScrawlController ()

{
    ImageBlock _block;
}

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) QSScrawlView *scrawlView;

@end

@implementation ZQImageScrawlController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configUI];
}

- (void)configUI {
    [super configLeftBarButtonItem:nil];
    self.title = [MILocalData appLanguage:@"other_key_23"];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, MIScreenWidth, MIScreenHeight - KNaviBarAllHeight - operaBarHeight)];
    _imageView.backgroundColor = [UIColor blackColor];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.image = _image;
    [self.view addSubview:_imageView];
    
    [self addScrawl];
    
    EditOperatingToolBar *bar = [[EditOperatingToolBar alloc] initWithFrame:CGRectMake(0, MIScreenHeight - KNaviBarAllHeight - operaBarHeight, self.view.width, operaBarHeight)];
    [self.view addSubview:bar];
    [bar addTapBlock:^(NSInteger index) {
        switch (index) {
            case 0:
                [self.navigationController popViewControllerAnimated:YES];
                break;
            case 1:
                [self clearScrawl];
                break;
            case 2:
                [self saveEditImage];
                [self.navigationController popViewControllerAnimated:YES];
                break;
                
            default:
                break;
        }
    }];
}

- (void)addFinishBlock:(ImageBlock)block {
    _block = block;
}

#pragma mark - 保存
- (void)saveEditImage {
    //    CGSize imageSize = _editImage.size;
    //    CGFloat scale =  [UIScreen mainScreen].scale;
    //    CGSize designSize = CGSizeMake( imageSize.width/scale, imageSize.height/scale);
    
    UIGraphicsBeginImageContextWithOptions(_imageView.bounds.size, NO, 0.0);
    //    _imgView.bounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
    //    _scrawlView.bounds = _imgView.bounds;
    [_imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    [_scrawlView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (_block) {
        _block(newImage);
    }
}

#pragma mark - 添加涂鸦
- (void)addScrawl {
    _scrawlView = [[QSScrawlView alloc] initWithFrame:_imageView.frame];
    _scrawlView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_scrawlView];
}

#pragma mark - 清除涂鸦
- (void)clearScrawl {
    if (_scrawlView) {
        [_scrawlView removeFromSuperview];
        _scrawlView = nil;
    }
    
    [self addScrawl];
}

@end
