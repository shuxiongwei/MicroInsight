//
//  MICommunityDetailVC.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/5.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MICommunityDetailVC.h"
#import "MicroInsight-Swift.h"
#import "MICommunityDetailTopView.h"
#import "MICommentVC.h"
#import "MISupportVC.h"
#import "MICommunityListModel.h"
#import "MICommunityVideoInfo.h"
#import "YYText.h"
#import "MICommentDetailVC.h"
#import "MIReportView.h"
#import "MIReviewImageViewController.h"

@interface MICommunityDetailVC () <UIScrollViewDelegate, WMPageControllerDelegate, WMPageControllerDataSource, MIShareManagerDelete>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *commentBtn;
@property (nonatomic, strong) UIButton *praiseBtn;
@property (nonatomic, strong) MICommentVC *commentVC;
@property (nonatomic, strong) MISupportVC *supportVC;
@property (nonatomic, strong) NSArray *titleCategories;
@property (nonatomic, assign) CGFloat kHeadViewH;
@property (nonatomic, strong) MICommunityVideoInfo *videoInfo;
@property (nonatomic, strong) MICommunityDetailModel *detailModel;
@property (nonatomic, strong) MICommunityDetailTopView *topView;
@property (nonatomic, strong) NSMutableArray *praiseArray;
@property (nonatomic, strong) MIPlaceholderTextView *textView;
@property (nonatomic, strong) UIView *bgTextView;
@property (nonatomic, strong) UIButton *maskView;
/* 标识当前评论类型(0:评论当前作品，1:评论作品的评论) */
@property (nonatomic, assign) NSInteger currentCommentType;
/* 标识当前作品的评论 */
@property (nonatomic, strong) MICommentModel *currentModel;
@property (nonatomic, strong) MIReportView *reportView;

@property (nonatomic, strong) UIView *loadingView;

@end

@implementation MICommunityDetailVC

#pragma mark - 懒加载
- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, MIScreenHeight - kBottomViewH, MIScreenWidth, kBottomViewH)];
        _bottomView.backgroundColor = UIColorFromRGBWithAlpha(0xF2F3F5, 1);
        [self.view addSubview:_bottomView];
        
        _commentBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(0, 0, _bottomView.width / 2.0, _bottomView.height) normalTitle:nil normalTitleColor:[UIColor blackColor] highlightedTitleColor:nil selectedColor:nil titleFont:10 normalImage:[UIImage imageNamed:@"icon_community_comment_nor"] highlightedImage:nil selectedImage:[UIImage imageNamed:@"icon_community_comment_sel"] touchUpInSideTarget:self action:@selector(clickBottomCommentBtn:)];
        [_bottomView addSubview:_commentBtn];
        
        _praiseBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(_bottomView.width / 2.0, 0, _bottomView.width / 2.0, _bottomView.height) normalTitle:nil normalTitleColor:[UIColor blackColor] highlightedTitleColor:nil selectedColor:nil titleFont:10 normalImage:[UIImage imageNamed:@"icon_community_praise_nor"] highlightedImage:nil selectedImage:[UIImage imageNamed:@"icon_community_praise_sel"] touchUpInSideTarget:self action:@selector(clickBottomPraiseBtn:)];
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

- (NSMutableArray *)praiseArray {
    if (!_praiseArray) {
        _praiseArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _praiseArray;
}

- (MICommunityDetailTopView *)topView {
    if (!_topView) {
        id model;
        CGRect frame;
        if (_contentType == 0) {
            frame = CGRectMake(0, 0, MIScreenWidth, _detailModel.viewHeight);
            model = _detailModel;
        } else {
            frame = CGRectMake(0, 0, MIScreenWidth, _videoInfo.viewHeight);
            model = _videoInfo;
        }
        
        _topView = [[MICommunityDetailTopView alloc] initWithFrame:frame];
        _topView.model = model;
        
        WSWeak(weakSelf)
        _topView.clickUserIcon = ^(NSInteger userId) {
            MIPersonalVC *vc = [[MIPersonalVC alloc] init];
            vc.userId = userId;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        };
        
        _topView.clickPlayBtn = ^(NSString * _Nonnull videoUrl) {
            MIVideoUploadVC *vc = [[MIVideoUploadVC alloc] init];
            vc.networkVideoUrl = videoUrl;
            vc.notUpload = @"1";
            [weakSelf.navigationController pushViewController:vc animated:YES];
        };
        
        _topView.clickContentImageView = ^(NSString *imgPath) {
            MIReviewImageViewController *imageVC = [[MIReviewImageViewController alloc] init];
            imageVC.imgPath = imgPath;
            [weakSelf.navigationController pushViewController:imageVC animated:YES];
        };
    }
    return _topView;
}

- (UIView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, KNaviBarAllHeight, MIScreenWidth, MIScreenHeight - KNaviBarAllHeight)];
        _loadingView.backgroundColor = UIColorFromRGBWithAlpha(0xF2F3F5, 1);
    }
    return _loadingView;
}

#pragma mark - 生命周期
- (void)dealloc {
    [self setBottomView:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];

    self.bottomView.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_textView resignFirstResponder];
    self.bottomView.hidden = YES;
}

- (void)viewDidLoad {
    [self setUpUI];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //键盘监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self configDetailUI];
}

#pragma mark - 配置UI
- (void)configDetailUI {
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont boldSystemFontOfSize:17],
       NSForegroundColorAttributeName:UIColorFromRGBWithAlpha(333333, 1)}];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
    self.title = @"正文详情";
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(backAction) image:[UIImage imageNamed:@"icon_login_back_nor"]];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(clickExtendBtn) image:[UIImage imageNamed:@"icon_community_more_nor"]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //因第三方self.view=scrollView，被迫将bottomView加在self.navigationController.view上了
    [self.navigationController.view addSubview:self.bottomView];
    [self configBgTextView];
    [self requestDetailDataNeedRefreshTopView:YES needRefreshCommentView:YES needRefreshSupportView:YES];
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
    _maskView.frame = MIScreenBounds;
    _maskView.backgroundColor = UIColorFromRGBWithAlpha(0x333333, 0.6);
    _maskView.hidden = YES;
    [_maskView addTarget:self action:@selector(clickMaskView) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_maskView];
    [self.navigationController.view addSubview:_maskView];
    
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
}

/**
 请求社区作品的详情数据

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
    
    WSWeak(weakSelf);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [MIRequestManager getCommunityDetailDataWithContentId:self.contentId contentType:self.contentType requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
//                [MBProgressHUD hideHUDForView:weakSelf.loadingView];
//                [weakSelf.loadingView removeFromSuperview];
//                weakSelf.loadingView = nil;
                
                NSInteger code = [jsonData[@"code"] integerValue];
                if (code == 0) {
                    NSDictionary *dic = jsonData[@"data"];
                    NSDictionary *contentDic = dic[@"content"];
                    
                    if (needRefreshTopView) {
                        if (weakSelf.contentType == 0) {
                            weakSelf.detailModel = [MICommunityDetailModel yy_modelWithDictionary:contentDic];
                            YYTextLayout *layout = [weakSelf.detailModel getContentHeightWithStr:weakSelf.detailModel.title width:MIScreenWidth - 30 font:14 lineSpace:5 maxRow:0];
                            weakSelf.detailModel.viewHeight = layout.textBoundingSize.height + 67 + 30 + (MIScreenWidth - 30) * 190.0 / 345.0 + 35;
                            weakSelf.kHeadViewH = weakSelf.detailModel.viewHeight;
                            weakSelf.praiseBtn.selected = weakSelf.detailModel.isLike;
                        } else {
                            weakSelf.videoInfo = [MICommunityVideoInfo yy_modelWithDictionary:contentDic];
                            YYTextLayout *layout = [weakSelf.videoInfo getContentHeightWithStr:weakSelf.videoInfo.title width:MIScreenWidth - 30 font:14 lineSpace:5 maxRow:0];
                            weakSelf.videoInfo.viewHeight = layout.textBoundingSize.height + 67 + 30 + (MIScreenWidth - 30) * 190.0 / 345.0 + 35;
                            weakSelf.kHeadViewH = weakSelf.videoInfo.viewHeight;
                            weakSelf.praiseBtn.selected = weakSelf.videoInfo.isLike;
                        }
                        
                        [weakSelf.view addSubview:weakSelf.topView];
                        [weakSelf refreshHeaderFrame];
                        
                        if (weakSelf.needShowKeyboard) {
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [weakSelf.textView becomeFirstResponder];
                                weakSelf.currentCommentType = 0;
                            });
                        }
                    } else {
                        if (weakSelf.contentType == 0) {
                            weakSelf.detailModel.comments = contentDic[@"comments"];
                            weakSelf.detailModel.likes = contentDic[@"likes"];
                        } else {
                            weakSelf.videoInfo.comments = contentDic[@"comments"];
                            weakSelf.videoInfo.likes = contentDic[@"likes"];
                        }
                    }
                    
                    if (needRefreshCommentView) {
                        [weakSelf updateComments:[contentDic[@"comments"] integerValue]];
                        
                        //不是第一次请求数据
                        if (!needRefreshSupportView || !needRefreshTopView) {
                            [weakSelf.commentVC refreshView];
                        }
                    }
                    
                    if (needRefreshSupportView) {
                        NSArray *likeList = dic[@"like"];
                        [weakSelf.praiseArray removeAllObjects];
                        for (NSDictionary *likeDic in likeList) {
                            MIPraiseModel *praiseM = [MIPraiseModel yy_modelWithDictionary:likeDic];
                            [weakSelf.praiseArray addObject:praiseM];
                        }
                        
                        [weakSelf.praiseBtn setTitle:[NSString stringWithFormat:@"%ld", weakSelf.praiseArray.count] forState:UIControlStateNormal];
                        weakSelf.supportVC.praiseArray = weakSelf.praiseArray;
                        [weakSelf updateLiks:weakSelf.praiseArray.count];
                    }
                }
            });
        }];
    });
}

- (void)refreshHeaderFrame {
    self.maximumHeaderViewHeight = _kHeadViewH;
    [self forceLayoutSubviews];
}

- (void)updateComments:(NSInteger)comments {
    [self.menuView updateTitle:[NSString stringWithFormat:@"评论 %ld", comments] atIndex:0 andWidth:NO];
    [_commentBtn setTitle:[NSString stringWithFormat:@"%ld", comments] forState:UIControlStateNormal];
    [_commentBtn layoutButtonWithEdgeInsetsStyle:MIButtonEdgeInsetsStyleTop imageTitleSpace:5];
}

- (void)updateLiks:(NSInteger)likes {
    [self.menuView updateTitle:[NSString stringWithFormat:@"点赞 %ld", likes] atIndex:1 andWidth:NO];
    [_praiseBtn setTitle:[NSString stringWithFormat:@"%ld", likes] forState:UIControlStateNormal];
    [_praiseBtn layoutButtonWithEdgeInsetsStyle:MIButtonEdgeInsetsStyleTop imageTitleSpace:5];
}

#pragma mark - Notify
- (void)keyBoardWillShow:(NSNotification *) notification {
    _bgTextView.hidden = NO;
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
    NSInteger comments;
    NSInteger likes;
    BOOL isLike;
    if (_contentType == 0) {
        comments = [_detailModel.comments integerValue];
        likes = [_detailModel.likes integerValue];
        isLike = _detailModel.isLike;
    } else {
        comments = [_videoInfo.comments integerValue];
        likes = [_videoInfo.likes integerValue];
        isLike = _videoInfo.isLike;
    }
    
    if (self.praiseBlock) {
        self.praiseBlock(comments, likes, isLike);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickExtendBtn {
    [_textView resignFirstResponder];
    
    MIUserInfoModel *model = [MILocalData getCurrentLoginUserInfo];
    QZShareType type;
    if (_contentType == 0) {
        if (model.uid == _detailModel.userId) {
            type = QZShareTypeNormal;
        } else {
            type = QZShareTypeOther;
        }
    } else {
        if (model.uid == [_videoInfo.userId integerValue]) {
            type = QZShareTypeNormal;
        } else {
            type = QZShareTypeOther;
        }
    }
    
    [[QZShareMgr shareManager] showShareType:type inVC:nil];
    [QZShareMgr shareManager].delegate = self;
    [QZShareMgr shareManager].shareWebUrl = [NSString stringWithFormat:@"http://www.tipscope.com/node.html?token=%@&contentId=%ld&contentType=%ld", [MILocalData getCurrentRequestToken], _contentId, _contentType];
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
        [MIRequestManager praiseWithContentId:_contentId contentType:_contentType requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
            
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
                [MIRequestManager commentWithContentId:[NSString stringWithFormat:@"%ld", weakSelf.contentId] contentType:weakSelf.contentType content:weakSelf.textView.text requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
                    
                    NSInteger code = [jsonData[@"code"] integerValue];
                    if (code == 0) {
                        [weakSelf requestDetailDataNeedRefreshTopView:NO needRefreshCommentView:YES needRefreshSupportView:NO];
                    } else {
                        [MIHudView showMsg:@"评论失败"];
                    }
                }];
            } else {
                [MIRequestManager commentProductionCommentWithContentId:weakSelf.currentModel.content_id contentType:weakSelf.currentModel.content_type commentId:weakSelf.currentModel.modelId content:weakSelf.textView.text requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
                    
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
- (void)shareManagerReportAction {
    if (!_reportView) {
        _reportView = [[MIReportView alloc] initWithFrame:CGRectMake(0, MIScreenHeight, MIScreenWidth, MIScreenHeight)];
        [[UIApplication sharedApplication].keyWindow addSubview:_reportView];
        
        WSWeak(weakSelf)
        _reportView.selectReportContent = ^(NSString * _Nonnull content) {
            
            NSString *userId;
            if (weakSelf.contentType == 0) {
                userId = [NSString stringWithFormat:@"%ld", weakSelf.detailModel.userId];
            } else {
                userId = weakSelf.videoInfo.userId;
            }
            
            [MIRequestManager reportUseWithUserId:userId reportContent:content requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
                
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

- (void)shareManagerAddBlackListAction {
    NSString *userId;
    if (_contentType == 0) {
        userId = [NSString stringWithFormat:@"%ld", _detailModel.userId];
    } else {
        userId = _videoInfo.userId;
    }
    
    [MIRequestManager addBlackListWithUserId:userId requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        NSInteger code = [jsonData[@"code"] integerValue];
        if (code == 0) {
            [MIHudView showMsg:@"拉黑成功"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"blackListNotification" object:nil];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [MIHudView showMsg:@"拉黑失败"];
        }
    }];
}

#pragma mark - WMPageControllerDelegate & WMPageControllerDataSource
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
            _commentVC.contentId = _contentId;
            _commentVC.contentType = _contentType;
            _commentVC.commentType = MICommentTypeCommunity;
            WSWeak(weakSelf)
            _commentVC.clickUserIcon = ^(NSInteger userId) {
                MIPersonalVC *vc = [[MIPersonalVC alloc] init];
                vc.userId = userId;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            };
            
            //点击评论的显示所有子评论
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
