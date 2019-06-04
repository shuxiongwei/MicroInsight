//
//  MIAlbumListCell.h
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/29.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MIAlbumModel;
@interface MIAlbumListCell : UITableViewCell

@property (nonatomic, strong) MIAlbumModel *model;

@end

NS_ASSUME_NONNULL_END
