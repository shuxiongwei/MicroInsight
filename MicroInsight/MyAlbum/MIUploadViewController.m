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
#import <VODUpload/VODUploadSVideoClient.h>
#import <AVFoundation/AVFoundation.h>


@interface MIUploadViewController ()<UICollectionViewDelegate, UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout, VODUploadSVideoClientDelegate>

@property (weak, nonatomic) IBOutlet UIView *playBgView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UICollectionView *themCollection;
@property (weak, nonatomic) IBOutlet UIButton *uploadBtn;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) AVPlayerItem *curItem;
@property (copy, nonatomic) NSArray *themes;

@end

@implementation MIUploadViewController

static NSString *const CellId = @"MIThemeCell";

#pragma mark - view life

- (void)dealloc{
    
    [_player pause];
    _player = nil;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self requestThemeData];
    
    [self configTopUIWithAsset:_assetUrl];
    
    UICollectionViewLeftAlignedLayout *flow = [[UICollectionViewLeftAlignedLayout alloc]init];
    flow.minimumInteritemSpacing = 10;
    flow.minimumLineSpacing = 10;
    flow.sectionInset = UIEdgeInsetsMake(15, 10, 15, 10);
    self.themCollection.collectionViewLayout = flow;
    self.themes = [NSArray array];
    // Do any additional setup after loading the view.
}

- (void)requestThemeData{
    
    __weak typeof(self)weakSelf = self;
    MIAlbumRequest *rq = [[MIAlbumRequest alloc] init];
    [rq themeListWithSuccessResponse:^(NSArray *modelList, NSString *message) {
        
        weakSelf.themes = modelList;
        [weakSelf.themCollection reloadData];
        
    } failureResponse:^(NSError *error) {
        
    }];
    
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    _playerLayer.frame = self.playBgView.bounds;
}


- (void)configTopUIWithAsset:(NSString *)url{
    
    if ([url.pathExtension isEqualToString:@"png"]) {
        _imageView.hidden = NO;
        _playBtn.hidden = YES;
        UIImage *img =  [UIImage imageWithContentsOfFile:url];
        _imageView.image = img;
    }
    
    if ([url.pathExtension isEqualToString:@"mov"]) {
        
        _imageView.hidden = YES;
        _playBtn.hidden = NO;
        
        
        self.curItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:url]];
        self.player = [AVPlayer playerWithPlayerItem:_curItem];;
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        [self.playBgView.layer addSublayer:_playerLayer];
        [_playBgView bringSubviewToFront:_playBtn];
    }
}

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
    cell.themLb.text = t.title;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MIThemeCell *cell = (MIThemeCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.selected = !cell.selected;
}

#pragma mark - IBAction

- (IBAction)playerBtnClick:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    if (sender.selected) {
        [_player play];
    }else{
        [_player pause];
    }
}

- (IBAction)backBtnClick:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancelBtnClick:(UIButton *)sender {
    
}

- (IBAction)didEndOnExit:(UITextField *)sender {
    
    [sender resignFirstResponder];
}

- (IBAction)uploadBtnClick:(UIButton *)sender {
    
    
    if ([_assetUrl.pathExtension isEqualToString:@"png"]) {
        NSString *fileName = [[MIHelpTool timeStampSecond] stringByAppendingString:@".jpg"];
        NSMutableArray *tags = [NSMutableArray arrayWithCapacity:_themes.count];
        for (MITheme *theme in _themes) {
            [tags addObject:@([theme.themeId integerValue])];
        }
        [MIRequestManager uploadImageWithFile:@"file" fileName:fileName filePath:_assetUrl title:_nameTF.text tags:tags requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
            
        }];
    }else{
        
        MIAlbumRequest *rq = [[MIAlbumRequest alloc] init];
        [rq videoInfoWithTitle:_assetUrl.lastPathComponent SuccessResponse:^(MIUploadVidoInfo * _Nonnull info) {
            
            VODUploadSVideoClient *client = [[VODUploadSVideoClient alloc] init];
            client.delegate = self;
            client.transcode = YES;
            NSString *imgPath = [self->_assetUrl stringByReplacingOccurrencesOfString:@".mov" withString:@".png"];
            NSFileManager *fm = [NSFileManager defaultManager];
            if (![fm fileExistsAtPath:imgPath]) {
                AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:self -> _assetUrl]];
                UIImage *image = [MIHelpTool fetchThumbnailWithAVAsset:asset curTime:0.0];
                NSData *imgData = UIImageJPEGRepresentation(image, 0.6);
                [imgData writeToFile:imgPath atomically:YES];
            }
           
            VodSVideoInfo *vodInfo = [[VodSVideoInfo alloc] init];
            NSIndexPath *index = self->_themCollection.indexPathsForSelectedItems.firstObject;
            MITheme *t = self->_themes[index.item];
            vodInfo.title = t.title;
            vodInfo.desc = self->_nameTF.text;
            vodInfo.templateGroupId = info.TemplateGroupId;
            vodInfo.cateId = @(0);
            [client uploadWithVideoPath:self.assetUrl imagePath:imgPath svideoInfo:vodInfo accessKeyId:info.AccessKeyId accessKeySecret:info.AccessKeySecret accessToken:info.SecurityToken];
            
        } failureResponse:^(NSError *error) {
            
        }];
    }
    
    
//    NSIndexPath *index = _themCollection.indexPathsForSelectedItems.firstObject;
//    MITheme *t = _themes[index.item];
//    MIAlbumRequest *rq = [[MIAlbumRequest alloc] init];
//    NSData *compress = UIImageJPEGRepresentation(_imageView.image, 0.2);
//    [rq uploadPhotoWithFile:compress title:t.title tags:@[t.themeId] SuccessResponse:^(NSString *message) {
//        
//    } failureResponse:^(NSError *error) {
//        
//    }];
 
}

#pragma mark - VODUploadSVideoClientDelegate
- (void)uploadSuccessWithResult:(VodSVideoUploadResult *)result{
    
    NSLog(@"uploadSuccess:%@",result);
}

- (void)uploadFailedWithCode:(NSString *)code message:(NSString *)message{
    NSLog(@"uploadFailed:%@",message);
}

- (void)uploadTokenExpired{
    NSLog(@"%s",__FUNCTION__);
}

- (void)uploadProgressWithUploadedSize:(long long)uploadedSize totalSize:(long long)totalSize{
    NSLog(@"uploadSize:%lld,totalSize:%lld",uploadedSize,totalSize);
}

- (void)uploadRetry{
    
    NSLog(@"%s",__FUNCTION__);
}

- (void)uploadRetryResume{
    
    NSLog(@"%s",__FUNCTION__);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_nameTF resignFirstResponder];
}

@end
