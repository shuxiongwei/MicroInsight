//
//  MIReviewImageView.m
//  MicroInsight
//
//  Created by 舒雄威 on 2018/4/19.
//  Copyright © 2018年 QiShon. All rights reserved.
//

#import "MIReviewImageView.h"
#import "MIReviewImageCell.h"
#import "MIAlbum.h"
#import "UIImageView+WebCache.h"

@interface MIReviewImageView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UICollectionView *collectionView;

@end


@implementation MIReviewImageView

- (void)setImageList:(NSArray *)imageList {
    _imageList = imageList;
    [_collectionView reloadData];
}

- (void)selectCurrentImage:(NSInteger)index {

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [_collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionLeft];
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self setupSubview];
    }
    
    return self;
}

#pragma mark - 配置UI
- (void)setupSubview {
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
    flowLayout.minimumLineSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    [_collectionView registerClass:[MIReviewImageCell class] forCellWithReuseIdentifier:@"MIReviewImageCell"];
    _collectionView.pagingEnabled = YES;
    _collectionView.alwaysBounceHorizontal = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self addSubview:_collectionView];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    NSInteger index = scrollView.contentOffset.x / self.bounds.size.width;
    if (_previewCurrentImage) {
        _previewCurrentImage(index);
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _imageList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    MIReviewImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MIReviewImageCell" forIndexPath:indexPath];
    MIAlbum *album = _imageList[indexPath.item];
    
    if ([album.fileUrl containsString:@"http"]) {
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:album.fileUrl] placeholderImage:nil options:SDWebImageRetryFailed];
    } else {
        cell.imgView.image = [UIImage imageWithContentsOfFile:album.fileUrl];
    }

    return cell;
}

@end
