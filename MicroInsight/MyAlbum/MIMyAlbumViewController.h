//
//  MIMyAlbumViewController.h
//  MicroInsight
//
//  Created by Jonphy on 2018/11/20.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,MIAlbumType) {
    
    MIAlbumTypePhoto = 1,
    MIAlbumTypeVideo
};


NS_ASSUME_NONNULL_BEGIN

@interface MIMyAlbumViewController : UIViewController

@property (nonatomic, assign) NSInteger albumType;

@end

NS_ASSUME_NONNULL_END
