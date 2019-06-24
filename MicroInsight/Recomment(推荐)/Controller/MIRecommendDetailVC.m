//
//  MIRecommendDetailVC.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/14.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIRecommendDetailVC.h"
#import "MICommentVC.h"
#import "MISupportVC.h"
#import "MICommunityListModel.h"
#import "MITweetModel.h"
#import "YYText.h"
#import "MIRecommendDetailCell.h"
#import "MICommentDetailVC.h"
#import "MIReportView.h"
#import "MIReviewImageViewController.h"

@interface MIRecommendDetailVC () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, WMPageControllerDelegate, WMPageControllerDataSource, MIShareManagerDelete>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *commentBtn;
@property (nonatomic, strong) UIButton *praiseBtn;
@property (nonatomic, strong) MICommentVC *commentVC;
@property (nonatomic, strong) MISupportVC *supportVC;
@property (nonatomic, strong) NSArray *titleCategories;
@property (nonatomic, assign) CGFloat kHeadViewH;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *timeLab;
@property (nonatomic, strong) UIButton *readingBtn;
@property (nonatomic, strong) MITweetModel *tweetModel;
@property (nonatomic, strong) NSMutableArray *sectionArray;
@property (nonatomic, strong) NSMutableArray *praiseArray;
/* 标识当前评论类型(0:评论当前作品，1:评论作品的评论) */
@property (nonatomic, assign) NSInteger currentCommentType;
@property (nonatomic, strong) MICommentModel *currentModel;
@property (nonatomic, strong) MIPlaceholderTextView *textView;
@property (nonatomic, strong) UIView *bgTextView;
@property (nonatomic, strong) UIButton *maskView;
@property (nonatomic, strong) MIReportView *reportView;
@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, strong) UIView *topBarView;

@end

@implementation MIRecommendDetailVC

#pragma mark - 懒加载
- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, MIScreenHeight - kBottomViewH, MIScreenWidth, kBottomViewH)];
        _bottomView.backgroundColor = UIColorFromRGBWithAlpha(0xF2F3F5, 1);
        [self.view addSubview:_bottomView];
        
        _commentBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(0, 0, _bottomView.width / 2.0, _bottomView.height) normalTitle:nil normalTitleColor:[UIColor blackColor] highlightedTitleColor:nil selectedColor:nil titleFont:10 normalImage:[UIImage imageNamed:@"icon_community_comment_nor"] highlightedImage:nil selectedImage:[UIImage imageNamed:@"icon_community_comment_sel"] touchUpInSideTarget:self action:@selector(clickBottomCommentBtn:)];
        [_commentBtn layoutButtonWithEdgeInsetsStyle:MIButtonEdgeInsetsStyleTop imageTitleSpace:2];
        [_bottomView addSubview:_commentBtn];
        
        _praiseBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(_bottomView.width / 2.0, 0, _bottomView.width / 2.0, _bottomView.height) normalTitle:nil normalTitleColor:[UIColor blackColor] highlightedTitleColor:nil selectedColor:nil titleFont:10 normalImage:[UIImage imageNamed:@"icon_community_praise_nor"] highlightedImage:nil selectedImage:[UIImage imageNamed:@"icon_community_praise_sel"] touchUpInSideTarget:self action:@selector(clickBottomPraiseBtn:)];
        [_praiseBtn layoutButtonWithEdgeInsetsStyle:MIButtonEdgeInsetsStyleTop imageTitleSpace:2];
        [_bottomView addSubview:_praiseBtn];
    }
    
    return _bottomView;
}

- (NSArray *)titleCategories {
    if (!_titleCategories) {
        _titleCategories = @[@"评论", @"点赞"];
    }
    return _titleCategories;
}

- (NSMutableArray *)sectionArray {
    if (!_sectionArray) {
        _sectionArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _sectionArray;
}

- (NSMutableArray *)praiseArray {
    if (!_praiseArray) {
        _praiseArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _praiseArray;
}

- (UIView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, KNaviBarAllHeight, MIScreenWidth, MIScreenHeight - KNaviBarAllHeight)];
        _loadingView.backgroundColor = UIColorFromRGBWithAlpha(0xF2F3F5, 1);
    }
    return _loadingView;
}

#pragma mark - 生命周期
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [self.view bringSubviewToFront:_topBarView];
    self.bottomView.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.bottomView.hidden = YES;
}

- (void)viewDidLoad {
    [self setUpUI];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configDetailUI];
    [self requestDetailDataNeedRefreshTopView:YES needRefreshCommentView:YES needRefreshSupportView:YES];
    //键盘监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - 配置UI
- (void)configDetailUI {
    self.title = @"文章详情";
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(backAction) image:[UIImage imageNamed:@"icon_login_back_nor"]];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(clickExtendBtn) image:[UIImage imageNamed:@"icon_community_more_nor"]];
    
//    //因第三方self.view=scrollView，被迫将bottomView加在self.navigationController.view上了
    [self.navigationController.view addSubview:self.bottomView];
    
    _titleLab = [[UILabel alloc] init];
    _titleLab.textColor = UIColorFromRGBWithAlpha(0x333333, 1);
    _titleLab.font = [UIFont systemFontOfSize:17];
    [self.view addSubview:_titleLab];
    [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(30);
        make.left.offset(20);
        make.right.offset(-20);
        make.height.equalTo(@(20));
    }];
    
    _timeLab = [[UILabel alloc] init];
    _timeLab.textColor = UIColorFromRGBWithAlpha(0x999999, 1);
    _timeLab.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:_timeLab];
    [_timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLab.mas_bottom).offset(5);
        make.left.offset(20);
        make.height.equalTo(@(15));
    }];
    
    _readingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_readingBtn setTitleColor:UIColorFromRGBWithAlpha(0x999999, 1) forState:UIControlStateNormal];
    _readingBtn.titleLabel.font = [UIFont systemFontOfSize:11];
    [_readingBtn setImage:[UIImage imageNamed:@"icon_community_reading_nor"] forState:UIControlStateNormal];
    [_readingBtn layoutButtonWithEdgeInsetsStyle:MIButtonEdgeInsetsStyleLeft imageTitleSpace:3];
    [self.view addSubview:_readingBtn];
    [_readingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.timeLab.mas_right).offset(30);
        make.centerY.equalTo(self.timeLab);
        make.height.equalTo(@(15));
    }];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
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
    [_tableView registerNib:[UINib nibWithNibName:@"MIRecommendDetailCell" bundle:nil] forCellReuseIdentifier:@"MIRecommendDetailCell"];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(20);
        make.top.equalTo(self.timeLab.mas_bottom).offset(30);
        make.height.equalTo(@(20));
        make.width.equalTo(@(MIScreenWidth - 40));
    }];
    
    UIView *marginView = [[UIView alloc] init];
    marginView.backgroundColor = UIColorFromRGBWithAlpha(0xF2F3F5, 1);
    [self.view addSubview:marginView];
    [marginView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(0);
        make.width.equalTo(@(MIScreenWidth));
        make.top.equalTo(self.tableView.mas_bottom).offset(0);
        make.height.equalTo(@(15));
    }];
    
    [self configTopBarView];
    [self configBgTextView];
}

- (void)setUpUI {
    self.titleSizeNormal = 14;
    self.titleSizeSelected = 14;
    self.menuViewStyle = WMMenuViewStyleLine;
    self.menuItemWidth = MIScreenWidth / self.titleCategories.count;
    self.menuViewHeight = 55;
    self.titleColorSelected = UIColorFromRGBWithAlpha(0x333333, 1);
    self.titleColorNormal = UIColorFromRGBWithAlpha(0x666666, 1);
    self.progressColor = UIColorFromRGBWithAlpha(0x2D2D2D, 1);
    self.progressWidth = 30;
    self.progressHeight = 3;
    self.progressViewCornerRadius = 2.0;
    self.progressViewBottomSpace = 7;
    self.minimumHeaderViewHeight = 0;
    self.maximumHeaderViewHeight = _kHeadViewH;
    
    [self forceLayoutSubviews];
}

- (void)configBgTextView {
    _maskView = [UIButton buttonWithType:UIButtonTypeCustom];
    _maskView.frame = self.view.bounds;
    _maskView.backgroundColor = UIColorFromRGBWithAlpha(0x333333, 0.6);
    _maskView.hidden = YES;
    [_maskView addTarget:self action:@selector(clickMaskView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_maskView];
    
    _bgTextView = [[UIView alloc] initWithFrame:CGRectMake(0, MIScreenHeight - kBottomViewH, MIScreenWidth, kBottomViewH)];
    _bgTextView.backgroundColor = UIColorFromRGBWithAlpha(0xF2F3F5, 1);
    _bgTextView.hidden = YES;
    [self.navigationController.view addSubview:_bgTextView];
    
    _textView = [[MIPlaceholderTextView alloc] initWithFrame:CGRectMake(20, 10, MIScreenWidth - 80, 40)];
    _textView.backgroundColor = [UIColor whiteColor];
    _textView.placeholder = @"写评论......";
    _textView.placeholderColor = UIColorFromRGBWithAlpha(0x999999, 1);
    _textView.placeholderFont = [UIFont systemFontOfSize:11];
    [_bgTextView addSubview:_textView];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.frame = CGRectMake(_bgTextView.width - 60, 0, 60, 40);
    sendBtn.centerY = _textView.centerY;
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn setTitleColor:UIColorFromRGBWithAlpha(0x333333, 1) forState:UIControlStateNormal];
    sendBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [sendBtn addTarget:self action:@selector(clickSendBtn) forControlEvents:UIControlEventTouchUpInside];
    [_bgTextView addSubview:sendBtn];
 
    _currentCommentType = 0;
}

- (void)configTopBarView {
    _topBarView = [[UIView alloc] initWithFrame:CGRectMake(0, -KNaviBarAllHeight, MIScreenWidth, KStatusHeight)];
    _topBarView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_topBarView];
}

- (void)refreshHeaderFrame {
    self.maximumHeaderViewHeight = _kHeadViewH;
    [self forceLayoutSubviews];
}

- (void)updateCommentsTitle:(NSInteger)comments {
    [self.menuView updateTitle:[NSString stringWithFormat:@"评论 %ld", comments] atIndex:0 andWidth:NO];
}

- (void)updateLikesTitle:(NSInteger)likes {
    [self.menuView updateTitle:[NSString stringWithFormat:@"点赞 %ld", likes] atIndex:1 andWidth:NO];
}

- (void)updateComments:(NSInteger)comments {
    [self.menuView updateTitle:[NSString stringWithFormat:@"评论 %ld", comments] atIndex:0 andWidth:NO];
    [_commentBtn setTitle:[NSString stringWithFormat:@"%ld", comments] forState:UIControlStateNormal];
}

- (void)updateLiks:(NSInteger)likes {
    [self.menuView updateTitle:[NSString stringWithFormat:@"点赞 %ld", likes] atIndex:1 andWidth:NO];
    [_praiseBtn setTitle:[NSString stringWithFormat:@"%ld", likes] forState:UIControlStateNormal];
}

- (void)refreshSubViews {
    _titleLab.text = _tweetModel.title;
    NSArray *strs = [_tweetModel.created_at componentsSeparatedByString:@" "];
    _timeLab.text = strs.firstObject;
    [_readingBtn setTitle:[NSString stringWithFormat:@"%ld", _tweetModel.readings] forState:UIControlStateNormal];
}

/**
 请求推文作品的详情数据
 
 @param needRefreshTopView 是否需要刷新头部视图
 @param needRefreshCommentView 是否需要刷新评论视图
 @param needRefreshSupportView 是否需要刷新点赞视图
 */
- (void)requestDetailDataNeedRefreshTopView:(BOOL)needRefreshTopView
                     needRefreshCommentView:(BOOL)needRefreshCommentView
                     needRefreshSupportView:(BOOL)needRefreshSupportView {
    
//    if (needRefreshTopView) {
//        [[UIApplication sharedApplication].keyWindow addSubview:self.loadingView];
//        [MBProgressHUD showMessage:@"数据加载中，请稍后" toView:self.loadingView];
//    }
    
    WSWeak(weakSelf)
    [MIRequestManager getSingleTweetWithId:_tweetId requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [MBProgressHUD hideHUDForView:weakSelf.loadingView];
//            [weakSelf.loadingView removeFromSuperview];
//            weakSelf.loadingView = nil;
//        });
        
        NSInteger code = [jsonData[@"code"] integerValue];
        if (code == 0) {
            NSDictionary *data = jsonData[@"data"];
            NSDictionary *tweetDic = data[@"tweet"];
            
            if (needRefreshTopView) {
                weakSelf.tweetModel = [MITweetModel yy_modelWithDictionary:tweetDic];
                weakSelf.praiseBtn.selected = weakSelf.tweetModel.isLike;
                [weakSelf refreshSubViews];
                
                weakSelf.kHeadViewH += 115;
                
                //table的高度
                CGFloat tableViewHeight = 0;
                NSArray *sections = data[@"sections"];
                for (NSDictionary *sectionDic in sections) {
                    MITweetSectionModel *model = [MITweetSectionModel yy_modelWithDictionary:sectionDic];
                    [weakSelf.sectionArray addObject:model];
                    
                    if ([model.type isEqualToString:@"1"]) { //文本
                        NSString *content = model.content;
                        NSArray *strs = [content componentsSeparatedByString:@"\r\n"];
                        for (NSString *str in strs) {
                            YYTextLayout *layout = [model getContentHeightWithStr:str width:MIScreenWidth - 40 font:14 lineSpace:5 maxRow:0];
                            model.contentHeight += layout.textBoundingSize.height;
                        }
                        model.contentHeight += 10;
                    } else if ([model.type isEqualToString:@"2"]) { //图片
                        CGFloat width = MIScreenWidth - 60;
                        CGFloat height = width * 190.0 / 315.0;
                        model.contentHeight = height + 10;
                    } else if ([model.type isEqualToString:@"3"]) { //视频
                        CGFloat width = MIScreenWidth - 60;
                        CGFloat height = width * 190.0 / 315.0;
                        model.contentHeight = height + 10;
                    }
                    
                    tableViewHeight += model.contentHeight;
                    weakSelf.kHeadViewH += model.contentHeight;
                }
                
                [weakSelf refreshHeaderFrame];
                [weakSelf.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.equalTo(@(tableViewHeight));
                }];
                [weakSelf.tableView reloadData];
            } else {
                weakSelf.tweetModel.comments = [tweetDic[@"comments"] integerValue];
                weakSelf.tweetModel.likes = [tweetDic[@"likes"] integerValue];
            }
            
            if (needRefreshCommentView) {
                [weakSelf updateComments:[tweetDic[@"comments"] integerValue]];
                
                if (!needRefreshTopView || !needRefreshSupportView) {
                    [weakSelf.commentVC refreshView];
                }
            }
            
            if (needRefreshSupportView) {
                NSArray *likes = data[@"likes"];
                for (NSDictionary *likeDic in likes) {
                    MIPraiseModel *model = [MIPraiseModel yy_modelWithDictionary:likeDic];
                    [weakSelf.praiseArray addObject:model];
                }
                
                [weakSelf.praiseBtn setTitle:[NSString stringWithFormat:@"%ld", weakSelf.praiseArray.count] forState:UIControlStateNormal];
                weakSelf.supportVC.praiseArray = weakSelf.praiseArray;
                [weakSelf updateLiks:weakSelf.praiseArray.count];
            }
        } else {
            
        }
    }];
}

#pragma mark - Notify
- (void)keyBoardWillShow:(NSNotification *) notification {
    _bgTextView.hidden = NO;
    _maskView.hidden = NO;
    [self.view bringSubviewToFront:_maskView];
    
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
    _bgTextView.hidden = YES;
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

#pragma mark - 事件响应
- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickExtendBtn {
    [[QZShareMgr shareManager] showShareType:QZShareTypeTweet inVC:nil];
    [QZShareMgr shareManager].delegate = self;
    [QZShareMgr shareManager].shareWebUrl = [NSString stringWithFormat:@"http://www.tipscope.com/tweet.html?token=%@&id=%ld", [MILocalData getCurrentRequestToken], _tweetId];
    [QZShareMgr shareManager].shareImg = [UIImage imageNamed:@"AppIcon"];
}

- (void)clickBottomCommentBtn:(UIButton *)sender {
    [_textView becomeFirstResponder];
    _currentCommentType = 0;
}

- (void)clickBottomPraiseBtn:(UIButton *)sender {
    if (sender.selected) {
        [MIHudView showMsg:@"您已经点过赞该作品"];
    } else {
        WSWeak(weakSelf)
        [MIRequestManager praiseTweetWithTweetId:_tweetId requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
            
            NSInteger code = [jsonData[@"code"] integerValue];
            if (code == 0) {
                weakSelf.praiseBtn.selected = YES;
                [weakSelf requestDetailDataNeedRefreshTopView:NO needRefreshCommentView:NO needRefreshSupportView:YES];
            } else {
                [MIHudView showMsg:@"点赞失败"];
            }
        }];
    }
}

- (void)clickSendBtn {
    if ([MIHelpTool isBlankString:_textView.text]) {
        [MIHudView showMsg:@"请输入评论内容"];
        return;
    }
    
    WSWeak(weakSelf);
    [MIRequestManager checkSensitiveWord:_textView.text completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        NSInteger code = [jsonData[@"code"] integerValue];
        if (code == 0) {
            if (weakSelf.currentCommentType == 0) {
                [MIRequestManager commentTweetWithTweetId:weakSelf.tweetId content:weakSelf.textView.text requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
                    
                    NSInteger code = [jsonData[@"code"] integerValue];
                    if (code == 0) {
                        [weakSelf requestDetailDataNeedRefreshTopView:NO needRefreshCommentView:YES needRefreshSupportView:NO];
                    } else {
                        [MIHudView showMsg:@"评论失败"];
                    }
                }];
            } else {
                [MIRequestManager commentTweetCommentWithTweetId:weakSelf.tweetId commentId:weakSelf.currentModel.modelId content:weakSelf.textView.text requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
                    
                    NSInteger code = [jsonData[@"code"] integerValue];
                    if (code == 0) {
                        [weakSelf requestDetailDataNeedRefreshTopView:NO needRefreshCommentView:YES needRefreshSupportView:NO];
                    } else {
                        [MIHudView showMsg:@"评论失败"];
                    }
                }];
            }
        } else if (code == -1) {
            [MIHudView showMsg:@"评论不能含有敏感词"];
        }
        
        weakSelf.textView.text = nil;
        [weakSelf.textView resignFirstResponder];
    }];
}

- (void)clickMaskView {
    [_textView resignFirstResponder];
}

#pragma mark - MIShareManagerDelete
- (void)shareManagerCopyLinkAction {
    
}

- (void)shareManagerGoHomeAction {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)shareManagerReportAction {
    if (!_reportView) {
        _reportView = [[MIReportView alloc] initWithFrame:CGRectMake(0, MIScreenHeight, MIScreenWidth, MIScreenHeight)];
        [[UIApplication sharedApplication].keyWindow addSubview:_reportView];
        
        WSWeak(weakSelf)
        _reportView.selectReportContent = ^(NSString * _Nonnull content) {
            
            [MIRequestManager reportUseWithUserId:[NSString stringWithFormat:@"%ld", weakSelf.tweetModel.modelId] reportContent:content requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
                
                NSInteger code = [jsonData[@"code"] integerValue];
                if (code == 0) {
                    [MIHudView showMsg:@"举报成功"];
                } else {
                    [MIHudView showMsg:@"举报失败"];
                }
            }];
        };
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.reportView.frame = MIScreenBounds;
    }];
}

#pragma mark - UITableViewDelegate


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sectionArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MITweetSectionModel *model = self.sectionArray[indexPath.row];
    return model.contentHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MIRecommendDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MIRecommendDetailCell" forIndexPath:indexPath];
    MITweetSectionModel *model = self.sectionArray[indexPath.row];
    cell.model = model;
    
    WSWeak(weakSelf)
    cell.clickPlayBtn = ^(NSString * _Nonnull videoUrl) {
        MIVideoUploadVC *vc = [[MIVideoUploadVC alloc] init];
        vc.networkVideoUrl = videoUrl;
        vc.notUpload = @"1";
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
    
    cell.clickImageView = ^(NSString * _Nonnull imgPath) {
        MIReviewImageViewController *imageVC = [[MIReviewImageViewController alloc] init];
        imageVC.imgPath = imgPath;
        [weakSelf.navigationController pushViewController:imageVC animated:YES];
    };
    
    return cell;
}

#pragma mark - Datasource & Delegate
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return self.titleCategories.count;
}

- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    
    WSWeak(weakSelf)
    switch (index) {
        case 0:
        {
            //评论
            _commentVC = [[MICommentVC alloc] init];
            _commentVC.contentId = _tweetId;
            _commentVC.commentType = MICommentTypeTweet;
            _commentVC.clickUserIcon = ^(NSInteger userId) {
                MIPersonalVC *vc = [[MIPersonalVC alloc] init];
                vc.userId = userId;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            };
            
            _commentVC.clickShowAllChildComment = ^(MICommentModel * _Nonnull model) {
                MICommentDetailVC *vc = [[MICommentDetailVC alloc] init];
                vc.commentModel = model;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            };
            
            //点击评论
            _commentVC.clickParentComment = ^(MICommentModel * _Nonnull model) {
                [weakSelf.textView becomeFirstResponder];
                weakSelf.currentModel = model;
                weakSelf.currentCommentType = 1;
            };
            
            return _commentVC;
        }
            break;
        case 1:
        {
            //点赞
            _supportVC = [[MISupportVC alloc] init];
            _supportVC.praiseArray = self.praiseArray;
            _supportVC.clickUserIcon = ^(NSInteger userId) {
                MIPersonalVC *vc = [[MIPersonalVC alloc] init];
                vc.userId = userId;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            };
            
            return _supportVC;
        }
            break;
        default:
        {
            return nil;
        }
            break;
    }
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    return self.titleCategories[index];
}

@end
