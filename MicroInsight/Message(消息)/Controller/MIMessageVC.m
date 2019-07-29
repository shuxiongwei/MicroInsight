//
//  MIMessageVC.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/12.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIMessageVC.h"
#import "MIMessageListCell.h"
#import "MIMessageListModel.h"
#import "MICommunityDetailVC.h"
#import "MIRecommendDetailVC.h"
#import "MIOfficialMessageVC.h"
#import "MIPrivateLetterVC.h"
#import "MILetterListModel.h"

@interface MIMessageVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *recommendArray; //官方推荐列表

@end

@implementation MIMessageVC

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MIScreenWidth, MIScreenHeight - KNaviBarAllHeight) style:UITableViewStylePlain];
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
        [_tableView registerNib:[UINib nibWithNibName:@"MIMessageListCell" bundle:nil] forCellReuseIdentifier:@"MIMessageListCell"];
    }
    return _tableView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArray;
}

- (NSMutableArray *)recommendArray {
    if (!_recommendArray) {
        _recommendArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _recommendArray;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self getAllNotReadMessageData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configUI];
    [self getAllMessageData];
}

- (void)configUI {
    self.title = [MILocalData appLanguage:@"other_key_5"];
    [super configLeftBarButtonItem:nil];
    
    [self.view addSubview:self.tableView];
}

- (void)getAllMessageData {
    [self.recommendArray removeAllObjects];
    [self.dataArray removeAllObjects];
    
    MIUserInfoModel *userInfo = [MILocalData getCurrentLoginUserInfo];
    NSString *sql = [NSString stringWithFormat:@"user_send_id != %ld", userInfo.uid];
    NSUInteger count = [MIMessageListModel rowCountWithWhere:sql];
    NSArray *list = [MIMessageListModel searchToDatabaseFromIndex:0 count:count condition:sql orderBy:@"created_at desc"];
    
    NSMutableArray *tempList = [NSMutableArray arrayWithCapacity:0];
    for (MIMessageListModel *model in list) {
        BOOL has = NO;
        if (tempList.count > 0) {
            for (MIMessageListModel *mod in tempList) {
                if (mod.user_send_id == model.user_send_id || mod.type == MIMessageTypePush) {
                    has = YES;
                    break;
                }
            }
        }
        
        if (!has) {
            [tempList addObject:model];
        }
    }
    
    if (tempList.count > 0) {
        for (MIMessageListModel *mod in tempList) {
            NSMutableArray *tweetList = [NSMutableArray arrayWithCapacity:0];
            NSMutableArray *praiseList = [NSMutableArray arrayWithCapacity:0];
            NSMutableArray *commentList = [NSMutableArray arrayWithCapacity:0];
            NSMutableArray *letterList = [NSMutableArray arrayWithCapacity:0];
            MIMessageModel *tweetModel = [[MIMessageModel alloc] init];
            MIMessageModel *praiseModel = [[MIMessageModel alloc] init];
            MIMessageModel *commentModel = [[MIMessageModel alloc] init];
            MIMessageModel *letterModel = [[MIMessageModel alloc] init];
            
            for (MIMessageListModel *model in list) {
                if (mod.user_send_id == model.user_send_id) {
                    if (model.type == MIMessageTypePraise || model.type == MIMessageTypeCommentPraise) {
                        if (!praiseModel.messageModel) {
                            praiseModel.messageModel = model;
                        }
                        if (model.status == 0) {
                            praiseModel.notReadCount += 1;
                        }
                        [praiseList addObject:model];
                    } else if (model.type == MIMessageTypeComment || model.type == MIMessageTypeCommentComment) {
                        if (!commentModel.messageModel) {
                            commentModel.messageModel = model;
                        }
                        if (model.status == 0) {
                            commentModel.notReadCount += 1;
                        }
                        [commentList addObject:model];
                    } else if (model.type == MIMessageTypeLetter || model.type == MIMessageTypeLetterImage) {
                        if (!letterModel.messageModel) {
                            letterModel.messageModel = model;
                        }
                        if (model.status == 0) {
                            letterModel.notReadCount += 1;
                        }
                        [letterList addObject:model];
                    } else {
                        if (!tweetModel.messageModel) {
                            tweetModel.messageModel = model;
                        }
                        if (model.status == 0) {
                            tweetModel.notReadCount += 1;
                        }
                        [tweetList addObject:model];
                    }
                }
            }
            
            tweetModel.messageList = tweetList;
            praiseModel.messageList = praiseList;
            commentModel.messageList = commentList;
            letterModel.messageList = letterList;
            
            if (tweetList.count > 0) {
                [self.recommendArray addObject:tweetModel];
            }
            
            if (praiseList.count > 0) {
                [self.dataArray addObject:praiseModel];
            }
            
            if (commentList.count > 0) {
                [self.dataArray addObject:commentModel];
            }
            
            if (letterList.count > 0) {
                [self.dataArray addObject:letterModel];
            }
        }
        
        [self.tableView reloadData];
    }
}

- (void)getAllNotReadMessageData {
    WSWeak(weakSelf)
    [MIRequestManager getAllNotReadMessageWithRequestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        NSInteger code = [jsonData[@"code"] integerValue];
        if (code == 0) {
            NSArray *list = jsonData[@"data"][@"list"];
            if (list.count > 0) {
                NSMutableArray *tempList = [NSMutableArray arrayWithCapacity:0];
                for (NSDictionary *dic in list) {
                    MIMessageListModel *model = [MIMessageListModel yy_modelWithDictionary:dic];
                    
                    NSUInteger count = [MILetterListModel rowCountWithWhere:nil];
                    NSArray *letterList = [MILetterListModel searchToDatabaseFromIndex:0 count:count condition:nil orderBy:nil];
                    for (MILetterListModel *mod in letterList) {
                        if ([mod.modelId integerValue] == model.modelId) {
                            model.status = 1;
                            [mod deleteToDatabase];
                            break;
                        }
                    }
                    
                    [model updateToDatabase];
                    
                    [tempList addObject:@(model.modelId)];
                    if (tempList.count > 0) {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            [MIRequestManager readMessageWithMessageIds:tempList requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
                                
                            }];
                        });
                    }
                }
                
                [weakSelf getAllMessageData];
            }
        }
    }];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        MIOfficialMessageVC *vc = [[MIOfficialMessageVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        
        if (self.recommendArray.count > 0) {
            MIMessageModel *messageModel = self.recommendArray[indexPath.row];
            for (MIMessageListModel *model in messageModel.messageList) {
                model.status = 1;
                messageModel.notReadCount -= 1;
                [model updateToDatabase];
            }
            
            [self.tableView reloadData];
        }
    } else {
        MIMessageModel *model = self.dataArray[indexPath.row];
        for (MIMessageListModel *mod in model.messageList) {
            mod.status = 1;
            model.notReadCount -= 1;
            [mod updateToDatabase];
        }
        
        [self.tableView reloadData];
        
        //社区作品的评论或点赞
        if (model.messageModel.type == MIMessageTypePraise || model.messageModel.type == MIMessageTypeComment) {
            MICommunityDetailVC *vc = [[MICommunityDetailVC alloc] init];
            vc.contentId = model.messageModel.content_id;
            vc.contentType = model.messageModel.content_type;
            [self.navigationController pushViewController:vc animated:YES];
        } else if (model.messageModel.type == MIMessageTypeCommentPraise || model.messageModel.type == MIMessageTypeCommentComment) { //社区作品评论的评论或点赞
            WSWeak(weakSelf)
            [MIRequestManager getMessageSourceWithCommentId:model.messageModel.comment_id requestToken:[MILocalData getCurrentRequestToken] completed:
             ^(id  _Nonnull jsonData, NSError * _Nonnull error) {
                 
                 NSInteger code = [jsonData[@"code"] integerValue];
                 if (code == 0) {
                     MICommunityDetailVC *vc = [[MICommunityDetailVC alloc] init];
                     vc.contentId = [jsonData[@"data"][@"content_id"] integerValue];
                     vc.contentType = [jsonData[@"data"][@"content_type"] integerValue];
                     [weakSelf.navigationController pushViewController:vc animated:YES];
                 }
             }];
        } else if (model.messageModel.type == MIMessageTypeLetter || model.messageModel.type == MIMessageTypeLetterImage) {
            MIPrivateLetterVC *vc = [[MIPrivateLetterVC alloc] init];
            vc.user_receive_id = model.messageModel.user_send_id;
            vc.nickname = model.messageModel.nickname;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.dataArray.count > 0) { //还有其他消息
        return 2;
    } else { //只有官方消息
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
       return self.dataArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MIMessageListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MIMessageListCell" forIndexPath:indexPath];
    MIMessageModel *model;
    
    if (indexPath.section == 0) {
        if (self.recommendArray.count > 0) {
            model = self.recommendArray[indexPath.row];
            cell.model = model;
            
            if (model.status == 0) {
                [cell setMessageCount:model.notReadCount];
            } else {
                [cell setMessageCount:0];
            }
        } else {
            model = [[MIMessageModel alloc] init];
            model.messageModel = [[MIMessageListModel alloc] init];
            model.messageModel.type = MIMessageTypeNone;
            cell.model = model;
            [cell setMessageCount:0];
        }
    } else {
        model = self.dataArray[indexPath.row];
        cell.model = model;
        
        if (model.status == 0) {
            [cell setMessageCount:model.notReadCount];
        } else {
            [cell setMessageCount:0];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return NO;
    }
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WSWeak(weakSelf)
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:[MILocalData appLanguage:@"album_key_7"] handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        MIMessageModel *model = weakSelf.dataArray[indexPath.row];
        [weakSelf.dataArray removeObject:model];
        [weakSelf.tableView reloadData];
        
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
        for (MIMessageListModel *mod in model.messageList) {
            [arr addObject:@(mod.modelId)];
            [mod deleteToDatabase];
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [MIRequestManager readMessageWithMessageIds:arr requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
                
            }];
        });
    }];
    
    return @[deleteRowAction];
}

@end
