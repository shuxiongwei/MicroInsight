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


@interface MICommunityDetailVC () <UIScrollViewDelegate, WMPageControllerDelegate, WMPageControllerDataSource>

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

@end

@implementation MICommunityDetailVC

#pragma mark - 懒加载
- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, MIScreenHeight - kBottomViewH, MIScreenWidth, kBottomViewH)];
        _bottomView.backgroundColor = UIColorFromRGBWithAlpha(0xF2F3F5, 1);
        [self.view addSubview:_bottomView];
        
        _commentBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(0, 0, _bottomView.width / 2.0, _bottomView.height) normalTitle:[NSString stringWithFormat:@"%ld", _communityModel.comments] normalTitleColor:[UIColor blackColor] highlightedTitleColor:nil selectedColor:nil titleFont:10 normalImage:[UIImage imageNamed:@"icon_community_comment_nor"] highlightedImage:nil selectedImage:[UIImage imageNamed:@"icon_community_comment_sel"] touchUpInSideTarget:self action:@selector(clickBottomCommentBtn:)];
        [_commentBtn layoutButtonWithEdgeInsetsStyle:MIButtonEdgeInsetsStyleTop imageTitleSpace:2];
        [_bottomView addSubview:_commentBtn];
        
        _praiseBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(_bottomView.width / 2.0, 0, _bottomView.width / 2.0, _bottomView.height) normalTitle:[NSString stringWithFormat:@"%ld", _communityModel.likes] normalTitleColor:[UIColor blackColor] highlightedTitleColor:nil selectedColor:nil titleFont:10 normalImage:[UIImage imageNamed:@"icon_community_praise_nor"] highlightedImage:nil selectedImage:[UIImage imageNamed:@"icon_community_praise_sel"] touchUpInSideTarget:self action:@selector(clickBottomPraiseBtn:)];
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
        if (_communityModel.contentType == 0) {
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
    }
    return _topView;
}

#pragma mark - 生命周期
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
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
}

#pragma mark - 配置UI
- (void)configDetailUI {
    self.title = @"正文详情";
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(backAction) image:[UIImage imageNamed:@"icon_login_back_nor"]];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(clickExtendBtn) image:[UIImage imageNamed:@"icon_community_more_nor"]];
    
    //因第三方self.view=scrollView，被迫将bottomView加在self.navigationController.view上了
    [self.navigationController.view addSubview:self.bottomView];
    
    [self updateCommentsTitle:_communityModel.comments];
    [self updateLikesTitle:_communityModel.likes];
    [self requestDetailData:YES];
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

- (void)requestDetailData:(BOOL)needRefresh {
    WSWeak(weakSelf);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [MIRequestManager getCommunityDetailDataWithContentId:_communityModel.contentId contentType:_communityModel.contentType requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSInteger code = [jsonData[@"code"] integerValue];
                if (code == 0) {
                    NSDictionary *dic = jsonData[@"data"];
                    
                    if (needRefresh) {
                        NSDictionary *contentDic = dic[@"content"];
                        if (weakSelf.communityModel.contentType == 0) {
                            weakSelf.detailModel = [MICommunityDetailModel yy_modelWithDictionary:contentDic];
                            YYTextLayout *layout = [weakSelf.detailModel getContentHeightWithStr:weakSelf.detailModel.title width:MIScreenWidth - 30 font:14 lineSpace:5 maxRow:0];
                            weakSelf.detailModel.viewHeight = layout.textBoundingSize.height + 67 + 30 + (MIScreenWidth - 30) * 190.0 / 345.0 + 35;
                            weakSelf.kHeadViewH = weakSelf.detailModel.viewHeight;
                        } else {
                            weakSelf.videoInfo = [MICommunityVideoInfo yy_modelWithDictionary:contentDic];
                            YYTextLayout *layout = [weakSelf.videoInfo getContentHeightWithStr:weakSelf.videoInfo.title width:MIScreenWidth - 30 font:14 lineSpace:5 maxRow:0];
                            weakSelf.videoInfo.viewHeight = layout.textBoundingSize.height + 67 + 30 + (MIScreenWidth - 30) * 190.0 / 345.0 + 35;
                            weakSelf.kHeadViewH = weakSelf.videoInfo.viewHeight;
                        }
                        
                        [weakSelf.view addSubview:weakSelf.topView];
                        [weakSelf refreshHeaderFrame];
                    }
                    
                    NSArray *likeList = dic[@"like"];
                    [weakSelf.praiseArray removeAllObjects];
                    for (NSDictionary *likeDic in likeList) {
                        MIPraiseModel *praiseM = [MIPraiseModel yy_modelWithDictionary:likeDic];
                        [weakSelf.praiseArray addObject:praiseM];
                    }
                    
                    [weakSelf.praiseBtn setTitle:[NSString stringWithFormat:@"%ld", weakSelf.praiseArray.count] forState:UIControlStateNormal];
                    weakSelf.supportVC.praiseArray = weakSelf.praiseArray;
                    weakSelf.communityModel.likes = weakSelf.praiseArray.count;
                }
            });
        }];
    });
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

#pragma mark - 事件响应
- (void)backAction {
    if (self.praiseBlock) {
        self.praiseBlock(_communityModel);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickExtendBtn {
    [[QZShareMgr shareManager] showShareType:QZShareTypeNormal inVC:nil];
    [QZShareMgr shareManager].shareWebUrl = [NSString stringWithFormat:@"http://www.tipscope.com/node.html?token=v_arO1gCPMXRNvog1rcUAnCeY1JAEkxc&contentId=%ld&contentType=%ld", _communityModel.contentId, _communityModel.contentType];
    [QZShareMgr shareManager].shareImg = [UIImage imageNamed:@"AppIcon"];
    [QZShareMgr shareManager].title = _communityModel.title;
}

- (void)clickBottomCommentBtn:(UIButton *)sender {
    
}

- (void)clickBottomPraiseBtn:(UIButton *)sender {
    if (sender.selected) {
        [MIHudView showMsg:@"您已经点过赞该作品"];
    } else {
        WSWeak(weakSelf)
        [MIRequestManager praiseWithContentId:_communityModel.contentId contentType:_communityModel.contentType requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
            
            NSInteger code = [jsonData[@"code"] integerValue];
            if (code == 0) {
                weakSelf.praiseBtn.selected = YES;
                weakSelf.communityModel.isLike = YES;
                [weakSelf requestDetailData:NO];
            } else {
                [MIHudView showMsg:@"点赞失败"];
            }
        }];
    }
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
            _commentVC.communityModel = _communityModel;
            _commentVC.clickUserIcon = ^(NSInteger userId) {
                MIPersonalVC *vc = [[MIPersonalVC alloc] init];
                vc.userId = userId;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            };
            
            _commentVC.clickCommentReplay = ^(MICommentModel * _Nonnull model) {
                
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
