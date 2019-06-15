//
//  MICommentVC.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/8.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MICommentVC.h"
#import "MICommunityListModel.h"
#import "MICommentCell.h"


@interface MICommentVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation MICommentVC

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        if (@available(iOS 11.0,*))
        {
            _tableView.estimatedRowHeight = 0;
            _tableView.estimatedSectionHeaderHeight = 0;
            _tableView.estimatedSectionFooterHeight = 0;
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [_tableView registerNib:[UINib nibWithNibName:@"MICommentCell" bundle:nil] forCellReuseIdentifier:@"MICommentCell"];
    }
    return _tableView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.tableView];
    [self requestCommentData:YES];
}

- (void)requestCommentData:(BOOL)isRefresh {
    WSWeak(weakSelf)
    [MIRequestManager getCommunityCommentsWithContentId:_communityModel.contentId contentType:_communityModel.contentType requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        NSInteger code = [jsonData[@"code"] integerValue];
        if (code == 0) {
            NSArray *list = jsonData[@"data"][@"list"];
            for (NSDictionary *dic in list) {
                MICommentModel *model = [MICommentModel yy_modelWithDictionary:dic];
                model.rowHeight = [model getRowHeight];
                model.commentHeight = [model getChildCommentTableViewHeight];
                [weakSelf.dataArray addObject:model];
            }
            
            [weakSelf.tableView reloadData];
        }
    }];
}

#pragma mark - UITableViewDelegate


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MICommentModel *model = self.dataArray[indexPath.row];
    return model.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MICommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MICommentCell" forIndexPath:indexPath];
    MICommentModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    
    WSWeak(weakSelf)
    cell.clickUserIcon = ^(NSInteger userId) {
        if (weakSelf.clickUserIcon) {
            weakSelf.clickUserIcon(userId);
        }
    };
    
    cell.clickCommentReplay = ^(MICommentModel * _Nonnull model) {
        if (weakSelf.clickCommentReplay) {
            weakSelf.clickCommentReplay(model);
        }
    };
    
    return cell;
}

@end
