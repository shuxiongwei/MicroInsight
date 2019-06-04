//
//  MIUploadViewController.m
//  MicroInsight
//
//  Created by Jonphy on 2018/11/20.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "MIUploadViewController.h"
#import "MIThemeCell.h"
#import "UICollectionViewLeftAlignedLayout.h"
#import "NSString+MITextSize.h"
#import "MIAlbumRequest.h"
#import "MITheme.h"
#import "MIAlbumRequest.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <VODUpload/VODUploadClient.h>
#import <VODUpload/VODUploadModel.h>
#import <AVFoundation/AVFoundation.h>
#import "MIPlayerViewController.h"
#import "MicroInsight-Swift.h"

@interface MIUploadViewController ()<UICollectionViewDelegate, UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UIView *playBgView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UICollectionView *themCollection;
@property (weak, nonatomic) IBOutlet UIButton *uploadBtn;
@property (weak, nonatomic) IBOutlet MIPlaceholderTextView *textView;
@property (copy, nonatomic) NSArray *themes;
@property (nonatomic, strong) MITheme *curTheme;

@end

@implementation MIUploadViewController

static NSString *const CellId = @"MIThemeCell";

#pragma mark - view life
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [super configLeftBarButtonItem:nil];
    self.title = @"上传作品";
    
    [self requestThemeData];
    [self configTopUIWithAsset:_assetUrl];
    
    UICollectionViewLeftAlignedLayout *flow = [[UICollectionViewLeftAlignedLayout alloc]init];
    flow.minimumInteritemSpacing = 10;
    flow.minimumLineSpacing = 10;
    flow.sectionInset = UIEdgeInsetsMake(15, 10, 15, 10);
    self.themCollection.collectionViewLayout = flow;
    self.themes = [NSArray array];
    
    _textView.placeholder = @"请描述你的作品信息......";
    [_textView rounded:1 width:1 color:UIColorFromRGBWithAlpha(0xDDDDDD, 1)];
    [_uploadBtn setButtonCustomBackgroudImageWithBtn:_uploadBtn fromColor:UIColorFromRGBWithAlpha(0x72B3E2, 1) toColor:UIColorFromRGBWithAlpha(0x6DD1CC, 1)];
}

- (void)requestThemeData {
    
    __weak typeof(self)weakSelf = self;
    MIAlbumRequest *rq = [[MIAlbumRequest alloc] init];
    [rq themeListWithSuccessResponse:^(NSArray *modelList, NSString *message) {
        
        weakSelf.themes = modelList;
        [weakSelf.themCollection reloadData];
        
    } failureResponse:^(NSError *error) {
        
    }];
}

- (void)configTopUIWithAsset:(NSString *)url {
    
    UIImage *img;
    if ([url.pathExtension isEqualToString:@"png"]) {
        _playBtn.hidden = YES;
        img =  [UIImage imageWithContentsOfFile:url];
    }
    
    if ([url.pathExtension isEqualToString:@"mov"]) {
        _playBtn.hidden = NO;
        AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:url]];
        img = [MIHelpTool fetchThumbnailWithAVAsset:asset curTime:0];
    }
    
    _imageView.image = img;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MITheme *t = _themes[indexPath.item];
    NSString *text = t.title;
    CGFloat itemW = [text sizeWithFont:[UIFont systemFontOfSize:15]].width + 24;
    return CGSizeMake(itemW, 30);
}

#pragma mark - UICollectionDelegate,UICollectionDatasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _themes.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MITheme *t = _themes[indexPath.item];
    MIThemeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellId forIndexPath:indexPath];
    [cell rounded:10 width:2 color:UIColorFromRGBWithAlpha(0x666666, 1)];
    cell.themLb.text = t.title;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MIThemeCell *cell = (MIThemeCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.selected = !cell.selected;
    _curTheme = _themes[indexPath.item];
}

#pragma mark - IBAction
- (IBAction)playerBtnClick:(UIButton *)sender {
    MIPlayerViewController *vc = [[MIPlayerViewController alloc] init];
    vc.videoURL = _assetUrl;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)uploadBtnClick:(UIButton *)sender {
    
    if ([MIHelpTool isBlankString:_textView.text]) {
        [MIToastAlertView showAlertViewWithMessage:@"请输入标题"];
        return;
    }
    
    WSWeak(weakSelf);
    [MIRequestManager checkSensitiveWord:_textView.text completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
        
        NSInteger code = [jsonData[@"code"] integerValue];
        if (code == 0) {
            if (!weakSelf.curTheme) {
                [MIToastAlertView showAlertViewWithMessage:@"请选择主题"];
                return;
            }
            
            if ([weakSelf.assetUrl.pathExtension isEqualToString:@"png"]) {
                [MBProgressHUD showStatus:@"图片上传中，请稍后"];
                
                NSString *fileName = [[MIHelpTool timeStampSecond] stringByAppendingString:@".jpg"];
                NSMutableArray *tags = [NSMutableArray arrayWithObject:@([weakSelf.curTheme.themeId integerValue])];
                
                [MIRequestManager uploadImageWithFile:@"file" fileName:fileName filePath:weakSelf.assetUrl title:weakSelf.textView.text tags:tags requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUD];
                    });
                    
                    NSInteger code = [jsonData[@"code"] integerValue];
                    if (code == 0) {
                        [MIToastAlertView showAlertViewWithMessage:@"上传成功"];
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    } else {
                        [MIToastAlertView showAlertViewWithMessage:@"上传失败"];
                    }
                }];
            } else {
                NSString *text = weakSelf.textView.text;
                WSWeak(weakSelf);
                MIAlbumRequest *rq = [[MIAlbumRequest alloc] init];
                [rq videoInfoWithTitle:weakSelf.assetUrl.lastPathComponent SuccessResponse:^(MIUploadVidoInfo * _Nonnull info) {
                    
                    VODUploadListener *listener = [[VODUploadListener alloc] init];
                    listener.retry = ^{
                        
                        NSLog(@"%s", __PRETTY_FUNCTION__);
                    };
                    listener.retryResume = ^{
                        NSLog(@"%s", __PRETTY_FUNCTION__);
                    };
                    listener.finish = ^(UploadFileInfo *fileInfo, VodUploadResult *result) {
                        
                        NSMutableArray *tags = [NSMutableArray arrayWithObject:@([weakSelf.curTheme.themeId integerValue])];
                        [MIRequestManager uploadVideoWithTitle:text videoId:result.videoId tags:tags requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
                            
                            NSInteger code = [jsonData[@"code"] integerValue];
                            if (code == 0) {
                                [MIToastAlertView showAlertViewWithMessage:@"视频上传成功"];
                                [weakSelf.navigationController popViewControllerAnimated:YES];
                            }
                        }];
                        
                        NSLog(@"%s", __PRETTY_FUNCTION__);
                    };
                    listener.failure = ^(UploadFileInfo *fileInfo, NSString *code, NSString *message) {
                        [SVProgressHUD showErrorWithStatus:@"上传失败"];
                        NSLog(@"%s", __PRETTY_FUNCTION__);
                    };
                    listener.started = ^(UploadFileInfo *fileInfo) {
                        NSLog(@"%s", __PRETTY_FUNCTION__);
                    };
                    listener.progress = ^(UploadFileInfo *fileInfo, long uploadedSize, long totalSize) {
                        CGFloat uploadedS = uploadedSize;
                        [SVProgressHUD showProgress:uploadedS / totalSize status:@"视频上传中..."];
                        if (uploadedSize >= totalSize) {
                            [SVProgressHUD dismiss];
                        }
                        NSLog(@"%s", __PRETTY_FUNCTION__);
                    };
                    
                    listener.expire = ^{
                        [SVProgressHUD showErrorWithStatus:@"上传失败"];
                        NSLog(@"%s", __PRETTY_FUNCTION__);
                    };
                    
                    VodInfo *uploadVodInfo = [[VodInfo alloc] init];
                    uploadVodInfo.title = weakSelf.textView.text;
                    uploadVodInfo.templateGroupId = info.TemplateGroupId;
                    uploadVodInfo.cateId = @(0);
                    
                    VODUploadClient *uploadClient = [[VODUploadClient alloc] init];
                    [uploadClient init:info.AccessKeyId accessKeySecret:info.AccessKeySecret secretToken:info.SecurityToken expireTime:info.Expiration listener:listener];
                    [uploadClient addFile:weakSelf.assetUrl vodInfo:uploadVodInfo];
                    [uploadClient start];
                    [SVProgressHUD showProgress:0 status:@"视频上传中..."];
                    
                } failureResponse:^(NSError *error) {
                    
                }];
            }
        } else if (code == -1) {
            [MIHudView showMsg:@"标题不能含有敏感词"];
        }
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_textView resignFirstResponder];
}

@end
