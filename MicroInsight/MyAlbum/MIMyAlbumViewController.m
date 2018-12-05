//
//  MIMyAlbumViewController.m
//  MicroInsight
//
//  Created by Jonphy on 2018/11/20.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "MIMyAlbumViewController.h"
#import "MIHelpTool.h"
#import "MIAlbumCell.h"
#import "MIUploadViewController.h"
#import "MIAlbum.h"
#import <AVFoundation/AVFoundation.h>
#import "MILoginViewController.h"
#import "MIReviewImageViewController.h"
#import "MIReviewVideoViewController.h"

@interface MIMyAlbumViewController () <UICollectionViewDelegate, UICollectionViewDataSource>{
 
    BOOL canSelected;
}

@property (weak, nonatomic) IBOutlet UIButton *selectedBtn;
@property (weak, nonatomic) IBOutlet UIView *emptyTipView;
@property (weak, nonatomic) IBOutlet UICollectionView *albumCollectionView;
@property (weak, nonatomic) IBOutlet UIView *manageBottomView;
@property (weak, nonatomic) IBOutlet UIView *typeBottomView;
@property (weak, nonatomic) IBOutlet UIButton *photoBtn;
@property (weak, nonatomic) IBOutlet UIButton *videoBtn;

@property (strong, nonatomic) NSMutableArray *assets;
@property (strong, nonatomic) NSMutableArray *seletedIndexPaths; //标识当前选择的item的indexPath数组

@end

@implementation MIMyAlbumViewController

static NSString *const cellId = @"MIAlbumCell";

- (void)viewDidLoad {
    [super viewDidLoad];

    [self refreshBtnSelected];
    self.assets = [self requestAssetsWithType:_albumType];
    [self showOrHideEmptyTipView];
    [self.albumCollectionView reloadData];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 5.0;
    layout.minimumInteritemSpacing = 5.0;
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 5.0, 0, 5.0);
    layout.sectionInset = inset;
    CGFloat width = (MIScreenWidth - 4 * 5.0) / 3;
    CGFloat height = width * 123 / 118.0;
    layout.itemSize = CGSizeMake(width, height);
    self.albumCollectionView.collectionViewLayout = layout;
    // Do any additional setup after loading the view.
}

- (NSMutableArray *)requestAssetsWithType:(MIAlbumType)type {
    [self.assets removeAllObjects];
    
    NSString *extention;
    if (type == MIAlbumTypePhoto) {
        extention = @"png";
    } else {
        extention = @"mov";
    }
    
    NSString *assetsPath = [MIHelpTool assetsPath];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:assetsPath]) {
        NSArray *contentOfFolder = [fm contentsOfDirectoryAtPath:assetsPath error:nil];
        NSMutableArray *paths = [NSMutableArray arrayWithArray:contentOfFolder];
        [paths sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj2 compare:obj1];
        }];
        
        for (NSString *aPath in paths) {
            if ([aPath.pathExtension isEqualToString:extention]) {
                NSString *fullPath = [assetsPath stringByAppendingPathComponent:aPath];
                MIAlbum *album = [[MIAlbum alloc] init];
                album.fileUrl = fullPath;
                [self.assets addObject:album];
            }
        }
    }
    
    return self.assets;
}

- (NSMutableArray *)assets{
 
    if (_assets == nil) {
        _assets = [NSMutableArray array];
    }
    return _assets;
}

#pragma mark - collectionDelegate,collectionDatasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
 
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    MIAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    MIAlbum *album = self.assets[indexPath.item];
    NSString *url = album.fileUrl;

    UIImage *img = nil;
    if ([[url pathExtension] isEqualToString:@"png"]) {
        img = [UIImage imageWithContentsOfFile:url];
        cell.playBtn.hidden = YES;
    } else {
        AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:url]];
        img = [MIHelpTool fetchThumbnailWithAVAsset:asset curTime:0.0];
        cell.playBtn.hidden = NO;
    }
    cell.assetImgView.image = img;
    cell.isSelected = album.isSelected;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (canSelected) {
//        if ([self.seletedIndexPaths containsObject:indexPath]) {
//            [self.seletedIndexPaths removeObject:indexPath];
//        } else {
//            [self.seletedIndexPaths addObject:indexPath];
//        }
        
        MIAlbum *album = self.assets[indexPath.item];
        album.isSelected = !album.isSelected;
        MIAlbumCell *cell = (MIAlbumCell *)[collectionView cellForItemAtIndexPath:indexPath];
        cell.isSelected = album.isSelected;
        
        return;
    }
    
    MIAlbum *album = self.assets[indexPath.item];
    if (_albumType == MIAlbumTypePhoto) {
        MIReviewImageViewController *imageVC = [[MIReviewImageViewController alloc] init];
        imageVC.imgPath = album.fileUrl;
        [self.navigationController pushViewController:imageVC animated:YES];
    } else {
        MIReviewVideoViewController *videoVC = [[MIReviewVideoViewController alloc] init];
        videoVC.assetPath = album.fileUrl;
        [self.navigationController pushViewController:videoVC animated:YES];
    }
}

#pragma mark - IBAction
- (IBAction)backHomeBtnClick:(UIButton *)sender {

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)selectedBtnClick:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    canSelected = !canSelected;
    if (!canSelected) {
        for (MIAlbum *album in self.assets) {
            album.isSelected = NO;
        }
        [_albumCollectionView reloadData];
//        [self.seletedIndexPaths removeAllObjects];
    }
    _typeBottomView.hidden = canSelected;
    _manageBottomView.hidden = !canSelected;
}

- (IBAction)photoBtnClick:(UIButton *)sender {
    
    if (!sender.selected) {
        sender.selected = YES;
        _videoBtn.selected = NO;
        _albumType = MIAlbumTypePhoto;
//        [self.seletedIndexPaths removeAllObjects];
        [self requestAssetsWithType:MIAlbumTypePhoto];
        [self showOrHideEmptyTipView];
        [self.albumCollectionView reloadData];
    }
}

- (IBAction)videoBtnClick:(UIButton *)sender {
    
    if (!sender.selected) {
        sender.selected = YES;
        _photoBtn.selected = NO;
        _albumType = MIAlbumTypeVideo;
//        [self.seletedIndexPaths removeAllObjects];
        [self requestAssetsWithType:MIAlbumTypeVideo];
        [self showOrHideEmptyTipView];
        [self.albumCollectionView reloadData];
    }
}

- (IBAction)deleteBtnClick:(UIButton *)sender {

    NSMutableArray *selectedAsset = [NSMutableArray array];
    for (MIAlbum *album in _assets) {
        
        if (album.isSelected) {
            [selectedAsset addObject:album];
        }
    }
    if (selectedAsset.count == 0) {
        
        [MIToastAlertView showAlertViewWithMessage:@"请选择需要删除的图片或视频"];
        return;
    }
//    if (self.seletedIndexPaths.count == 0) {
//        [MIToastAlertView showAlertViewWithMessage:@"请选择需要删除的图片或视频"];
//        return;
//    }
    
    NSString *alertText = @"确定删除所选图片吗？";
    if (_albumType == MIAlbumTypeVideo) {
        alertText = @"确定删除所选视频吗？";
    }
    
    [MIAlertView showAlertViewWithFrame:MIScreenBounds alertBounds:CGRectMake(0, 0, 331, 213) alertType:QSAlertMessage alertTitle:@"温馨提示" alertMessage:alertText alertInfo:@"删除" action:^(id alert) {
        
//        for (NSInteger i = 0; i < self.seletedIndexPaths.count; i++) {
//            NSIndexPath *indexP = self.seletedIndexPaths[i];
//            MIAlbum *album = self.assets[indexP.item];
//
//            NSFileManager *fm = [NSFileManager defaultManager];
//            if ([fm fileExistsAtPath:album.fileUrl]) {
//                [fm removeItemAtPath:album.fileUrl error:nil];
//            }
//        }
        for (MIAlbum *asset in selectedAsset) {
            
            NSFileManager *fm = [NSFileManager defaultManager];
            if ([fm fileExistsAtPath:asset.fileUrl]) {
                [fm removeItemAtPath:asset.fileUrl error:nil];
            }
        }
        [self.assets removeObjectsInArray:selectedAsset];
//        [self requestAssetsWithType:self->_albumType];
        [self showOrHideEmptyTipView];
//        [self.seletedIndexPaths removeAllObjects];
        [self.albumCollectionView reloadData];
    }];
}

- (IBAction)uploadBtnClick:(UIButton *)sender {
//    if (self.seletedIndexPaths.count > 1) {
//        [MIToastAlertView showAlertViewWithMessage:@"上传的图片或视频数量不得超过1个"];
//        return;
//    }
    NSMutableArray *selectedAsset = [NSMutableArray array];
    for (MIAlbum *album in _assets) {
        
        if (album.isSelected) {
            [selectedAsset addObject:album];
        }
    }
    if (selectedAsset.count == 0) {
        [MIToastAlertView showAlertViewWithMessage:@"请选择一张照片或一个视频"];
        return;
    }
    
    if (selectedAsset.count > 1) {
        [MIToastAlertView showAlertViewWithMessage:@"上传的图片或视频数量不得超过1个"];
        return;
    }
    
    NSString *username = [MILocalData getCurrentLoginUsername];
    if (![MIHelpTool isBlankString:username]) {
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"MyAlbum" bundle:nil];
        MIUploadViewController *vc = [board instantiateViewControllerWithIdentifier:@"MIUploadViewController"];
//        MIAlbum *asset = self.seletedIndexPaths.firstObject;
//        vc.assetUrl = asset.fileUrl;
        MIAlbum *asset = selectedAsset.firstObject;
        vc.assetUrl = asset.fileUrl;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        MILoginViewController *vc = [board instantiateViewControllerWithIdentifier:@"MILoginViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - refresh
- (void)refreshBtnSelected {
    if (_albumType == MIAlbumTypePhoto) {
        _photoBtn.selected = YES;
        _videoBtn.selected = NO;
    } else {
        _photoBtn.selected = NO;
        _videoBtn.selected = YES;
    }
}

- (void)showOrHideEmptyTipView {
    if (self.assets.count == 0) {
        _emptyTipView.hidden = NO;
    } else {
        _emptyTipView.hidden = YES;
    }
}

#pragma mark - 懒加载
//- (NSMutableArray *)seletedIndexPaths {
//    if (!_seletedIndexPaths) {
//        _seletedIndexPaths = [NSMutableArray arrayWithCapacity:0];
//    }
//
//    return _seletedIndexPaths;
//}

@end
