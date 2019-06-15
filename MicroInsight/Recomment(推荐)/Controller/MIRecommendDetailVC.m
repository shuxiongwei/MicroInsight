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

@interface MIRecommendDetailVC () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, WMPageControllerDelegate, WMPageControllerDataSource>

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
    [self requestDetailData:YES];
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

- (void)refreshSubViews {
    _titleLab.text = _tweetModel.title;
    NSArray *strs = [_tweetModel.created_at componentsSeparatedByString:@" "];
    _timeLab.text = strs.firstObject;
    [_readingBtn setTitle:[NSString stringWithFormat:@"%ld", _tweetModel.readings] forState:UIControlStateNormal];
    
    [self updateLikesTitle:_tweetModel.likes];
    [self updateCommentsTitle:_tweetModel.comments];
}

- (void)requestDetailData:(BOOL)needRefresh {
    WSWeak(weakSelf)
    [MIRequestManager getSingleTweetWithId:_tweetId requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        NSInteger code = [jsonData[@"code"] integerValue];
        if (code == 0) {
            NSDictionary *data = jsonData[@"data"];
            NSDictionary *tweetDic = data[@"tweet"];
            weakSelf.tweetModel = [MITweetModel yy_modelWithDictionary:tweetDic];
            [weakSelf refreshSubViews];
            
            weakSelf.kHeadViewH += 115;
            
            if (needRefresh) {
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
            }

            NSArray *likes = data[@"likes"];
            for (NSDictionary *likeDic in likes) {
                MIPraiseModel *model = [MIPraiseModel yy_modelWithDictionary:likeDic];
                [weakSelf.praiseArray addObject:model];
            }
            
            [weakSelf.praiseBtn setTitle:[NSString stringWithFormat:@"%ld", weakSelf.praiseArray.count] forState:UIControlStateNormal];
            weakSelf.supportVC.praiseArray = weakSelf.praiseArray;
        } else {
            
        }
    }];
}

#pragma mark - 事件响应
- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickExtendBtn {
//    [[QZShareMgr shareManager] showShareType:QZShareTypeNormal inVC:nil];
//    [QZShareMgr shareManager].shareWebUrl = [NSString stringWithFormat:@"http://www.tipscope.com/node.html?token=v_arO1gCPMXRNvog1rcUAnCeY1JAEkxc&contentId=%ld&contentType=%ld", _communityModel.contentId, _communityModel.contentType];
//    [QZShareMgr shareManager].shareImg = [UIImage imageNamed:@"AppIcon"];
//    [QZShareMgr shareManager].title = _communityModel.title;
}

- (void)clickBottomCommentBtn:(UIButton *)sender {
    
}

- (void)clickBottomPraiseBtn:(UIButton *)sender {
    if (sender.selected) {
        [MIHudView showMsg:@"您已经点过赞该作品"];
    } else {
        
    }
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
//            _commentVC.communityModel = _communityModel;
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
