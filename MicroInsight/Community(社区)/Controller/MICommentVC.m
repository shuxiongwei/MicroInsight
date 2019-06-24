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
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MIScreenWidth, MIScreenHeight - KNaviBarAllHeight - kBottomViewH - 55) style:UITableViewStylePlain];
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
    
    if (_commentType == MICommentTypeCommunity) {
        [MIRequestManager getCommunityCommentsWithContentId:_contentId contentType:_contentType requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
            
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
    } else {
        [MIRequestManager getTweetCommentsWithTweetId:_contentId requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
            
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
}

- (void)refreshView {
    [self.dataArray removeAllObjects];
    [self requestCommentData:YES];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MICommentModel *model = self.dataArray[indexPath.row];
    if (self.clickParentComment) {
        self.clickParentComment(model);
    }
}

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
    __block MICommentModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    
    WSWeak(weakSelf)
    cell.clickUserIcon = ^(NSInteger userId) {
        if (weakSelf.clickUserIcon) {
            weakSelf.clickUserIcon(userId);
        }
    };
    
    cell.clickShowAllChildComment = ^(MICommentModel * _Nonnull model) {
        if (weakSelf.clickShowAllChildComment) {
            weakSelf.clickShowAllChildComment(model);
        }
    };
    
    cell.clickPraiseComment = ^{
        if (weakSelf.commentType == MICommentTypeCommunity) {
            [MIRequestManager praiseCommunityCommentWithContentId:weakSelf.contentId contentType:weakSelf.contentType commentId:model.modelId requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
                
                NSInteger code = [jsonData[@"code"] integerValue];
                if (code == 0) {
                    NSDictionary *data = jsonData[@"data"];
                    model.isLike = YES;
                    model.likes = [data[@"likes"] integerValue];
                    [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                } else {
                    [MIHudView showMsg:@"点赞失败"];
                }
            }];
        } else {
            [MIRequestManager praiseTweetCommentWithTweetId:weakSelf.contentId commentId:model.modelId requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
                
                NSInteger code = [jsonData[@"code"] integerValue];
                if (code == 0) {
                    NSDictionary *data = jsonData[@"data"];
                    model.isLike = YES;
                    model.likes = [data[@"likes"] integerValue];
                    [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                } else {
                    [MIHudView showMsg:@"点赞失败"];
                }
            }];
        }
    };
    
    return cell;
}

@end
