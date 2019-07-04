//
//  MIUploadViewController.h
//  MicroInsight
//
//  Created by Jonphy on 2018/11/20.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface MIUploadViewController : MIBaseViewController

@property (nonatomic, copy) NSString *assetUrl;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) UIImage *curImage;

@end

NS_ASSUME_NONNULL_END
