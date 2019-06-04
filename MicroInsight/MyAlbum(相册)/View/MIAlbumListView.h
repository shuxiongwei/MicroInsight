//
//  MIAlbumListView.h
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/29.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MIAlbumModel;
@protocol MIAlbumListViewDelegate <NSObject>

- (void)didClickTableViewCell:(MIAlbumModel *)model animate:(BOOL)animate;

@end


@interface MIAlbumListView : UIView

@property (nonatomic, weak) id<MIAlbumListViewDelegate> delegate;
@property (nonatomic, copy) NSArray *list;
@property (nonatomic, assign) NSInteger currentIndex;

@end

NS_ASSUME_NONNULL_END
