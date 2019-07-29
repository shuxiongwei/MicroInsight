//
//  MIOfficialMessageVC.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/17.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIOfficialMessageVC.h"
#import "MIMessageListCell.h"
#import "MIMessageListModel.h"
#import "MIRecommendDetailVC.h"

@interface MIOfficialMessageVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation MIOfficialMessageVC

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self requestData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configUI];
}

- (void)configUI {
    self.title = [MILocalData appLanguage:@"other_key_6"];
    [super configLeftBarButtonItem:nil];
    
    [self.view addSubview:self.tableView];
}

- (void)getAllMessageData {
    [self.dataArray removeAllObjects];
    
    NSString *sql = [NSString stringWithFormat:@"type == 0"];
    NSUInteger count = [MIMessageListModel rowCountWithWhere:sql];
    self.dataArray = [MIMessageListModel searchToDatabaseFromIndex:0 count:count condition:sql orderBy:@"created_at desc"];
    [self.tableView reloadData];
}

- (void)requestData {
    WSWeak(weakSelf)
    [MIRequestManager getTweetMessageWithRequestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        NSInteger code = [jsonData[@"code"] integerValue];
        if (code == 0) {
            NSArray *list = jsonData[@"data"][@"list"];
            if (list.count > 0) {
                NSMutableArray *tempList = [NSMutableArray arrayWithCapacity:0];
                for (NSDictionary *dic in list) {
                    MIMessageListModel *model = [MIMessageListModel yy_modelWithDictionary:dic];
                    if (![MIHelpTool isBlankString:model.title]) {
                        [weakSelf.dataArray addObject:model];
                    }
                    
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
    MIMessageListModel *model = self.dataArray[indexPath.row];
    MIRecommendDetailVC *vc = [[MIRecommendDetailVC alloc] init];
    vc.tweetId = model.user_send_id;
    [self.navigationController pushViewController:vc animated:YES];
    
    model.status = 1;
    [model updateToDatabase];
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MIMessageListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MIMessageListCell" forIndexPath:indexPath];
    MIMessageListModel *model = self.dataArray[indexPath.row];
    cell.messageModel = model;
    if (model.status == 0) { //未读
        [cell setMessageCount:1];
    } else {
        [cell setMessageCount:0];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
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
        
        MIMessageListModel *model = weakSelf.dataArray[indexPath.row];
        [weakSelf.dataArray removeObject:model];
        [weakSelf.tableView reloadData];
        
        [model deleteToDatabase];
    }];
    
    return @[deleteRowAction];
}

@end
