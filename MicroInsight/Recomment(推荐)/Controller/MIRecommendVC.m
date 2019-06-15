//
//  MIRecommendVC.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/8.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIRecommendVC.h"
#import "MIRecommendCell.h"
#import "MIRecommendListModel.h"
#import "MJRefresh.h"
#import "MIRecommendDetailVC.h"

@interface MIRecommendVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, assign) NSInteger curPage;

@end

@implementation MIRecommendVC

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataList;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MIScreenWidth, MIScreenHeight - KNaviBarAllHeight) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        if (@available(iOS 11.0,*)) {
            _tableView.estimatedRowHeight = 0;
            _tableView.estimatedSectionHeaderHeight = 0;
            _tableView.estimatedSectionFooterHeight = 0;
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        [_tableView registerNib:[UINib nibWithNibName:@"MIRecommendCell" bundle:nil] forCellReuseIdentifier:@"MIRecommendCell"];
        
        WSWeak(weakSelf);
        _tableView.mj_header = [MJRefreshGifHeader headerWithRefreshingBlock:^{
            weakSelf.curPage = 1;
            [weakSelf requstRecommendList:YES];
        }];
        
        _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            weakSelf.curPage += 1;
            [weakSelf requstRecommendList:NO];
        }];
    }
    return _tableView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _curPage = 1;
    [self configUI];
    [self.view addSubview:self.tableView];
    [self requstRecommendList:YES];
}

- (void)configUI {
    self.title = @"推荐";
    self.view.backgroundColor = UIColorFromRGBWithAlpha(0xF2F3F5, 1);
    [super configLeftBarButtonItem:nil];
    [super configRightBarButtonItemWithType:UIButtonTypeCustom frame:CGRectMake(0, 0, 60, 20) normalTitle:nil normalTitleColor:nil highlightedTitleColor:nil selectedColor:nil titleFont:0 normalImage:[UIImage imageNamed:@"icon_community_search_nor"] highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(clickSearchBtn)];
}

- (void)requstRecommendList:(BOOL)isRefresh {
    WSWeak(weakSelf);
    [MIRequestManager getRecommendDataListWithSearchTitle:@"" requestToken:[MILocalData getCurrentRequestToken] page:_curPage pageSize:10 completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        if (isRefresh) {
            [weakSelf.tableView.mj_header endRefreshing];
            [weakSelf.dataList removeAllObjects];
        }
        
        NSInteger code = [jsonData[@"code"] integerValue];
        if (code == 0) {
            
            NSDictionary *data = jsonData[@"data"];
            NSArray *list = data[@"list"];
            for (NSDictionary *dic in list) {
                MIRecommendListModel *model = [MIRecommendListModel yy_modelWithDictionary:dic];
                [weakSelf.dataList addObject:model];
            }
            
            if (list.count < 10) {
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            } else {
                [weakSelf.tableView.mj_footer endRefreshing];
            }
            
            [weakSelf.tableView reloadData];
        } else {
            
        }
    }];
}

- (void)clickSearchBtn {
    
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 115;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 7;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MIRecommendListModel *model = self.dataList[indexPath.section];
    MIRecommendDetailVC *vc = [[MIRecommendDetailVC alloc] init];
    vc.tweetId = model.modelId;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MIRecommendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MIRecommendCell" forIndexPath:indexPath];
    MIRecommendListModel *model = self.dataList[indexPath.section];
    [cell setCellWithModel:model];
    
    return cell;
}

@end
