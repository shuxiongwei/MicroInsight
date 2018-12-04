//
//  MICommunityViewController.m
//  MicroInsight
//
//  Created by Jonphy on 2018/11/19.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "MICommunityViewController.h"
#import "MICommunityCell.h"
#import "MICommunityListModel.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"

typedef NS_ENUM(NSUInteger, MIRefreshType) {
    MIRefreshNormal,  //刷新
    MIRefreshAdd,     //添加
};


@interface MICommunityViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *searchBackView;
@property (nonatomic, strong) UICollectionView *collectionV;

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, assign) NSInteger pageCount;
@property (nonatomic, strong) NSMutableArray *dataList;

@end

@implementation MICommunityViewController

static NSString * const MICellID = @"MICommunityCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITextField *searchField = [_searchBar valueForKey:@"_searchField"];
    [searchField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [searchField setValue:[UIFont systemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
    searchField.font = [UIFont systemFontOfSize:14];
    searchField.layer.cornerRadius = 15;
    searchField.layer.masksToBounds = YES;
    searchField.backgroundColor = [UIColor blackColor];
    UIButton *cancelBtn = [_searchBar valueForKey:@"cancelButton"];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 5;
    UIEdgeInsets inset = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
    layout.sectionInset = inset;
    CGFloat width = (MIScreenWidth - 3 * 5) / 2.0;
    layout.itemSize = CGSizeMake(width, width * 148.0 / 180.0);
    
    _collectionV = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, MIScreenWidth, MIScreenHeight - 64) collectionViewLayout:layout];
    _collectionV.delegate = self;
    _collectionV.dataSource = self;
    [_collectionV registerNib:[UINib nibWithNibName:@"MICommunityCell" bundle:nil] forCellWithReuseIdentifier:MICellID];
    [self.view addSubview:_collectionV];
    
    WSWeak(weakSelf);
    MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingBlock:^{
        [weakSelf.collectionV.mj_header endRefreshing];
        weakSelf.currentPage = 1;
        [weakSelf refreshUI:MIRefreshNormal];
    }];
    _collectionV.mj_header = header;
    
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        
        if (weakSelf.currentPage >= weakSelf.pageCount) {
            [weakSelf.collectionV.mj_footer endRefreshingWithNoMoreData];
        } else {
            [weakSelf.collectionV.mj_footer endRefreshing];
            weakSelf.currentPage++;
            [weakSelf refreshUI:MIRefreshAdd];
        }
    }];
    _collectionV.mj_footer = footer;
    
    _currentPage = 1;
    _pageSize = 10;
    [self refreshUI:MIRefreshNormal];
}

- (void)refreshUI:(MIRefreshType)type {
    [self requestDataList:type complete:^{
        [_collectionV reloadData];
    }];
}

- (void)requestDataList:(MIRefreshType)type complete:(void(^)(void))completed {
    
    WSWeak(weakSelf);
    [MIRequestManager getCommunityDataListWithSearchTitle:_searchBar.text requestToken:[MILocalData getCurrentRequestToken] page:_currentPage pageSize:_pageSize completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        NSInteger code = [jsonData[@"code"] integerValue];
        if (code == 0) {
            if (type == MIRefreshNormal) {
                [weakSelf.dataList removeAllObjects];
            }
            
            NSDictionary *data = jsonData[@"data"];
            NSArray *list = data[@"list"];
            for (NSDictionary *dic in list) {
                MICommunityListModel *model = [MICommunityListModel yy_modelWithDictionary:dic];
                [weakSelf.dataList addObject:model];
            }
            
            NSDictionary *pagination = jsonData[@"pagination"];
            weakSelf.currentPage = [pagination[@"page"] integerValue];
            weakSelf.pageCount = [pagination[@"pageCount"] integerValue];
            
            completed();
        }
    }];
}

#pragma mark - IB
- (IBAction)homeBtnClick:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)searchBtnClick:(UIButton *)sender {
    _searchBackView.hidden = NO;
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MICommunityCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MICellID forIndexPath:indexPath];
    MICommunityListModel *listM = self.dataList[indexPath.item];
    cell.titleLb.text = listM.title;
    cell.timeLb.text = listM.createdAt;
    MICommunityTagModel *tagM = listM.tags.firstObject;
    cell.subTitleLb.text = tagM.title;
    
    if (listM.contentType.integerValue == 0) { //图片
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:listM.url] placeholderImage:nil options:SDWebImageRetryFailed];
    } else { //视频
        AVAsset *asset = [AVAsset assetWithURL:[NSURL URLWithString:listM.url]];
        cell.imgView.image = [MIHelpTool fetchThumbnailWithAVAsset:asset curTime:0];
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    MICommunityListModel *listM = self.dataList[indexPath.item];
    
}

#pragma mark - searchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    _currentPage = 1;
    [self refreshUI:MIRefreshNormal];
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    _currentPage = 1;
    [self refreshUI:MIRefreshNormal];
    [searchBar resignFirstResponder];
    searchBar.text = nil;
    _searchBackView.hidden = YES;
}

#pragma mark - 懒加载
- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _dataList;
}

@end
