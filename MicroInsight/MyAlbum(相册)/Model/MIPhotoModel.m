//
//  MIPhotoModel.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/20.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIPhotoModel.h"

@implementation MIPhotoModel

- (id)copyWithZone:(NSZone *)zone {
    MIPhotoModel *model = [[self.class allocWithZone:zone] init];
    model.filePath = self.filePath;
    model.type = self.type;
    model.isSelected = self.isSelected;
    model.asset = self.asset;
    model.duration = self.duration;
    
    return model;
}

@end


@implementation MIAlbumModel

- (id)copyWithZone:(NSZone *)zone {
    MIAlbumModel *model = [[self.class allocWithZone:zone] init];
    model.name = self.name;
    model.count = self.count;
    model.result = self.result;
    model.photos = self.photos.copy;
    
    return model;
}


@end
