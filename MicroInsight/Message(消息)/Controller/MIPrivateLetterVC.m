//
//  MIPrivateLetterVC.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/7/6.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIPrivateLetterVC.h"
#import "MIPrivateLetterAlbumVC.h"
#import "MILetterListModel.h"
#import "MIPrivateListCell.h"
#import "MIReviewImageViewController.h"

@interface MIPrivateLetterVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) MIPlaceholderTextView *textView;
@property (nonatomic, strong) UIView *bgTextView;
@property (nonatomic, strong) UIButton *maskView;
@property (nonatomic, strong) NSMutableArray *letterArray;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation MIPrivateLetterVC

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
        [_tableView registerClass:[MIPrivateListCell class] forCellReuseIdentifier:@"letterListCell"];
    }
    return _tableView;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self configBgTextView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (_maskView) {
        [_maskView removeFromSuperview];
        _maskView = nil;
        [_bgTextView removeFromSuperview];
        _bgTextView = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _avatar = [MILocalData getCurrentLoginUserInfo].avatar;
    [self configPrivateLetterUI];
    [self requestReadPrivateLetter];
    [NSThread detachNewThreadSelector:@selector(configTimer) toTarget:self withObject:nil];
}

- (void)configPrivateLetterUI {
    //键盘监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendImageLetterFinish:) name:@"sendImageLetterFinish" object:nil];
    
    [super configLeftBarButtonItem:nil];
    self.view.backgroundColor = UIColorFromRGBWithAlpha(0xF2F3F5, 1);
    self.title = _nickname;
    [self.view addSubview:self.tableView];
}

- (void)releaseObject {
    [self releaseTimer];
}

- (void)configBgTextView {
    _maskView = [UIButton buttonWithType:UIButtonTypeCustom];
    _maskView.frame = MIScreenBounds;
    _maskView.backgroundColor = UIColorFromRGBWithAlpha(0x333333, 0.6);
    _maskView.hidden = YES;
    [_maskView addTarget:self action:@selector(clickMaskView) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.view addSubview:_maskView];
    
    _bgTextView = [[UIView alloc] initWithFrame:CGRectMake(0, MIScreenHeight - kBottomViewH, MIScreenWidth, kBottomViewH)];
    _bgTextView.backgroundColor = [UIColor whiteColor];
    [self.navigationController.view addSubview:_bgTextView];
    
    _textView = [[MIPlaceholderTextView alloc] initWithFrame:CGRectMake(60, 10, MIScreenWidth - 120, 40)];
    _textView.backgroundColor = UIColorFromRGBWithAlpha(0xF2F3F5, 1);
    [_bgTextView addSubview:_textView];
    
    UIButton *photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    photoBtn.frame = CGRectMake(20, 0, 22, 18);
    photoBtn.centerY = _textView.centerY;
    [photoBtn setImage:[UIImage imageNamed:@"icon_message_photo_nor"] forState:UIControlStateNormal];
    [photoBtn addTarget:self action:@selector(clickPhotoBtn) forControlEvents:UIControlEventTouchUpInside];
    [photoBtn setEnlargeEdge:10];
    [_bgTextView addSubview:photoBtn];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.frame = CGRectMake(_bgTextView.width - 60, 0, 60, 40);
    sendBtn.centerY = _textView.centerY;
    [sendBtn setTitle:[MILocalData appLanguage:@"community_key_6"] forState:UIControlStateNormal];
    [sendBtn setTitleColor:UIColorFromRGBWithAlpha(0x333333, 1) forState:UIControlStateNormal];
    sendBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [sendBtn addTarget:self action:@selector(clickSendBtn) forControlEvents:UIControlEventTouchUpInside];
    [_bgTextView addSubview:sendBtn];
}

- (void)requestReadPrivateLetter {
    [self.letterArray removeAllObjects];
    
    WSWeak(weakSelf)
    [MIRequestManager getReadLetterWithUserId:[NSString stringWithFormat:@"%ld", _user_receive_id] requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        NSInteger code = [jsonData[@"code"] integerValue];
        if (code == 0) {
            NSArray *list = jsonData[@"data"][@"list"];
            weakSelf.otherAvatar = jsonData[@"data"][@"avatar"];
            if (list.count > 0) {
                [weakSelf handleData:list completed:^{
                    [weakSelf requestNotReadPrivateLetter:YES];
                }];
            } else {
                [weakSelf requestNotReadPrivateLetter:YES];
            }
        }
    }];
}

- (void)requestNotReadPrivateLetter:(BOOL)needReload {
    WSWeak(weakSelf)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [MIRequestManager getUnreadLetterWithUserId:[NSString stringWithFormat:@"%ld", weakSelf.user_receive_id] requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSInteger code = [jsonData[@"code"] integerValue];
                if (code == 0) {
                    NSArray *list = jsonData[@"data"][@"list"];
                    if (list.count > 0) {
                        [weakSelf handleData:list completed:^{
                            [weakSelf sortLetterList];
                            [weakSelf.tableView reloadData];
                            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:weakSelf.letterArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                        }];
                        
                        if (!needReload) {
                            NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
                            for (NSDictionary *dic in list) {
                                MILetterListModel *model = [MILetterListModel yy_modelWithDictionary:dic];
                                [arr addObject:model.modelId];
                            }
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                [MIRequestManager readMessageWithMessageIds:arr requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
                                    
                                }];
                            });
                        }
                    } else {
                        if (needReload) {
                            [weakSelf sortLetterList];
                            [weakSelf.tableView reloadData];
                            if (weakSelf.letterArray.count > 0) {
                                [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:weakSelf.letterArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                            }
                        }
                    }
                }
            });
        }];
    });
}

- (void)handleData:(NSArray *)list completed:(void (^)(void))completed {
    NSMutableArray *newList = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *dic in list) {
        MILetterListModel *model1 = [MILetterListModel yy_modelWithDictionary:dic];
        
        BOOL has = NO;
        for (MILetterListModel *model2 in self.letterArray) {
            if ([model1.modelId isEqual:model2.modelId]) {
                has = YES;
                break;
            }
        }
        
        if (!has) {
            [newList addObject:model1];
        }
    }
    
    if (newList.count > 0) {
        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t queue = dispatch_queue_create("handleDataQueue", DISPATCH_QUEUE_SERIAL);
        MIUserInfoModel *userInfo = [MILocalData getCurrentLoginUserInfo];
        
        for (MILetterListModel *model in newList) {
//            __block MILetterListModel *model = [MILetterListModel yy_modelWithDictionary:dic];
            if ([model.user_send_id integerValue] == userInfo.uid) {
                model.isSelf = YES;
                model.avatar = self.avatar;
            } else {
                model.avatar = self.otherAvatar;
            }
            
            [self.letterArray addObject:model];
            
            if ([model.type isEqualToString:@"6"]) {
                dispatch_group_enter(group);
                
                [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:model.content] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                    
                } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                    
                    model.image = image;
                    dispatch_group_leave(group);
                }];
            }
        }
        
        dispatch_group_notify(group, queue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completed) {
                    completed();
                }
            });
        });
    } else {
        if (completed) {
            completed();
        }
    }
}

- (void)sortLetterList {
    [self.letterArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        MILetterListModel *model1 = (MILetterListModel *)obj1;
        MILetterListModel *model2 = (MILetterListModel *)obj2;
        return [model1.created_at compare:model2.created_at];
    }];
}

- (void)clickMaskView {
    [_textView resignFirstResponder];
}

- (void)clickPhotoBtn {
    MIPrivateLetterAlbumVC *vc = [[MIPrivateLetterAlbumVC alloc] init];
    vc.user_receive_id = _user_receive_id;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)clickSendBtn {
    WSWeak(weakSelf)
    [MBProgressHUD showStatus:[NSString stringWithFormat:@"%@...", [MILocalData appLanguage:@"other_key_7"]]];
    [MIRequestManager sendLetterWithReceiveId:[NSString stringWithFormat:@"%ld", _user_receive_id] content:_textView.text requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        [weakSelf requestReadPrivateLetter];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
        });
    }];
    
    _textView.text = nil;
    [_textView resignFirstResponder];
}

#pragma mark - 定时器
- (void)configTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(requestNotReadPrivateLetter:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] run];
}

- (void)releaseTimer {
    [_timer invalidate];
    _timer = nil;
}

#pragma mark - Notify
- (void)keyBoardWillShow:(NSNotification *)notification {
    _maskView.hidden = NO;

    // 获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:notification.userInfo];
    // 获取键盘高度
    CGRect keyBoardBounds  = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    // 3.执行动画
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:^{
            self.bgTextView.bottom = MIScreenHeight - keyBoardBounds.size.height;
        }];
    } else {
        self.bgTextView.bottom = MIScreenHeight - keyBoardBounds.size.height;
    }
}

- (void)keyBoardWillHide:(NSNotification *)notification {
    _maskView.hidden = YES;
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:notification.userInfo];
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:^{
            self.bgTextView.bottom = MIScreenHeight;
        }];
    } else {
        self.bgTextView.bottom = MIScreenHeight;
    }
}

- (void)sendImageLetterFinish:(NSNotification *)notification {
    [self requestReadPrivateLetter];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MILetterListModel *model = self.letterArray[indexPath.row];
    return model.cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.letterArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MIPrivateListCell *cell = [MIPrivateListCell cellWithTableView:tableView letterModel:self.letterArray[indexPath.row]];
    
    WSWeak(weakSelf)
    cell.tapImageView = ^(NSString * _Nonnull imageUrl) {
        MIReviewImageViewController *imageVC = [[MIReviewImageViewController alloc] init];
        imageVC.imgPath = imageUrl;
        [weakSelf.navigationController pushViewController:imageVC animated:YES];
    };
    
    return cell;
}

@end
