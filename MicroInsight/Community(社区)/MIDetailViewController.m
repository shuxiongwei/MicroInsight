//
//  MIDetailViewController.m
//  MicroInsight
//
//  Created by 舒雄威 on 2018/12/5.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "MIDetailViewController.h"
#import "MICommentCell.h"
#import "MICommunityListModel.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "MIReviewImageViewController.h"
#import "MICommunityRequest.h"
#import "MIPlayerViewController.h"
#import "MIThirdPartyLoginManager.h"
#import "MIReportView.h"

static NSString * const commentID = @"MICommentCell";

@interface MIDetailViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backImgView;
@property (weak, nonatomic) IBOutlet UIImageView *topImgView;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet UIButton *praiseBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UITextField *commentTF;
@property (weak, nonatomic) IBOutlet UIImageView *userIcon;

@property (nonatomic, strong) MICommunityDetailModel *detailModel;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, assign) NSInteger pageCount;
@property (nonatomic, strong) NSMutableArray *commentList;

@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (copy, nonatomic) NSString *VideoURLString;
@property (weak, nonatomic) IBOutlet UIView *playerBackView;
@property (nonatomic, strong) MICommunityVideoInfo *videoInfo;

@property (nonatomic, strong) MIReportView *reportView;

@end

@implementation MIDetailViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [super configLeftBarButtonItem:@"社区"];
    
    MIUserInfoModel *userInfo = [MILocalData getCurrentLoginUserInfo];
    if (userInfo.uid != _userId.integerValue) {
        [super configRightBarButtonItemWithType:UIButtonTypeCustom frame:CGRectMake(0, 0, 30, 30) normalTitle:nil normalTitleColor:nil highlightedTitleColor:nil selectedColor:nil titleFont:0 normalImage:[UIImage imageNamed:@"btn_more_p"] highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(showReportView)];
    }
    
    [self configDetailUI];
    
    if (_contentType == 0) {
        [self requestImageData:NO];
        _playBtn.hidden = YES;
    } else {
        [self requestVideoInfo:NO];
        _playBtn.hidden = NO;
    }

    [self requestCommentData:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)configDetailUI {
    [_tableView registerNib:[UINib nibWithNibName:commentID bundle:nil] forCellReuseIdentifier:commentID];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    _userIcon.layer.cornerRadius = 14;
    _userIcon.layer.masksToBounds = YES;
    [_praiseBtn layoutButtonWithEdgeInsetsStyle:MIButtonEdgeInsetsStyleLeft imageTitleSpace:5];
    [_commentBtn layoutButtonWithEdgeInsetsStyle:MIButtonEdgeInsetsStyleLeft imageTitleSpace:5];
    
    _commentTF.layer.cornerRadius = 20;
    _commentTF.layer.masksToBounds = YES;
    [_commentTF setValue:UIColorFromRGBWithAlpha(0x666666, 1) forKeyPath:@"_placeholderLabel.textColor"];
    
    if (_contentType == 0) {
        _playBtn.hidden = YES;
        _topImgView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTopImgView:)];
        [_topImgView addGestureRecognizer:tap];
    }
}

/**
 请求视频详情数据

 @param isComment 是否评论后的请求
 */
- (void)requestVideoInfo:(BOOL)isComment {
    
    WSWeak(weakSelf);
    MICommunityRequest *rq = [[MICommunityRequest alloc] init];
    [rq videoInfoWithVideoId:_contentId SuccessResponse:^(MICommunityVideoInfo * _Nonnull info) {
        
        weakSelf.videoInfo = info;
        [weakSelf.commentBtn setTitle:info.comments forState:UIControlStateNormal];
        [weakSelf.praiseBtn setTitle:info.likes forState:UIControlStateNormal];
        weakSelf.praiseBtn.selected = info.isLike;
        
        if (!isComment) {
            weakSelf.title = info.title;
            weakSelf.titleLab.text = info.nickname;
            [weakSelf refreshTopAndBottomImageView:info.coverUrl];
            [weakSelf setUserIconImage:info.avatar];
            
            MIPlayerInfo *pInfo = info.playUrlList.firstObject;
            weakSelf.VideoURLString = pInfo.playUrl;
        }
    } failureResponse:^(NSError *error) {
        
    }];
}

/**
 请求图片详情数据

 @param isComment 是否是评论后的请求
 */
- (void)requestImageData:(BOOL)isComment {
    WSWeak(weakSelf);
    [MIRequestManager getCommunityDetailDataWithContentId:_contentId requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        NSInteger code = [jsonData[@"code"] integerValue];
        if (code == 0) {
            NSDictionary *dic = jsonData[@"data"];
            NSDictionary *imageDic = dic[@"image"];
            weakSelf.detailModel = [MICommunityDetailModel yy_modelWithDictionary:imageDic];
            [weakSelf refreshUI:isComment];
        }
    }];
}

/**
 刷新UI

 @param isComment 是否是评论后的刷新
 */
- (void)refreshUI:(BOOL)isComment {
    [_commentBtn setTitle:_detailModel.comments forState:UIControlStateNormal];
    [_praiseBtn setTitle:_detailModel.likes forState:UIControlStateNormal];
    _praiseBtn.selected = _detailModel.isLike;
    
    if (!isComment) {
        self.title = _detailModel.title;
        _titleLab.text = _detailModel.nickname;
        [self refreshTopAndBottomImageView:_detailModel.url];
        [self setUserIconImage:_detailModel.avatar];
    }
}

- (void)requestCommentData:(BOOL)isComment {
    WSWeak(weakSelf);
    [MIRequestManager getCommunityCommentListWithContentId:_contentId contentType:_contentType requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        NSInteger code = [jsonData[@"code"] integerValue];
        if (code == 0) {
            if (isComment) {
                [weakSelf.commentList removeAllObjects];
            }
            
            NSDictionary *dic = jsonData[@"data"];
            NSArray *list = dic[@"list"];
            for (NSDictionary *commentDic in list) {
                MICommunityCommentModel *model = [MICommunityCommentModel yy_modelWithDictionary:commentDic];
                [weakSelf.commentList addObject:model];
            }
            
            [weakSelf.tableView reloadData];
        }
    }];
}

- (void)refreshTopAndBottomImageView:(NSString *)url {

    //等比缩放，限定在矩形框外
    NSString *imgUrl = [NSString stringWithFormat:@"%@?x-oss-process=image/resize,m_fill,h_%ld,w_%ld", url, (NSInteger)_topImgView.size.width / 1, (NSInteger)_topImgView.size.width / 1];
    
    WSWeak(weakSelf);
    [_topImgView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:nil options:SDWebImageRetryFailed completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
        weakSelf.backImgView.image = [MIUIFactory coreBlurImage:image];
    }];
}

- (void)setUserIconImage:(NSString *)url {
    //等比缩放，限定在矩形框外
    NSString *imgUrl = [NSString stringWithFormat:@"%@?x-oss-process=image/resize,m_fill,h_%ld,w_%ld", url, (NSInteger)_userIcon.size.width / 1, (NSInteger)_userIcon.size.width / 1];
    [_userIcon sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"account"] options:SDWebImageRetryFailed];
}

#pragma mark - IBAction
- (IBAction)playBtnClick:(UIButton *)sender {

    if (_VideoURLString.length > 0) {
        MIPlayerViewController *vc = [[MIPlayerViewController alloc] init];
        vc.videoURL = _VideoURLString;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)clickCommentBtn:(UIButton *)sender {
    [_commentTF becomeFirstResponder];
}

- (IBAction)clickPraiseBtn:(UIButton *)sender {
    if (!sender.selected) {
        WSWeak(weakSelf);
        [MIRequestManager praiseWithContentId:_contentId contentType:_contentType requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
            
            NSInteger code = [jsonData[@"code"] integerValue];
            if (code == 0) {
                NSDictionary *data = jsonData[@"data"];
                [weakSelf.praiseBtn setTitle:[data[@"goodNum"] stringValue] forState:UIControlStateNormal];
                weakSelf.praiseBtn.selected = YES;
                weakSelf.detailModel.isLike = YES;
            } else {
                [MIToastAlertView showAlertViewWithMessage:@"点赞失败"];
            }
        }];
    } else {
        [MIToastAlertView showAlertViewWithMessage:@"已点赞过该作品"];
    }
}

- (IBAction)clickSendBtn:(UIButton *)sender {
    if ([MIHelpTool isBlankString:_commentTF.text]) {
        [MIToastAlertView showAlertViewWithMessage:@"请输入评论内容"];
        return;
    }
    
    WSWeak(weakSelf);
    [MIRequestManager checkSensitiveWord:_commentTF.text completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        NSInteger code = [jsonData[@"code"] integerValue];
        if (code == 0) {
            [MIRequestManager commentWithContentId:weakSelf.contentId contentType:weakSelf.contentType content:weakSelf.commentTF.text requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
                
                NSInteger code = [jsonData[@"code"] integerValue];
                if (code == 0) {
                    if (weakSelf.contentType == 0) {
                        [weakSelf requestImageData:YES];
                    } else {
                        [weakSelf requestVideoInfo:YES];
                    }
                    
                    [weakSelf requestCommentData:YES];
                } else {
                    [MIToastAlertView showAlertViewWithMessage:@"评论失败"];
                }
            }];
        } else if (code == -1) {
            [MIToastAlertView showAlertViewWithMessage:@"评论不能含有敏感词"];
        }
        
        weakSelf.commentTF.text = nil;
        [weakSelf.commentTF resignFirstResponder];
    }];
}

- (IBAction)clickShareBtn:(UIButton *)sender {
    
    NSString *title = @"";
    NSString *description = @"";
    if (_contentType == 0) {
        title = _detailModel.title;
        description = @"图片";
    } else {
        title = _videoInfo.title;
        description = @"视频";
    }
    
    [[MIThirdPartyLoginManager shareManager] shareByWXWithTitle:title description:description imageUrl:_detailModel.url videoUrl:_videoInfo.playUrlList.firstObject.playUrl isVideo:_contentType];
}

#pragma mark - 手势
- (void)clickTopImgView:(UITapGestureRecognizer *)rec {
    MIReviewImageViewController *imageVC = [[MIReviewImageViewController alloc] init];
    imageVC.imgPath = _detailModel.url;
    [self.navigationController pushViewController:imageVC animated:YES];
}

#pragma mark - 通知
- (void)keyboardWillChangeFrame:(NSNotification *)note {
    // 键盘显示/隐藏完毕的frame
    CGRect frame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // 修改底部约束(屏幕的高度 - 键盘的Y值)
    _bottomConstraint.constant = [UIScreen mainScreen].bounds.size.height - frame.origin.y;

    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        // 自动布局的view改变约束后,需要强制布局
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - 举报相关
- (void)showReportView {
    WSWeak(weakSelf);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle: UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *reportAction = [UIAlertAction actionWithTitle:@"举报" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (!weakSelf.reportView) {
            weakSelf.reportView = [[MIReportView alloc] initWithFrame:CGRectMake(0, weakSelf.view.bounds.size.height, weakSelf.view.bounds.size.width, weakSelf.view.bounds.size.height)];
            [weakSelf.view addSubview:weakSelf.reportView];
            
            weakSelf.reportView.selectReportContent = ^(NSString * _Nonnull content) {
                
                NSString *userId;
                if (weakSelf.contentType == 0) {
                    userId = [NSString stringWithFormat:@"%ld", weakSelf.detailModel.userId];
                } else {
                    userId = weakSelf.videoInfo.userId;
                }
                
                [MIRequestManager reportUseWithUserId:userId reportContent:content requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
                    
                    NSInteger code = [jsonData[@"code"] integerValue];
                    if (code == 0) {
                        [MIToastAlertView showAlertViewWithMessage:@"举报成功"];
                    }
                }];
            };
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.reportView.frame = CGRectMake(0, 0, weakSelf.view.bounds.size.width, weakSelf.view.bounds.size.height);
        }];
    }];
    
    UIAlertAction *blackAction = [UIAlertAction actionWithTitle:@"拉黑" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *userId;
        if (weakSelf.contentType == 0) {
            userId = [NSString stringWithFormat:@"%ld", weakSelf.detailModel.userId];
        } else {
            userId = weakSelf.videoInfo.userId;
        }
        
        [MIRequestManager addBlackListWithUserId:userId requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
            
            NSInteger code = [jsonData[@"code"] integerValue];
            if (code == 0) {
                [MIToastAlertView showAlertViewWithMessage:@"拉黑成功"];
                [[NSNotificationCenter defaultCenter] postNotificationName:blackListNotification object:nil];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:reportAction];
    [alertController addAction:blackAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.commentList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MICommentCell *cell = [tableView dequeueReusableCellWithIdentifier:commentID forIndexPath:indexPath];
    MICommunityCommentModel *model = self.commentList[indexPath.row];
    cell.titleLab.text = model.nickname;
    cell.timeLab.text = model.createdAt;
    cell.commentLab.text = model.content;
    
    //等比缩放，限定在矩形框外
    NSString *imgUrl = [NSString stringWithFormat:@"%@?x-oss-process=image/resize,m_fill,h_%ld,w_%ld", model.avatar, (NSInteger)cell.userBtn.size.width / 1, (NSInteger)cell.userBtn.size.width / 1];
    [cell.userBtn sd_setImageWithURL:[NSURL URLWithString:imgUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"account"] options:SDWebImageRetryFailed];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MICommunityCommentModel *model = self.commentList[indexPath.row];
    CGFloat width = MIScreenWidth - 70;
    CGFloat contentH = [MIHelpTool measureMutilineStringHeightWithString:model.content font:[UIFont systemFontOfSize:13] width:width];

    return contentH + 73;
}

#pragma mark - 懒加载
- (NSMutableArray *)commentList {
    if (!_commentList) {
        _commentList = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _commentList;
}

#pragma mark - touch
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

@end
