//
//  MICommunityViewController.m
//  MicroInsight
//
//  Created by Jonphy on 2018/11/19.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "MICommunityViewController.h"
#import "MICommunityCell.h"

@interface MICommunityViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation MICommunityViewController

static  NSString * const MICellID = @"MICommunityCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 5;
    layout.itemSize = CGSizeMake((MIScreenWidth - 3 * 5) / 2.0,MIScreenHeight * 180 / 150);
    self.collectionView.collectionViewLayout = layout;
    // Do any additional setup after loading the view.
}

#pragma mark - IB
- (IBAction)homeBtnClick:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)searchBtnClick:(UIButton *)sender {
    
    self.searchBar.hidden = NO;
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MICommunityCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MICellID forIndexPath:indexPath];
    return cell;

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

}

#pragma mark - searchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{

}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{

    searchBar.hidden = YES;
}

@end
