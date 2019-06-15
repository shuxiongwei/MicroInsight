//
//  MISupportVC.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/8.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MISupportVC.h"
#import "MIPraiseCell.h"

@interface MISupportVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) NSInteger page;

@end

@implementation MISupportVC

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
        [_tableView registerNib:[UINib nibWithNibName:@"MIPraiseCell" bundle:nil] forCellReuseIdentifier:@"MIPraiseCell"];
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.tableView];
}

- (void)setPraiseArray:(NSMutableArray *)praiseArray {
    dispatch_async(dispatch_get_main_queue(), ^{
        _praiseArray = [NSMutableArray arrayWithArray:praiseArray];
        [self.tableView reloadData];
    });
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.praiseArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MIPraiseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MIPraiseCell" forIndexPath:indexPath];
    MIPraiseModel *model = self.praiseArray[indexPath.row];
    cell.model = model;
    
    WSWeak(weakSelf)
    cell.clickUserIcon = ^(NSInteger userId) {
        if (weakSelf.clickUserIcon) {
            weakSelf.clickUserIcon(userId);
        }
    };
    
    return cell;
}

@end
