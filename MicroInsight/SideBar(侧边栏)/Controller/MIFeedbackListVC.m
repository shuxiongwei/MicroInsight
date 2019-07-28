//
//  MIFeedbackListVC.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/7/14.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIFeedbackListVC.h"
#import "MIFeedbackListModel.h"
#import "MIFeedbackListCell.h"
#import "MicroInsight-Swift.h"

@interface MIFeedbackListVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *letterArray;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation MIFeedbackListVC

- (NSMutableArray *)letterArray {
    if (!_letterArray) {
        _letterArray = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _letterArray;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MIScreenWidth, MIScreenHeight - KNaviBarAllHeight - kBottomViewH) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = UIColorFromRGBWithAlpha(0xF2F3F5, 1);
        _tableView.tableFooterView = [[UIView alloc] init];
        if (@available(iOS 11.0,*))
        {
            _tableView.estimatedRowHeight = 0;
            _tableView.estimatedSectionHeaderHeight = 0;
            _tableView.estimatedSectionFooterHeight = 0;
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [_tableView registerClass:[MIFeedbackListCell class] forCellReuseIdentifier:@"listCell"];
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(feedbackFinish:) name:@"feedbackFinish" object:nil];
    
    [super configLeftBarButtonItem:nil];
    self.title = [MILocalData appLanguage:@"feekback_key_1"];
    self.view.backgroundColor = UIColorFromRGBWithAlpha(0xF2F3F5, 1);
    
    [self.view addSubview:self.tableView];
    
    UIButton *questionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    questionBtn.frame = CGRectMake(0, MIScreenHeight - KNaviBarAllHeight - kBottomViewH, MIScreenWidth, kBottomViewH);
    questionBtn.backgroundColor = [UIColor whiteColor];
    [questionBtn setTitle:[MILocalData appLanguage:@"other_key_49"] forState:UIControlStateNormal];
    questionBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [questionBtn setTitleColor:UIColorFromRGBWithAlpha(0x333333, 1) forState:UIControlStateNormal];
    [questionBtn addTarget:self action:@selector(clickQuestionBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:questionBtn];
    
    [self requestFeedbackList];
}

- (void)requestFeedbackList {
    [self.letterArray removeAllObjects];
    
    [MIRequestManager getFeedbackListWithRequestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        NSInteger code = [jsonData[@"code"] integerValue];
        if (code == 0) {
            NSArray *list = jsonData[@"data"][@"list"];
            MIUserInfoModel *userInfo = [MILocalData getCurrentLoginUserInfo];
            for (NSDictionary *dic in list) {
                MIFeedbackListModel *model = [MIFeedbackListModel yy_modelWithDictionary:dic];
                if ([model.type isEqualToString:@"0"]) {
                    model.isSelf = YES;
                    model.avatar = userInfo.avatar;
                }
                [self.letterArray addObject:model];
            }
            
            MIFeedbackListModel *firstMod = [[MIFeedbackListModel alloc] init];
            firstMod.feedback = @"感谢您使用Tipscope APP,有任何意见 或建议请反馈给我们，希望能给您更好 的使用体验！";
            firstMod.type = @"1";
            NSDate *date = [NSDate date];
            firstMod.created_at = [date stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
            [self.letterArray insertObject:firstMod atIndex:0];
            
            [self.tableView reloadData];
            if (self.letterArray.count > 0) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.letterArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
        }
    }];
}

- (void)clickQuestionBtn:(UIButton *)sender {
    MIFeedbackVC *vc = [[MIFeedbackVC alloc] initWithNibName:@"MIFeedbackVC" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)feedbackFinish:(NSNotification *)notification {
    [self requestFeedbackList];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MIFeedbackListModel *model = self.letterArray[indexPath.row];
    return model.cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.letterArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MIFeedbackListCell *cell = [MIFeedbackListCell cellWithTableView:tableView letterModel:self.letterArray[indexPath.row]];
    return cell;
}

@end
