//
//  MICommentDetailVC.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/17.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MICommentDetailVC.h"
#import "YYText.h"
#import "MIChildCommentCell.h"
#import "MICommunityListModel.h"


@interface MICommentDetailVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) MIPlaceholderTextView *textView;
@property (nonatomic, strong) UIView *bgTextView;
@property (nonatomic, strong) UIButton *maskView;
@property (nonatomic, strong) UIButton *praiseBtn;
@property (nonatomic, assign) CGFloat topHeight;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation MICommentDetailVC

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _topHeight, MIScreenWidth, MIScreenHeight - KNaviBarAllHeight - _topHeight - kBottomViewH) style:UITableViewStylePlain];
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
        [_tableView registerNib:[UINib nibWithNibName:@"MIChildCommentCell" bundle:nil] forCellReuseIdentifier:@"MIChildCommentCell"];
        
        WSWeak(weakSelf);
        _tableView.mj_header = [MJRefreshGifHeader headerWithRefreshingBlock:^{
            weakSelf.page = 1;
            [weakSelf reloadData:YES];
        }];
        
        _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            weakSelf.page += 1;
            [weakSelf reloadData:NO];
        }];
    }
    return _tableView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArray;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self configBgTextView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_textView resignFirstResponder];

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
    
    [self configUI];
}

- (void)configUI {
    self.title = [NSString stringWithFormat:@"%ld条消息", _commentModel.childCount];
    [super configLeftBarButtonItem:nil];
    
    _page = 1;
    [self calculateChildCommentCellHeight];
    [self configTopView];
//    [self configBgTextView];
    [self.view addSubview:self.tableView];
    [self reloadData:YES];
    
    //键盘监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)calculateChildCommentCellHeight {
    YYTextLayout *topLayout = [_commentModel getContentHeightWithStr:_commentModel.content width:MIScreenWidth - 85 font:13 lineSpace:5 maxRow:0];
    _topHeight = 120 + topLayout.textBoundingSize.height;
}

- (void)configTopView {
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MIScreenWidth, _topHeight)];
    topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTopView)];
    [topView addGestureRecognizer:tap];
    
    UIButton *userIcon = [UIButton buttonWithType:UIButtonTypeCustom];
    userIcon.frame = CGRectMake(15, 20, 45, 45);
    [userIcon round:22.5 RectCorners:UIRectCornerAllCorners];
    NSString *imgUrl = [NSString stringWithFormat:@"%@?x-oss-process=image/resize,m_fill,h_45,w_45", _commentModel.avatar];
    [userIcon sd_setImageWithURL:[NSURL URLWithString:imgUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"icon_personal_head_nor"]];
    [userIcon addTarget:self action:@selector(clickUserIcon) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:userIcon];
    
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.text = _commentModel.nickname;
    titleLab.textColor = UIColorFromRGBWithAlpha(0x333333, 1);
    titleLab.font = [UIFont systemFontOfSize:13];
    [topView addSubview:titleLab];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(userIcon.mas_right).offset(15);
        make.bottom.equalTo(userIcon.mas_centerY).offset(-3.5);
        make.width.equalTo(@(150));
    }];
    
    UILabel *timeLab = [[UILabel alloc] init];
    NSArray *strs = [_commentModel.created_at componentsSeparatedByString:@" "];
    timeLab.text = strs.firstObject;
    timeLab.textColor = UIColorFromRGBWithAlpha(0x999999, 1);
    timeLab.font = [UIFont systemFontOfSize:9];
    [topView addSubview:timeLab];
    [timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(userIcon.mas_right).offset(15);
        make.top.equalTo(userIcon.mas_centerY).offset(3.5);
        make.width.equalTo(@(150));
    }];
    
    _praiseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_praiseBtn setImage:[UIImage imageNamed:@"icon_community_praise_nor"] forState:UIControlStateNormal];
    [_praiseBtn setImage:[UIImage imageNamed:@"icon_community_praise_sel"] forState:UIControlStateSelected];
    [_praiseBtn setTitleColor:UIColorFromRGBWithAlpha(0x666666, 1) forState:UIControlStateNormal];
    [_praiseBtn layoutButtonWithEdgeInsetsStyle:MIButtonEdgeInsetsStyleLeft imageTitleSpace:3];
    _praiseBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    [_praiseBtn addTarget:self action:@selector(clickPraiseBtn:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:_praiseBtn];
    [_praiseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-20);
        make.centerY.equalTo(userIcon.mas_centerY);
    }];
    [self updatePraiseBtnStatus];
    
    UILabel *contentLab = [[UILabel alloc] init];
    contentLab.text = _commentModel.content;
    contentLab.numberOfLines = 0;
    contentLab.textColor = UIColorFromRGBWithAlpha(0x333333, 1);
    contentLab.font = [UIFont systemFontOfSize:13];
    [topView addSubview:contentLab];
    [contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(75);
        make.right.offset(-10);
        make.bottom.offset(-40);
        make.top.equalTo(userIcon.mas_bottom).offset(15);
    }];
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
    
    _textView = [[MIPlaceholderTextView alloc] initWithFrame:CGRectMake(20, 10, MIScreenWidth - 80, 40)];
    _textView.backgroundColor = UIColorFromRGBWithAlpha(0xF2F3F5, 1);
    _textView.placeholder = [NSString stringWithFormat:@"%@......", [MILocalData appLanguage:@"other_key_17"]];
    _textView.placeholderColor = UIColorFromRGBWithAlpha(0x999999, 1);
    _textView.placeholderFont = [UIFont systemFontOfSize:11];
    [_bgTextView addSubview:_textView];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.frame = CGRectMake(_bgTextView.width - 60, 0, 60, 40);
    sendBtn.centerY = _textView.centerY;
    [sendBtn setTitle:[MILocalData appLanguage:@"community_key_6"] forState:UIControlStateNormal];
    [sendBtn setTitleColor:UIColorFromRGBWithAlpha(0x333333, 1) forState:UIControlStateNormal];
    sendBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [sendBtn addTarget:self action:@selector(clickSendBtn) forControlEvents:UIControlEventTouchUpInside];
    [_bgTextView addSubview:sendBtn];
}

- (void)updatePraiseBtnStatus {
    [_praiseBtn setTitle:[NSString stringWithFormat:@"%ld", _commentModel.likes] forState:UIControlStateNormal];
    _praiseBtn.selected = _commentModel.isLike;
}

- (void)reloadData:(BOOL)isRefresh {
    
    WSWeak(weakSelf)
    if ([self isTweet]) {
        [MIRequestManager getTweetCommentAndChildCommentListWithTweetId:[_commentModel.tweet_id integerValue] commentId:_commentModel.modelId requestToken:[MILocalData getCurrentRequestToken] page:_page pageSize:10 completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
            
            NSInteger code = [jsonData[@"code"] integerValue];
            if (code == 0) {
                if (isRefresh) {
                    [weakSelf.dataArray removeAllObjects];
                    [weakSelf.tableView.mj_header endRefreshing];
                }
                
                NSArray *list = jsonData[@"data"][@"list"];
                for (NSDictionary *dic in list) {
                    MIChildCommentModel *model = [MIChildCommentModel yy_modelWithDictionary:dic];
                    YYTextLayout *layout = [model getContentHeightWithStr:model.content width:MIScreenWidth - 85 font:11 lineSpace:5 maxRow:0];
                    model.rowHeight = 97 + layout.textBoundingSize.height;
                    [weakSelf.dataArray addObject:model];
                }
                
                if (list.count < 10) {
                    if (!isRefresh) {
                        [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                    }
                } else {
                    if (!isRefresh) {
                        [weakSelf.tableView.mj_footer endRefreshing];
                    }
                }
                
                [weakSelf.tableView reloadData];
            } else {
               
            }
        }];
    } else {
        [MIRequestManager getCommunityCommentAndChildCommentListWithContentId:_commentModel.content_id contentType:_commentModel.content_type commentId:_commentModel.modelId requestToken:[MILocalData getCurrentRequestToken] page:_page pageSize:10 completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
            
            NSInteger code = [jsonData[@"code"] integerValue];
            if (code == 0) {
                if (isRefresh) {
                    [weakSelf.dataArray removeAllObjects];
                    [weakSelf.tableView.mj_header endRefreshing];
                }
                
                NSArray *list = jsonData[@"data"][@"list"];
                for (NSDictionary *dic in list) {
                    MIChildCommentModel *model = [MIChildCommentModel yy_modelWithDictionary:dic];
                    YYTextLayout *layout = [model getContentHeightWithStr:model.content width:MIScreenWidth - 85 font:11 lineSpace:5 maxRow:0];
                    model.rowHeight = 97 + layout.textBoundingSize.height;
                    [weakSelf.dataArray addObject:model];
                }
                
                if (list.count < 10) {
                    if (!isRefresh) {
                        [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                    }
                } else {
                    if (!isRefresh) {
                        [weakSelf.tableView.mj_footer endRefreshing];
                    }
                }
                
                [weakSelf.tableView reloadData];
            } else {
           
            }
        }];
    }
}

- (BOOL)isTweet {
    if ([MIHelpTool isBlankString:_commentModel.tweet_id] || [_commentModel.tweet_id isEqualToString:@"0"]) { //社区作品
        return NO;
    } else { //推文
        return YES;
    }
}

#pragma mark - 事件响应
- (void)tapTopView {
    [_textView becomeFirstResponder];
}

- (void)clickUserIcon {
    MIPersonalVC *vc = [[MIPersonalVC alloc] init];
    vc.userId = _commentModel.user_id;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)clickPraiseBtn:(UIButton *)sender {
    if (_praiseBtn.selected) {
        [MIHudView showMsg:[MILocalData appLanguage:@"other_key_11"]];
    } else {
        WSWeak(weakSelf)
        [MIRequestManager praiseTweetCommentWithTweetId:[_commentModel.tweet_id integerValue] commentId:_commentModel.modelId requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
            
            NSInteger code = [jsonData[@"code"] integerValue];
            if (code == 0) {
                weakSelf.commentModel.likes += 1;
                weakSelf.commentModel.isLike = YES;
                [weakSelf updatePraiseBtnStatus];
            } else {
//                [MIHudView showMsg:@"点赞失败"];
            }
        }];
    }
}

- (void)clickMaskView {
    [_textView resignFirstResponder];
}

- (void)clickSendBtn {
    if ([MIHelpTool isBlankString:_textView.text]) {
        [MIHudView showMsg:[MILocalData appLanguage:@"other_key_13"]];
    } else {
        WSWeak(weakSelf)
        if ([self isTweet]) {
            [MIRequestManager commentTweetCommentWithTweetId:[_commentModel.tweet_id integerValue] commentId:_commentModel.modelId content:_textView.text requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
                
                NSInteger code = [jsonData[@"code"] integerValue];
                if (code == 0) {
                    [weakSelf reloadData:YES];
                } else {
//                    [MIHudView showMsg:@"评论失败"];
                }
            }];
        } else {
            [MIRequestManager commentProductionCommentWithContentId:_commentModel.content_id contentType:_commentModel.content_type commentId:_commentModel.modelId content:_textView.text requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
                
                NSInteger code = [jsonData[@"code"] integerValue];
                if (code == 0) {
                    [weakSelf reloadData:YES];
                } else {
//                    [MIHudView showMsg:@"评论失败"];
                }
            }];
        }
        
        _textView.text = nil;
        [_textView resignFirstResponder];
    }
}

#pragma mark - Notify
- (void)keyBoardWillShow:(NSNotification *) notification {
    _maskView.hidden = NO;
//    [self.view bringSubviewToFront:_maskView];
    
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

- (void)keyBoardWillHide:(NSNotification *) notification {
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


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MIChildCommentModel *model = self.dataArray[indexPath.row];
    return model.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MIChildCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MIChildCommentCell" forIndexPath:indexPath];
    __block MIChildCommentModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    
    WSWeak(weakSelf)
    cell.clickUserIcon = ^(MIChildCommentModel *childModel) {
        MIPersonalVC *vc = [[MIPersonalVC alloc] init];
        vc.userId = childModel.user_id;
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
    
    __weak __typeof(&*cell)weakCell = cell;
    cell.clickPraiseComment = ^{
        if (model.isLike) {
            [MIHudView showMsg:[MILocalData appLanguage:@"other_key_11"]];
        } else {
            if ([weakSelf isTweet]) {
                [MIRequestManager praiseTweetCommentWithTweetId:[model.tweet_id integerValue] commentId:model.modelId requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
                    
                    NSInteger code = [jsonData[@"code"] integerValue];
                    if (code == 0) {
                        model.isLike = YES;
                        model.likes += 1;
                        weakCell.model = model;
                    } else {
//                        [MIHudView showMsg:@"点赞失败"];
                    }
                }];
            } else {
                [MIRequestManager praiseCommunityCommentWithContentId:model.content_id contentType:model.content_type commentId:model.modelId requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
                    
                    NSInteger code = [jsonData[@"code"] integerValue];
                    if (code == 0) {
                        model.isLike = YES;
                        model.likes += 1;
                        weakCell.model = model;
                    } else {
//                        [MIHudView showMsg:@"点赞失败"];
                    }
                }];
            }
        }
    };
    
    return cell;
}

@end
