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

#import <AVFoundation/AVFoundation.h>


@interface MIUploadViewController ()<UICollectionViewDelegate, UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout>

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
    
    
//    NSIndexPath *index = _themCollection.indexPathsForSelectedItems.firstObject;
//    MITheme *t = _themes[index.item];
//    MIAlbumRequest *rq = [[MIAlbumRequest alloc] init];
//    NSData *compress = UIImageJPEGRepresentation(_imageView.image, 0.2);
//    [rq uploadPhotoWithFile:compress title:t.title tags:@[t.themeId] SuccessResponse:^(NSString *message) {
//        
//    } failureResponse:^(NSError *error) {
//        
//    }];
    
    NSIndexPath *index = _themCollection.indexPathsForSelectedItems.firstObject;
     MITheme *t = _themes[index.item];
    MIAlbumRequest *rq = [[MIAlbumRequest alloc] init];
    [rq videoInfoWithTitle:t.title SuccessResponse:^(MIUploadVidoInfo * _Nonnull info) {
        
        

    } failureResponse:^(NSError *error) {

    }];
    
}

@end
