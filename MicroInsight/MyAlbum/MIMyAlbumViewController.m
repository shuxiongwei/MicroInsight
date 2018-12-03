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

typedef NS_ENUM(NSInteger,MIAlbumType) {
    
    MIAlbumTypePhoto = 1,
    MIAlbumTypeVideo
};

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

@end

@implementation MIMyAlbumViewController

static NSString *const cellId = @"MIAlbumCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.assets = [self requestAssetsWithType:MIAlbumTypePhoto];
    if (self.assets.count == 0) {
        _emptyTipView.hidden = NO;
    }else{
        _emptyTipView.hidden = YES;
    }
    [self.albumCollectionView reloadData];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 5.0;
    layout.minimumInteritemSpacing = 5.0;
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 5.0, 0, 5.0);
    layout.sectionInset = inset;
    CGFloat width = (MIScreenWidth - 3 * 5.0) / 2;
    CGFloat height = width * 123 / 118.0;
    layout.itemSize = CGSizeMake(width, height);
    self.albumCollectionView.collectionViewLayout = layout;
    // Do any additional setup after loading the view.
}

- (NSMutableArray *)requestAssetsWithType:(MIAlbumType)type{
    NSString *extention;
    if (type == MIAlbumTypePhoto) {
        extention = @"png";
    } else {
        extention = @"mov";
    }
    NSString *assetsPath = [MIHelpTool assetsPath];
    NSDirectoryEnumerator *DE = [[NSFileManager defaultManager] enumeratorAtPath:assetsPath];
    for (NSString *filename in DE) {
        
        NSString *path = [assetsPath stringByAppendingPathComponent:filename];
        if ([filename.pathExtension isEqualToString:extention]) {
            MIAlbum *album = [[MIAlbum alloc] init];
            album.fileUrl = path;
            [self.assets addObject:album];
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
    } else {
        AVAsset *asset = [AVAsset assetWithURL:[NSURL URLWithString:url]];
        img = [MIHelpTool fetchThumbnailWithAVAsset:asset curTime:0.0];
    }
    cell.assetImgView.image = img;
    cell.isSelected = album.isSelected;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (canSelected) {
        MIAlbum *album = self.assets[indexPath.item];
        album.isSelected = !album.isSelected;
        MIAlbumCell *cell = (MIAlbumCell *)[collectionView cellForItemAtIndexPath:indexPath];
        cell.isSelected = album.isSelected;
        return;
    }
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"MyAlbum" bundle:nil];
    MIUploadViewController *vc = [board instantiateViewControllerWithIdentifier:@"MIUploadViewController"];
    [self.navigationController pushViewController:vc animated:YES];
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
    }
    _typeBottomView.hidden = canSelected;
    _manageBottomView.hidden = !canSelected;
}

- (IBAction)photoBtnClick:(UIButton *)sender {
    
    sender.selected = YES;
    _videoBtn.selected = NO;
    
    [self requestAssetsWithType:MIAlbumTypePhoto];
    [self.albumCollectionView reloadData];
}

- (IBAction)videoBtnClick:(UIButton *)sender {
    
    sender.selected = YES;
    _photoBtn.selected = NO;
    
    [self requestAssetsWithType:MIAlbumTypeVideo];
    [self.albumCollectionView reloadData];
}

- (IBAction)deleteBtnClick:(UIButton *)sender {
    
}

- (IBAction)uploadBtnClick:(UIButton *)sender {
    
}

@end
