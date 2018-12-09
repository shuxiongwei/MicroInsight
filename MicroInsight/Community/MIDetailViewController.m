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
    [self requestDetailData:NO];
    [self requestCommentData:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)configDetailUI {
    [_tableView registerNib:[UINib nibWithNibName:commentID bundle:nil] forCellReuseIdentifier:commentID];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [_praiseBtn layoutButtonWithEdgeInsetsStyle:MIButtonEdgeInsetsStyleLeft imageTitleSpace:5];
    [_commentBtn layoutButtonWithEdgeInsetsStyle:MIButtonEdgeInsetsStyleLeft imageTitleSpace:5];
    
    _topImgView.contentMode = UIViewContentModeScaleAspectFit;
    _topImgView.userInteractionEnabled = YES;
    _topImgView.hidden = YES;
    _backImgView.hidden = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTopImgView:)];
    [_topImgView addGestureRecognizer:tap];
}

/**
 请求数据

 @param isComment 是否是评论后的请求
 */
- (void)requestDetailData:(BOOL)isComment {
    WSWeak(weakSelf);
    [MIRequestManager getCommunityDetailDataWithContentId:_contentId requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        NSInteger code = [jsonData[@"code"] integerValue];
        if (code == 0) {
            NSDictionary *dic = jsonData[@"data"];
            NSDictionary *imageDic = dic[@"image"];
            weakSelf.detailModel = [MICommunityDetailModel yy_modelWithDictionary:imageDic];
            if ([weakSelf.detailModel.url.pathExtension isEqualToString:@"jpg"]) {
                [weakSelf refreshUI:YES isComment:isComment];
            } else {
                [weakSelf refreshUI:NO isComment:isComment];
            }
        }
    }];
}

/**
 刷新UI

 @param isImage YES：图片，NO：视频
 @param isComment 是否是评论后的刷新
 */
- (void)refreshUI:(BOOL)isImage isComment:(BOOL)isComment {
    [_commentBtn setTitle:_detailModel.commentNum forState:UIControlStateNormal];
    [_praiseBtn setTitle:_detailModel.goodNum forState:UIControlStateNormal];
    _praiseBtn.selected = _detailModel.isLike;
    
    if (!isComment) {
        self.title = _detailModel.title;
        _titleLab.text = _detailModel.username;
        
        if (isImage) {
            _topImgView.hidden = NO;
            _backImgView.hidden = NO;
            
            WSWeak(weakSelf);
            [_topImgView sd_setImageWithURL:[NSURL URLWithString:_detailModel.url] placeholderImage:nil options:SDWebImageLowPriority completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                

                weakSelf.backImgView.image = image;
                
                UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
                UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
                effectView.frame = weakSelf.backImgView.bounds;
                effectView.alpha = 0.95;
                [weakSelf.backImgView addSubview:effectView];
            }];
        } else {
            
        }
    }
}

- (void)requestCommentData:(BOOL)isComment {
    WSWeak(weakSelf);
    [MIRequestManager getCommunityCommentListWithContentId:_contentId requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
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

#pragma mark - 事件响应
- (IBAction)clickCommentBtn:(UIButton *)sender {
    [_commentTF becomeFirstResponder];
}

- (IBAction)clickPraiseBtn:(UIButton *)sender {
    if (!sender.selected) {
        [MIRequestManager praiseWithContentId:_detailModel.contentId requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
            
            NSInteger code = [jsonData[@"code"] integerValue];
            if (code == 0) {
//                [self requestDetailData:YES];
                NSDictionary *data = jsonData[@"data"];
                [_praiseBtn setTitle:[data[@"goodNum"] stringValue] forState:UIControlStateNormal];
                _praiseBtn.selected = YES;
                _detailModel.isLike = YES;
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
    
    [MIRequestManager commentWithContentId:_detailModel.contentId content:_commentTF.text requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        NSInteger code = [jsonData[@"code"] integerValue];
        if (code == 0) {
            [self requestDetailData:YES];
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
    // 键盘显示\隐藏完毕的frame
    CGRect frame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // 修改底部约束
    _bottomConstraint.constant = [UIScreen mainScreen].bounds.size.height - frame.origin.y; // 屏幕的高度 - 键盘的Y值

    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded]; // 自动布局的view改变约束后,需要强制布局
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

#pragma mar - touch
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

@end
