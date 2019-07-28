//
//  MIPrivateImageReviewVC.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/7/9.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIPrivateImageReviewVC.h"
#import "MIPrivateImageCell.h"

@interface MIPrivateImageReviewVC () <UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation MIPrivateImageReviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configUI];
}

- (void)configUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [super configLeftBarButtonItem:nil];
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 69, 24)];
    rightView.backgroundColor = [UIColor clearColor];
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 49, 24);
    [rightBtn setTitle:[MILocalData appLanguage:@"community_key_6"] forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [rightBtn setEnlargeEdge:10];
    rightBtn.backgroundColor = UIColorFromRGBWithAlpha(0x4A9DD5, 1);
    [rightBtn round:3 RectCorners:UIRectCornerAllCorners];
    [rightBtn addTarget:self action:@selector(clickRightBtn) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:rightBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightView];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, MIScreenWidth, MIScreenHeight - 120)];
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    _scrollView.delegate = self;
    for (NSInteger i = 0; i < _imageArray.count; i++) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(i * MIScreenWidth, 0, MIScreenWidth, _scrollView.bounds.size.height)];
        imgView.image = _imageArray[i];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        [_scrollView addSubview:imgView];
    }
    _scrollView.contentSize = CGSizeMake(_imageArray.count * MIScreenWidth, _scrollView.bounds.size.height);
    [self.view addSubview:_scrollView];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(63, 80);
    flowLayout.minimumInteritemSpacing = 20;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, MIScreenHeight - KNaviBarAllHeight - 120, MIScreenWidth, 120) collectionViewLayout:flowLayout];
    [_collectionView registerNib:[UINib nibWithNibName:@"MIPrivateImageCell" bundle:nil] forCellWithReuseIdentifier:@"MIPrivateImageCell"];
    _collectionView.backgroundColor = UIColorFromRGBWithAlpha(0x333333, 0.8);
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self.view addSubview:_collectionView];
}

- (void)clickRightBtn {
    
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _imageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MIPrivateImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MIPrivateImageCell" forIndexPath:indexPath];
    cell.imgView.image = _imageArray[indexPath.item];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [_scrollView setContentOffset:CGPointMake(MIScreenWidth * indexPath.item, 0)];
}

@end
