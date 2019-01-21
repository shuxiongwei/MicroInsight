//
//  MIBlackListViewController.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/1/19.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIBlackListViewController.h"
#import "MIBlackListCell.h"
#import "MIBlackListModel.h"
#import "UIImageView+WebCache.h"

@interface MIBlackListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *blackListT;
@property (nonatomic, strong) NSMutableArray *blackList;

@end

@implementation MIBlackListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"黑名单";
    [super configLeftBarButtonItem:@"返回"];
    
    [_blackListT registerNib:[UINib nibWithNibName:@"MIBlackListCell" bundle:nil] forCellReuseIdentifier:@"MIBlackListCell"];
    _blackListT.separatorStyle = UITableViewCellSeparatorStyleNone;
    _blackList = [NSMutableArray arrayWithCapacity:0];
    
    [self configBlackList];
}

- (void)configBlackList {
    [MIRequestManager getBlackListWithRequestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        [_blackList removeAllObjects];
        NSInteger code = [jsonData[@"code"] integerValue];
        if (code == 0) {
            NSDictionary *data = jsonData[@"data"];
            NSArray *list = data[@"list"];
            for (NSDictionary *dic in list) {
                MIBlackListModel *model = [MIBlackListModel yy_modelWithDictionary:dic];
                [_blackList addObject:model];
                [_blackListT reloadData];
            }
        }
        
        if (_blackList.count == 0) {
            _blackListT.hidden = YES;
        }
    }];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MIBlackListModel *model = _blackList[indexPath.row];
    
    [MIRequestManager cancelBlackListWithUserId:model.userId requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        NSInteger code = [jsonData[@"code"] integerValue];
        if (code == 0) {
            [self configBlackList];
        }
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _blackList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MIBlackListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MIBlackListCell" forIndexPath:indexPath];
    MIBlackListModel *model = _blackList[indexPath.row];
    cell.userName.text = model.nickname;
    
    NSString *imgUrl = [NSString stringWithFormat:@"%@?x-oss-process=image/resize,m_fill,h_%ld,w_%ld", model.avatar, (NSInteger)cell.imgView.size.width / 1, (NSInteger)cell.imgView.size.width / 1];
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"account"] options:SDWebImageRetryFailed];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50;
}

@end
