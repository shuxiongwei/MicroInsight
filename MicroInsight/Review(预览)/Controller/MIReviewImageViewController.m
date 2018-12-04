//
//  MIReviewImageViewController.m
//  MicroInsight
//
//  Created by 舒雄威 on 2018/8/22.
//  Copyright © 2018年 舒雄威. All rights reserved.
//

#import "MIReviewImageViewController.h"
#import "MIReviewImageCell.h"

@interface MIReviewImageViewController () <UICollectionViewDataSource>

@property (strong, nonatomic) UICollectionView *collectionView;

@end

@implementation MIReviewImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configReviewImageUI];
}

- (void)configReviewImageUI {
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView registerClass:[MIReviewImageCell class] forCellWithReuseIdentifier:@"reviewCell"];
    _collectionView.pagingEnabled = YES;
    _collectionView.alwaysBounceHorizontal = YES;
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.dataSource = self;
    [self.view addSubview:_collectionView];
    
    [super configBackBtn];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MIReviewImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"reviewCell" forIndexPath:indexPath];
    
    UIImage *image = [UIImage imageWithContentsOfFile:_imgPath];
    cell.imgView.image = image;
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
