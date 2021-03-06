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
#import "MICommunityCollectionLayout.h"
#import "MIDetailViewController.h"


@interface MICommunityViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *searchBackView;
@property (nonatomic, strong) UICollectionView *collectionV;
@property (nonatomic, strong) UICollectionView *searchCollectionV;

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, assign) NSInteger pageCount;
@property (nonatomic, strong) NSMutableArray *dataList;

@property (nonatomic, assign) NSInteger searchPage;
@property (nonatomic, assign) NSInteger searchPageCount;
@property (nonatomic, strong) NSMutableArray *searchDataList;

@property (nonatomic, assign) BOOL addBlackList; //标识是否是拉黑后返回当前控制器

@end

@implementation MICommunityViewController

static NSString * const MICellID = @"MICommunityCell";

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:blackListNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

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

    [self configCollectionView];
    [self configSearchCollectionView];
    
    MIUserInfoModel *model = [MILocalData getCurrentLoginUserInfo];
    _titleLab.text = model.nickname;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hasAddBlackList) name:blackListNotification object:nil];
}

- (void)configCollectionView {
    _collectionV = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, MIScreenWidth, MIScreenHeight - 64) collectionViewLayout:[[MICommunityCollectionLayout alloc] init]];
    _collectionV.delegate = self;
    _collectionV.dataSource = self;
    [_collectionV registerNib:[UINib nibWithNibName:@"MICommunityCell" bundle:nil] forCellWithReuseIdentifier:MICellID];
    [self.view addSubview:_collectionV];
    
    WSWeak(weakSelf);
    MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingBlock:^{
        [weakSelf.collectionV.mj_footer resetNoMoreData];
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

- (void)configSearchCollectionView {
    _searchCollectionV = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, MIScreenWidth, MIScreenHeight - 64) collectionViewLayout:[[MICommunityCollectionLayout alloc] init]];
    _searchCollectionV.delegate = self;
    _searchCollectionV.dataSource = self;
    _searchCollectionV.hidden = YES;
    _searchCollectionV.backgroundColor = [UIColor blackColor];
    [_searchCollectionV registerNib:[UINib nibWithNibName:@"MICommunityCell" bundle:nil] forCellWithReuseIdentifier:MICellID];
    [self.view addSubview:_searchCollectionV];
    
    WSWeak(weakSelf);
    MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingBlock:^{
        [weakSelf.searchCollectionV.mj_footer resetNoMoreData];
        [weakSelf.searchCollectionV.mj_header endRefreshing];
        weakSelf.searchPage = 1;
        [weakSelf refreshUI:MIRefreshNormal];
    }];
    _searchCollectionV.mj_header = header;
    
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        
        if (weakSelf.searchPage >= weakSelf.searchPageCount) {
            [weakSelf.searchCollectionV.mj_footer endRefreshingWithNoMoreData];
        } else {
            [weakSelf.searchCollectionV.mj_footer endRefreshing];
            weakSelf.searchPage++;
            [weakSelf refreshUI:MIRefreshAdd];
        }
    }];
    _searchCollectionV.mj_footer = footer;
    
    _searchPage = 1;
}

- (void)refreshUI:(MIRefreshType)type {
    WSWeak(weakSelf);
    [self requestDataList:type complete:^{
        
        if (![MIHelpTool isBlankString:weakSelf.searchBar.text]) {
            [weakSelf.searchCollectionV reloadData];
        } else {
            [weakSelf.collectionV reloadData];
        }
    }];
}

- (void)requestDataList:(MIRefreshType)type complete:(void(^)(void))completed {
    
    WSWeak(weakSelf);
    
    NSInteger page = _currentPage;
    if (![MIHelpTool isBlankString:weakSelf.searchBar.text]) {
        page = _searchPage;
    }
    
    [MIRequestManager getCommunityDataListWithSearchTitle:_searchBar.text requestToken:[MILocalData getCurrentRequestToken] page:page pageSize:_pageSize isMine:_isMine completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        NSInteger code = [jsonData[@"code"] integerValue];
        if (code == 0) {
            if (type == MIRefreshNormal) {
                if (![MIHelpTool isBlankString:weakSelf.searchBar.text]) {
                    [weakSelf.searchDataList removeAllObjects];
                } else {
                    [weakSelf.dataList removeAllObjects];
                }
            }
            
            NSDictionary *data = jsonData[@"data"];
            NSArray *list = data[@"list"];
            for (NSDictionary *dic in list) {
                MICommunityListModel *model = [MICommunityListModel yy_modelWithDictionary:dic];
                
                if (![MIHelpTool isBlankString:weakSelf.searchBar.text]) {
                    [weakSelf.searchDataList addObject:model];
                } else {
                    [weakSelf.dataList addObject:model];
                }
            }
            
            NSDictionary *pagination = data[@"pagination"];
            if (![MIHelpTool isBlankString:weakSelf.searchBar.text]) {
                weakSelf.searchPage = [pagination[@"page"] integerValue];
                weakSelf.searchPageCount = [pagination[@"pageCount"] integerValue];
            } else {
                weakSelf.currentPage = [pagination[@"page"] integerValue];
                weakSelf.pageCount = [pagination[@"pageCount"] integerValue];
            }
            
            completed();
        }
    }];
}

- (void)hasAddBlackList {
    _addBlackList = YES;
    _currentPage = 1;
    _searchPage = 1;
    _pageSize = 10;
    [_collectionV.mj_footer resetNoMoreData];
    [_searchCollectionV.mj_footer resetNoMoreData];
    [self refreshUI:MIRefreshNormal];
}

#pragma mark - IB
- (IBAction)homeBtnClick:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)searchBtnClick:(UIButton *)sender {
    _searchBackView.hidden = NO;
    [_searchBar becomeFirstResponder];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (![MIHelpTool isBlankString:_searchBar.text]) {
        return self.searchDataList.count;
    }
    return self.dataList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MICommunityCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MICellID forIndexPath:indexPath];
    
    MICommunityListModel *listM;
    if (![MIHelpTool isBlankString:_searchBar.text]) {
        listM = self.searchDataList[indexPath.item];
    } else {
        listM = self.dataList[indexPath.item];
    }
    
    cell.titleLb.text = listM.title;
    cell.timeLb.text = listM.createdAt;
    MICommunityTagModel *tagM = listM.tags.firstObject;
    cell.subTitleLb.text = tagM.title;
    cell.authorLab.text = listM.nickname;

    //通过阿里云的处理，图片固定宽高，自动裁剪
    NSString *url = [NSString stringWithFormat:@"?x-oss-process=image/resize,m_fill,h_%ld,w_%ld", (NSInteger)cell.imgView.size.height / 1, (NSInteger)cell.imgView.size.width / 1];

    if (listM.contentType.integerValue == 0) { //图片
        cell.playIcon.hidden = YES;
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:[listM.url stringByAppendingString:url]] placeholderImage:nil options:SDWebImageRetryFailed];
    } else { //视频
        cell.playIcon.hidden = NO;
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:[listM.coverUrl stringByAppendingString:url]] placeholderImage:nil options:SDWebImageRetryFailed];
    }
    
    //等比缩放，限定在矩形框外
    NSString *imgUrl = [NSString stringWithFormat:@"%@?x-oss-process=image/resize,m_fill,h_%ld,w_%ld", listM.avatar, (NSInteger)cell.userIcon.size.width / 1, (NSInteger)cell.userIcon.size.width / 1];
    [cell.userIcon sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"account"] options:SDWebImageRetryFailed];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    MICommunityListModel *listM;
    if (![MIHelpTool isBlankString:_searchBar.text]) {
        listM = self.searchDataList[indexPath.item];
    } else {
        listM = self.dataList[indexPath.item];
    }
    
    MIDetailViewController *detailVC = [[MIDetailViewController alloc] initWithNibName:@"MIDetailViewController" bundle:nil];
    detailVC.userId = listM.userId;
    detailVC.contentId = listM.contentId;
    detailVC.contentType = [listM.contentType integerValue];
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - searchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    if (![MIHelpTool isBlankString:_searchBar.text]) {
        _searchPage = 1;
        [self refreshUI:MIRefreshNormal];
        _searchCollectionV.hidden = NO;
    } else {
        _searchCollectionV.hidden = YES;
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    searchBar.text = nil;
    _searchBackView.hidden = YES;
    _searchCollectionV.hidden = YES;
    
    if (_addBlackList) {
        _addBlackList = NO;
        [self refreshUI:MIRefreshNormal];
    }
}

#pragma mark - 懒加载
- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _dataList;
}

- (NSMutableArray *)searchDataList {
    if (!_searchDataList) {
        _searchDataList = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _searchDataList;
}

#pragma mar - touch
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

@end
