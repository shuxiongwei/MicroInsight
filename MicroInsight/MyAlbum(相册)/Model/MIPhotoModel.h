//
//  MIPhotoModel.h
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/20.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface MIPhotoModel : NSObject<NSCopying>

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, assign) MIAlbumType type;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, copy) NSString *duration;

@end


@interface MIAlbumModel : NSObject<NSCopying>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) PHFetchResult *result;
@property (nonatomic, copy) NSArray<MIPhotoModel *> *photos;

@end

NS_ASSUME_NONNULL_END
