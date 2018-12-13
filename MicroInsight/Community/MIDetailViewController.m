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
#import "MIReviewImageViewController.h"
#import "UIButton+Extension.h"
#import "MICommunityRequest.h"
#import "MIPlayerViewController.h"


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

@property (nonatomic, strong) MICommunityDetailModel *detailModel;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, assign) NSInteger pageCount;
@property (nonatomic, strong) NSMutableArray *commentList;

@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (copy, nonatomic) NSString *VideoURLString;
@property (weak, nonatomic) IBOutlet UIView *playerBackView;
@property (nonatomic, strong) MICommunityVideoInfo *videoInfo;

@end

@implementation MIDetailViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [super configLeftBarButtonItem:@"社区"];
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

    [_praiseBtn layoutButtonWithEdgeInsetsStyle:MIButtonEdgeInsetsStyleLeft imageTitleSpace:5];
    [_commentBtn layoutButtonWithEdgeInsetsStyle:MIButtonEdgeInsetsStyleLeft imageTitleSpace:5];
    _topImgView.contentMode = UIViewContentModeScaleAspectFit;
    
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
        [weakSelf.commentBtn setTitle:info.commentNum forState:UIControlStateNormal];
        [weakSelf.praiseBtn setTitle:info.goodNum forState:UIControlStateNormal];
        weakSelf.praiseBtn.selected = info.isLike;
        
        if (!isComment) {
            weakSelf.title = info.title;
            weakSelf.titleLab.text = info.username;
            [weakSelf refreshTopAndBottomImageView:info.coverUrl];
            
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
    [_commentBtn setTitle:_detailModel.commentNum forState:UIControlStateNormal];
    [_praiseBtn setTitle:_detailModel.goodNum forState:UIControlStateNormal];
    _praiseBtn.selected = _detailModel.isLike;
    
    if (!isComment) {
        self.title = _detailModel.title;
        _titleLab.text = _detailModel.username;
        [self refreshTopAndBottomImageView:_detailModel.url];
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
    WSWeak(weakSelf);
    [_topImgView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil options:SDWebImageLowPriority completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
        weakSelf.backImgView.image = image;
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        effectView.frame = weakSelf.backImgView.bounds;
        effectView.alpha = 0.95;
        [weakSelf.backImgView addSubview:effectView];
    }];
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
    [MIRequestManager commentWithContentId:_contentId contentType:_contentType content:_commentTF.text requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        NSInteger code = [jsonData[@"code"] integerValue];
        if (code == 0) {
            if (weakSelf.contentType == 0) {
                [self requestImageData:YES];
            } else {
                [self requestVideoInfo:YES];
            }
            
            [self requestCommentData:YES];
        } else {
            [MIToastAlertView showAlertViewWithMessage:@"评论失败"];
        }
    }];
    
    _commentTF.text = nil;
    [_commentTF resignFirstResponder];
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
    cell.titleLab.text = model.username;
    cell.timeLab.text = model.createdAt;
    cell.commentLab.text = model.content;
    
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
