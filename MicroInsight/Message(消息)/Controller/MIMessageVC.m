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
    
    [self.recommendArray removeAllObjects];
    [self.dataArray removeAllObjects];
    [self requestData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configUI];
}

- (void)configUI {
    self.title = @"消息";
    [super configLeftBarButtonItem:nil];
    
    [self.view addSubview:self.tableView];
}

- (void)requestData {
    WSWeak(weakSelf)
    [MIRequestManager getAllNotReadMessageWithRequestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        NSInteger code = [jsonData[@"code"] integerValue];
        if (code == 0) {
            NSArray *list = jsonData[@"data"][@"list"];
            for (NSDictionary *dic in list) {
                MIMessageListModel *model = [MIMessageListModel yy_modelWithDictionary:dic];
                if (model.type == MIMessageTypePush) {
                    [weakSelf.recommendArray addObject:model];
                } else {
                   [weakSelf.dataArray addObject:model];
                }
            }
            
            [weakSelf.tableView reloadData];
        }
    }];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        MIOfficialMessageVC *vc = [[MIOfficialMessageVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        MIMessageListModel *model = self.dataArray[indexPath.row];

        //社区作品的评论或点赞
        if (model.type == MIMessageTypePraise || model.type == MIMessageTypeComment) {
            MICommunityDetailVC *vc = [[MICommunityDetailVC alloc] init];
            vc.contentId = model.content_id;
            vc.contentType = model.content_type;
            [self.navigationController pushViewController:vc animated:YES];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [MIRequestManager readMessageWithMessageIds:@[@(model.modelId)] requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
                    
                }];
            });
        } else if (model.type == MIMessageTypeCommentPraise || model.type == MIMessageTypeCommentComment) { //社区作品评论的评论或点赞
            WSWeak(weakSelf)
            [MIRequestManager getMessageSourceWithCommentId:model.comment_id requestToken:[MILocalData getCurrentRequestToken] completed:
             ^(id  _Nonnull jsonData, NSError * _Nonnull error) {
                 
                 NSInteger code = [jsonData[@"code"] integerValue];
                 if (code == 0) {
                     MICommunityDetailVC *vc = [[MICommunityDetailVC alloc] init];
                     vc.contentId = [jsonData[@"data"][@"content_id"] integerValue];
                     vc.contentType = [jsonData[@"data"][@"content_type"] integerValue];
                     [weakSelf.navigationController pushViewController:vc animated:YES];
                     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                         [MIRequestManager readMessageWithMessageIds:@[@(model.modelId)] requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
                             
                         }];
                     });
                 }
             }];
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
    MIMessageListModel *model;
    if (indexPath.section == 0) {
        if (self.recommendArray.count > 0) {
            model = self.recommendArray[indexPath.row];
            [cell setMessageCount:self.recommendArray.count];
        } else {
            model = [[MIMessageListModel alloc] init];
            model.type = MIMessageTypeNone;
        }
    } else {
        model = self.dataArray[indexPath.row];
        [cell setMessageCount:1];
    }
    cell.model = model;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
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
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        MIMessageListModel *model = weakSelf.dataArray[indexPath.row];
        [weakSelf.dataArray removeObject:model];
        [weakSelf.tableView reloadData];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [MIRequestManager readMessageWithMessageIds:@[@(model.modelId)] requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
                
            }];
        });
    }];
    
    return @[deleteRowAction];
}

@end
