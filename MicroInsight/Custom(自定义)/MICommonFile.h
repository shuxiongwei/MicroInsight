//
//  MICommonFile.h
//  MicroInsight
//
//  Created by 舒雄威 on 2018/12/5.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#ifndef MICommonFile_h
#define MICommonFile_h

typedef NS_ENUM(NSUInteger, MIRefreshType) {
    MIRefreshNormal,  //刷新
    MIRefreshAdd,     //添加
};

typedef NS_ENUM(NSInteger,MIAlbumType) {
    MIAlbumTypeAll = 0,     //所有
    MIAlbumTypePhoto,       //照片
    MIAlbumTypeVideo,       //视频
};

#endif /* MICommonFile_h */
