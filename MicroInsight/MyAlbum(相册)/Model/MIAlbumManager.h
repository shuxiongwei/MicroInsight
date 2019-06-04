//
//  MIAlbumManager.h
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/28.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@class MIPhotoModel;
@class MIAlbumModel;
@interface MIAlbumManager : NSObject

@property (nonatomic, assign) CGFloat assetScale;
@property (nonatomic, assign) CGSize AssetThumbnailSize;

+ (instancetype)manager;

- (void)getAllAlbums:(BOOL)allowPickingVideo
   allowPickingImage:(BOOL)allowPickingImage
     needFetchAssets:(BOOL)needFetchAssets
          completion:(void (^)(NSArray<MIAlbumModel *> *models))completion;

- (void)getAssetsFromFetchResult:(PHFetchResult *)result
               allowPickingVideo:(BOOL)allowPickingVideo
               allowPickingImage:(BOOL)allowPickingImage
                      completion:(void (^)(NSArray<MIPhotoModel *> *models))completion;

- (void)getPhotoWithAsset:(PHAsset *)asset
               photoSize:(CGSize)photoSize
               completion:(void (^)(UIImage *photo, NSDictionary *info))completion;

- (void)getOriginalPhotoDataWithAsset:(PHAsset *)asset
                      progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler completion:(void (^)(NSData *data,NSDictionary *info,BOOL isDegraded))completion;

@end

NS_ASSUME_NONNULL_END
