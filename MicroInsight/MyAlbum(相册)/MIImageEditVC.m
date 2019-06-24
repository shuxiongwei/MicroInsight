//
//  MIImageEditVC.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/9.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIImageEditVC.h"
#import "ZQImageEdit.h"

typedef NS_ENUM(NSInteger, MIImageEditType) {
    MIImageEditTypeRotation = 0,
    MIImageEditTypeCrop,
    MIImageEditTypeMosaic,
    MIImageEditTypeScrawl,
    MIImageEditTypeDown,
};

@interface MIImageEditVC ()

@property (nonatomic, strong) UIImageView *imgView;

@end

@implementation MIImageEditVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configUI];
}

- (void)configUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [super configLeftBarButtonItem:nil];
    UIButton *saveBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(0, 0, 60, 30) normalTitle:@"保存" normalTitleColor:UIColorFromRGBWithAlpha(0x333333, 1) highlightedTitleColor:nil selectedColor:nil titleFont:15 normalImage:nil highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(clickSaveBtn)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
    
    _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, MIScreenWidth, MIScreenHeight - KNaviBarAllHeight - 60)];
    _imgView.backgroundColor = [UIColor blackColor];
    _imgView.contentMode = UIViewContentModeScaleAspectFit;
    _imgView.clipsToBounds = YES;
    _imgView.image = _image;
    [self.view addSubview:_imgView];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, MIScreenHeight - KNaviBarAllHeight - 60, MIScreenWidth, 60)];
    [self.view addSubview:bottomView];
    
    CGFloat width = (MIScreenWidth - 40) / 5.0;
    for (NSInteger i = 0; i < 5; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(20 + width * i, 0, width, 60);
        NSString *imgName = [NSString stringWithFormat:@"icon_album_edit_%ld", i];
        UIImage *img = [UIImage imageNamed:imgName];
        [btn setImage:img forState:UIControlStateNormal];
        btn.tag = i;
        [btn addTarget:self action:@selector(editImage:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:btn];
    }
}

- (void)clickSaveBtn {
    
}

- (void)editImage:(UIButton *)sender {
    WSWeak(weakSelf)
    switch (sender.tag) {
        case MIImageEditTypeRotation: {
            ZQImageRotationController *vc = [[ZQImageRotationController alloc] init];
            vc.image = _image;
            [vc addFinishBlock:^(UIImage *image) {
                weakSelf.image = image;
                weakSelf.imgView.image = image;
            }];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case MIImageEditTypeCrop: {
            ZQImageCropController *vc = [[ZQImageCropController alloc] init];
            vc.image = _image;
            [vc addFinishBlock:^(UIImage *image) {
                weakSelf.image = image;
                weakSelf.imgView.image = image;
            }];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case MIImageEditTypeMosaic:{
            ZQImageMosaicController *vc = [[ZQImageMosaicController alloc] init];
            vc.image = _image;
            [vc addFinishBlock:^(UIImage *image) {
                weakSelf.image = image;
                weakSelf.imgView.image = image;
            }];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case MIImageEditTypeScrawl: {
            ZQImageScrawlController *vc = [[ZQImageScrawlController alloc] init];
            vc.image = _image;
            [vc addFinishBlock:^(UIImage *image) {
                weakSelf.image = image;
                weakSelf.imgView.image = image;
            }];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case MIImageEditTypeDown:
            UIImageWriteToSavedPhotosAlbum(_image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
            break;
        default:
            break;
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
//    if(!error)
//    {
//        [ProgressHud showSuccess:@"保存成功"];
//
//    }
//    else
//    {
//        [ProgressHud showError:@"保存失败"];
//    }
}

@end
