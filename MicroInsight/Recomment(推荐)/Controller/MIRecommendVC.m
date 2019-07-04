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

@interface MIRecommendVC () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, assign) NSInteger curPage;

@property (nonatomic, strong) UITableView *searchTV;
@property (nonatomic, strong) NSMutableArray *searchList;
@property (nonatomic, assign) NSInteger searchPage;

@property (nonatomic, strong) UITextField *searchTF;
@property (nonatomic, strong) UIButton *maskView;

@end

@implementation MIRecommendVC

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataList;
}

- (NSMutableArray *)searchList {
    if (!_searchList) {
        _searchList = [NSMutableArray arrayWithCapacity:0];
    }
    return _searchList;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MIScreenWidth, MIScreenHeight - KNaviBarAllHeight) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tag = 1000;
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

- (UITableView *)searchTV {
    if (_searchTV == nil) {
        _searchTV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MIScreenWidth, MIScreenHeight - KNaviBarAllHeight) style:UITableViewStylePlain];
        _searchTV.separatorStyle = UITableViewCellSeparatorStyleNone;
        _searchTV.delegate = self;
        _searchTV.dataSource = self;
        _searchTV.tag = 2000;
        _searchTV.hidden = YES;
        _searchTV.tableFooterView = [[UIView alloc] init];
        if (@available(iOS 11.0,*)) {
            _searchTV.estimatedRowHeight = 0;
            _searchTV.estimatedSectionHeaderHeight = 0;
            _searchTV.estimatedSectionFooterHeight = 0;
            _searchTV.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        [_searchTV registerNib:[UINib nibWithNibName:@"MIRecommendCell" bundle:nil] forCellReuseIdentifier:@"MIRecommendCell"];
        
        WSWeak(weakSelf);
        _searchTV.mj_header = [MJRefreshGifHeader headerWithRefreshingBlock:^{
            weakSelf.searchPage = 1;
            [weakSelf requstRecommendList:YES];
        }];
        
        _searchTV.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            weakSelf.searchPage += 1;
            [weakSelf requstRecommendList:NO];
        }];
    }
    return _searchTV;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_searchTF resignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //键盘监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    _curPage = 1;
    _searchPage = 1;
    [self configUI];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.searchTV];
    [self requstRecommendList:YES];
}

- (void)configUI {
    self.title = @"推荐";
    self.view.backgroundColor = UIColorFromRGBWithAlpha(0xF2F3F5, 1);
    [super configLeftBarButtonItem:nil];
    [super configRightBarButtonItemWithType:UIButtonTypeCustom frame:CGRectMake(0, 0, 60, 20) normalTitle:nil normalTitleColor:nil highlightedTitleColor:nil selectedColor:nil titleFont:0 normalImage:[UIImage imageNamed:@"icon_recommend_search_nor"] highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(clickSearchBtn)];
    
    _maskView = [UIButton buttonWithType:UIButtonTypeCustom];
    _maskView.frame = CGRectMake(0, 0, MIScreenWidth, MIScreenHeight - KNaviBarAllHeight);
    _maskView.backgroundColor = UIColorFromRGBWithAlpha(0x333333, 0.6);
    _maskView.hidden = YES;
    [_maskView addTarget:self action:@selector(clickMaskView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_maskView];
}

- (void)configTopSearchView {
    if (!_searchTF) {
        _searchTF = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, MIScreenWidth - 131, 30)];
        _searchTF.font = [UIFont systemFontOfSize:10];
        _searchTF.textColor = UIColorFromRGBWithAlpha(0x999999, 1);
        _searchTF.backgroundColor = UIColorFromRGBWithAlpha(0xF2F3F5, 1);
        _searchTF.delegate = self;
        _searchTF.returnKeyType = UIReturnKeySearch;
        
        self.navigationItem.titleView = _searchTF;
    } else {
        _searchTF.hidden = NO;
    }
    [_searchTF becomeFirstResponder];
}

- (void)popToForwardViewController {
    [_searchTF resignFirstResponder];
    if (_searchTV.hidden) {
        [super popToForwardViewController];
    } else {
        _searchTV.hidden = YES;
        _searchTF.text = nil;
        _searchTF.hidden = YES;
    }
}

- (void)requstRecommendList:(BOOL)isRefresh {
    
    NSInteger page;
    if ([MIHelpTool isBlankString:_searchTF.text]) {
        page = _curPage;
    } else {
        page = _searchPage;
    }
    
    WSWeak(weakSelf);
    [MIRequestManager getRecommendDataListWithSearchTitle:_searchTF.text requestToken:[MILocalData getCurrentRequestToken] page:page pageSize:10 completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        if (isRefresh) {
            if ([MIHelpTool isBlankString:weakSelf.searchTF.text]) {
                [weakSelf.tableView.mj_header endRefreshing];
                [weakSelf.dataList removeAllObjects];
            } else {
                [weakSelf.searchTV.mj_header endRefreshing];
                [weakSelf.searchList removeAllObjects];
            }
        }
        
        NSInteger code = [jsonData[@"code"] integerValue];
        if (code == 0) {
            
            NSDictionary *data = jsonData[@"data"];
            NSArray *list = data[@"list"];
            for (NSDictionary *dic in list) {
                MIRecommendListModel *model = [MIRecommendListModel yy_modelWithDictionary:dic];
                
                if ([MIHelpTool isBlankString:weakSelf.searchTF.text]) {
                    [weakSelf.dataList addObject:model];
                } else {
                    [weakSelf.searchList addObject:model];
                }
            }
            
            if (list.count < 10) {
                if ([MIHelpTool isBlankString:weakSelf.searchTF.text]) {
                    [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                    weakSelf.searchTV.hidden = YES;
                } else {
                    [weakSelf.searchTV.mj_footer endRefreshingWithNoMoreData];
                    weakSelf.searchTV.hidden = NO;
                }
            } else {
                if ([MIHelpTool isBlankString:weakSelf.searchTF.text]) {
                    [weakSelf.tableView.mj_footer endRefreshing];
                    weakSelf.searchTV.hidden = YES;
                } else {
                    [weakSelf.searchTV.mj_footer endRefreshing];
                    weakSelf.searchTV.hidden = NO;
                }
            }
            
            if ([MIHelpTool isBlankString:weakSelf.searchTF.text]) {
                [weakSelf.tableView reloadData];
            } else {
                [weakSelf.searchTV reloadData];
            }
        } else {
            if ([MIHelpTool isBlankString:weakSelf.searchTF.text]) {
                [weakSelf.tableView.mj_footer endRefreshing];
            } else {
                [weakSelf.searchTV.mj_footer endRefreshing];
            }
        }
    }];
}

- (void)clickSearchBtn {
    [self configTopSearchView];
}

- (void)clickMaskView {
    [_searchTF resignFirstResponder];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_searchTF resignFirstResponder];
}

#pragma mark - Notify
- (void)keyBoardWillShow:(NSNotification *) notification {
    _maskView.hidden = NO;
    [self.view bringSubviewToFront:_maskView];
}

- (void)keyBoardWillHide:(NSNotification *) notification {
    _maskView.hidden = YES;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([MIHelpTool isBlankString:_searchTF.text]) {
        [MIHudView showMsg:@"请输入搜索内容"];
        return YES;
    }
    
    [_searchTF resignFirstResponder];
    _searchPage = 1;
    [self requstRecommendList:YES];
    
    return YES;
}

//- (BOOL)textFieldShouldClear:(UITextField *)textField {
//    return YES;
//}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_searchTF resignFirstResponder];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 115;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 7;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MIRecommendListModel *model;
    if (tableView.tag == 1000) {
        model = self.dataList[indexPath.section];
    } else {
        model = self.searchList[indexPath.section];
    }
    MIRecommendDetailVC *vc = [[MIRecommendDetailVC alloc] init];
    vc.tweetId = model.modelId;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView.tag == 1000) {
        return self.dataList.count;
    } else {
        return self.searchList.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MIRecommendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MIRecommendCell" forIndexPath:indexPath];
    
    MIRecommendListModel *model;
    if (tableView.tag == 1000) {
        model = self.dataList[indexPath.section];
    } else {
        model = self.searchList[indexPath.section];
    }

    [cell setCellWithModel:model];
    
    return cell;
}

@end
