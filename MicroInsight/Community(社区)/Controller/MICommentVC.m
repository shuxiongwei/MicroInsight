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
#import "MIReportView.h"
#import "MICommentAlertView.h"

@interface MICommentVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) MIReportView *reportView;
@property (nonatomic, strong) MICommentAlertView *commentAlertView;

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
                [weakSelf sortCommentList];
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
                [weakSelf sortCommentList];
                [weakSelf.tableView reloadData];
            }
        }];
    }
}

- (void)sortCommentList {
    [self.dataArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        MICommentModel *model1 = (MICommentModel *)obj1;
        MICommentModel *model2 = (MICommentModel *)obj2;
        return [model2.created_at compare:model1.created_at];
    }];
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
    cell.clickUserIcon = ^(MIChildCommentModel *childModel) {
        if (weakSelf.clickUserIcon) {
            weakSelf.clickUserIcon(childModel);
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
//                    [MIHudView showMsg:@"点赞失败"];
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
//                    [MIHudView showMsg:@"点赞失败"];
                }
            }];
        }
    };
    
    cell.longPressComment = ^(MICommentModel * _Nonnull model) {
        MIUserInfoModel *userInfo = [MILocalData getCurrentLoginUserInfo];
        if (userInfo.uid != model.user_id) {
            
            if (!weakSelf.commentAlertView) {
                weakSelf.commentAlertView = [MICommentAlertView commentAlertView];
                [weakSelf.commentAlertView.commentBtn setTitle:[MILocalData appLanguage:@"other_key_56"] forState:UIControlStateNormal];
                [weakSelf.commentAlertView.reportBtn setTitle:[MILocalData appLanguage:@"community_key_13"] forState:UIControlStateNormal];
                
                NSString *blackStr;
                if (model.isBlack) {
                    blackStr = [MILocalData appLanguage:@"other_key_57"];
                } else {
                    blackStr = [MILocalData appLanguage:@"community_key_16"];
                }
                
                [weakSelf.commentAlertView.blackBtn setTitle:blackStr forState:UIControlStateNormal];
                weakSelf.commentAlertView.frame = MIScreenBounds;
                [[UIApplication sharedApplication].keyWindow addSubview:weakSelf.commentAlertView];
                
                weakSelf.commentAlertView.alertType = ^(NSInteger type) {
                    if (type == 0) {
                        if (weakSelf.clickParentComment) {
                            weakSelf.clickParentComment(model);
                        }
                    } else if (type == 1) {
                        if (!weakSelf.reportView) {
                            weakSelf.reportView = [[MIReportView alloc] initWithFrame:CGRectMake(0, MIScreenHeight, MIScreenWidth, MIScreenHeight)];
                            [[UIApplication sharedApplication].keyWindow addSubview:weakSelf.reportView];

                            weakSelf.reportView.selectReportContent = ^(NSString * _Nonnull content) {
                                
                                [MIRequestManager reportUseWithUserId:[NSString stringWithFormat:@"%ld", model.modelId] reportContent:content requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
                                    
                                    NSInteger code = [jsonData[@"code"] integerValue];
                                    if (code == 0) {
                                        [MIHudView showMsg:[MILocalData appLanguage:@"other_key_15"]];
                                    } else {
                                        //                    [MIHudView showMsg:@"举报失败"];
                                    }
                                }];
                            };
                        }
                        
                        [UIView animateWithDuration:0.3 animations:^{
                            self.reportView.frame = MIScreenBounds;
                        }];
                    } else if (type == 2) {
                        if (model.isBlack) {
                            [MIRequestManager cancelBlackListWithUserId:[NSString stringWithFormat:@"%ld", model.user_id] requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
                                
                                NSInteger code = [jsonData[@"code"] integerValue];
                                if (code == 0) {
                                    [MIHudView showMsg:[MILocalData appLanguage:@"other_key_55"]];
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"blackListNotification" object:nil];
                                    model.isBlack = NO;
                                    [weakSelf.tableView reloadData];
                                }
                            }];
                        } else {
                            [MIRequestManager addBlackListWithUserId:[NSString stringWithFormat:@"%ld", model.user_id] requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
                                
                                NSInteger code = [jsonData[@"code"] integerValue];
                                if (code == 0) {
                                    [MIHudView showMsg:[MILocalData appLanguage:@"other_key_16"]];
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"blackListNotification" object:nil];
                                    model.isBlack = YES;
                                    [weakSelf.tableView reloadData];
                                } else {
                                    //            [MIHudView showMsg:@"拉黑失败"];
                                }
                            }];
                        }
                    }
                };
            }
            
            [UIView animateWithDuration:0.3 animations:^{
                weakSelf.commentAlertView.alpha = 1;
            }];
        }
    };
    
    return cell;
}

@end
