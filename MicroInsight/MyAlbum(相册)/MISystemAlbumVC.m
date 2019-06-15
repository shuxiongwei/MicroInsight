//
//  MISystemAlbumVC.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/28.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MISystemAlbumVC.h"
#import "MIAlbumCollectionLayout.h"
#import "MIAlbumCell.h"
#import "MIPhotoModel.h"
#import "MIAlbumManager.h"
#import "MIAlbumListView.h"


static NSString * const cellId = @"cellId";

@interface MISystemAlbumVC () <UICollectionViewDelegate, UICollectionViewDataSource, MIAlbumListViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionV;
@property (nonatomic, strong) UIView *uploadView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIButton *titleBtn;
@property (nonatomic, strong) MIAlbumListView *albumListView;
@property (nonatomic, strong) UIView *albumBgView;
@property (nonatomic, strong) NSMutableArray *selectArray;
@property (nonatomic, strong) UILabel *selectLab;
@property (nonatomic, strong) UIButton *cancelBtn;

@end

@implementation MISystemAlbumVC

- (UIView *)albumsBgView {
    if (!_albumBgView) {
        _albumBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MIScreenWidth, MIScreenHeight - KNaviBarAllHeight)];
        _albumBgView.hidden = YES;
        _albumBgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        [_albumBgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickAlbumBgView)]];
    }
    return _albumBgView;
}

- (NSMutableArray *)selectArray {
    if (!_selectArray) {
        _selectArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _selectArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGFloat width = (MIScreenWidth - 2 * 15.0 - 2 * 9.0) / 3.0;
    CGFloat height = width * 140.0 / 109.0;
    [MIAlbumManager manager].AssetThumbnailSize = CGSizeMake(width, height);
    
    [self configSystemAlbumUI];
    [self requestData];
}

- (void)configSystemAlbumUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    _cancelBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(0, 0, 60, 28) normalTitle:nil normalTitleColor:UIColorFromRGBWithAlpha(0x333333, 1) highlightedTitleColor:nil selectedColor:nil titleFont:12 normalImage:[UIImage imageNamed:@"icon_login_back_nor"] highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(clickCancelBtn)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_cancelBtn];
    
    _selectLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 20)];
    _selectLab.textColor = UIColorFromRGBWithAlpha(0x333333, 1);
    _selectLab.font = [UIFont systemFontOfSize:12];
    _selectLab.textAlignment = NSTextAlignmentRight;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_selectLab];
    
    _titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _titleBtn.frame = CGRectMake(0, 0, 200, 30);
    [_titleBtn setTitle:@"手机相册" forState:UIControlStateNormal];
    [_titleBtn setTitleColor:UIColorFromRGBWithAlpha(0x333333, 1) forState:UIControlStateNormal];
    _titleBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_titleBtn layoutButtonWithEdgeInsetsStyle:MIButtonEdgeInsetsStyleRight imageTitleSpace:15];
    [_titleBtn setImage:[UIImage imageNamed:@"icon_album_down_nor"] forState:UIControlStateNormal];
    [_titleBtn addTarget:self action:@selector(clickTitleBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = _titleBtn;
    
    UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MIScreenWidth, 1)];
    lineV.backgroundColor = UIColorFromRGBWithAlpha(0xDDDDDD, 1);
    [self.view addSubview:lineV];
    
    [self configCollectionView];
    [self configUploadBottomView];
}

- (void)configCollectionView {
    MIAlbumCollectionLayout *layout = [[MIAlbumCollectionLayout alloc] init];
    _collectionV = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 2, MIScreenWidth, MIScreenHeight - KNaviBarAllHeight - 2) collectionViewLayout:layout];
    _collectionV.delegate = self;
    _collectionV.dataSource = self;
    _collectionV.showsVerticalScrollIndicator = NO;
    _collectionV.backgroundColor = [UIColor whiteColor];
    [_collectionV registerNib:[UINib nibWithNibName:@"MIAlbumCell" bundle:nil] forCellWithReuseIdentifier:cellId];
    [self.view addSubview:_collectionV];
}

- (void)configUploadBottomView {
    _uploadView = [[UIView alloc] initWithFrame:CGRectMake(0, MIScreenHeight - KNaviBarAllHeight - 60, MIScreenWidth, 60)];
    _uploadView.backgroundColor = [UIColor whiteColor];
    _uploadView.hidden = YES;
    [self.view addSubview:_uploadView];
    
    UIButton *deleteBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(15, 0, 109, 60) normalTitle:@"删除" normalTitleColor:UIColorFromRGBWithAlpha(0x333333, 1) highlightedTitleColor:nil selectedColor:nil titleFont:9 normalImage:[UIImage imageNamed:@"icon_album_delete_nor"] highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(clickDeleteBtn:)];
    [deleteBtn layoutButtonWithEdgeInsetsStyle:MIButtonEdgeInsetsStyleTop imageTitleSpace:5];
    [_uploadView addSubview:deleteBtn];
    
    UIButton *uploadBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(MIScreenWidth - 109 - 15, 0, 109, 60) normalTitle:@"上传" normalTitleColor:UIColorFromRGBWithAlpha(0x333333, 1) highlightedTitleColor:nil selectedColor:nil titleFont:9 normalImage:[UIImage imageNamed:@"icon_album_upload_nor"] highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(clickUploadBtn:)];
    [uploadBtn layoutButtonWithEdgeInsetsStyle:MIButtonEdgeInsetsStyleTop imageTitleSpace:5];
    [_uploadView addSubview:uploadBtn];
}

- (void)configAlbumViewWithHeight:(CGFloat)height {
    if (!_albumListView) {
        [self.view addSubview:self.albumsBgView];
        _albumListView = [[MIAlbumListView alloc] initWithFrame:CGRectMake(0, -1000, self.view.frame.size.width, height)];
        _albumListView.delegate = self;
        [self.view addSubview:_albumListView];
    } else {
        _albumListView.y = -1000;
        _albumListView.height = height;
    }
}

- (void)requestData {
    WSWeak(weakSelf);
    [[MIAlbumManager manager] getAllAlbums:YES allowPickingImage:YES needFetchAssets:YES completion:^(NSArray<MIAlbumModel *> * _Nonnull models) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            MIAlbumModel *model = models.firstObject;
            if (model.count > 0) {
                [weakSelf configAlbumViewWithHeight:MIN(models.count * 95, MIScreenHeight - KNaviBarAllHeight)];
                weakSelf.albumListView.list = models;
                
                MIPhotoModel *mod = weakSelf.albumListView.list[weakSelf.albumListView.currentIndex];
                if (mod) {
                    weakSelf.titleBtn.selected = YES;
                    [weakSelf didClickTableViewCell:weakSelf.albumListView.list[weakSelf.albumListView.currentIndex] animate:YES];
                }
            }
        });
    }];
}

- (void)clickDeleteBtn:(UIButton *)sender {

    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
    for (MIPhotoModel *model in self.selectArray) {
        [arr addObject:model.asset];
    }
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest deleteAssets:arr];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MIHudView showMsg:@"图片删除成功"];
            [self.selectArray removeAllObjects];
            [self requestData];
        });
    }];
}

- (void)clickUploadBtn:(UIButton *)sender {

}

- (void)clickTitleBtn:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.albumsBgView.hidden = NO;
        [UIView animateWithDuration:0.25 animations:^{
            _albumListView.frame = CGRectMake(0, 0, self.view.frame.size.width, _albumListView.height);
            self.albumsBgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
            sender.imageView.transform = CGAffineTransformMakeRotation(M_PI);
            [self.view bringSubviewToFront:self.albumsBgView];
            [self.view bringSubviewToFront:_albumListView];
        }];
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            _albumListView.frame = CGRectMake(0, -1000, self.view.frame.size.width, _albumListView.height);
            self.albumsBgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
            sender.imageView.transform = CGAffineTransformMakeRotation(M_PI * 2);
        } completion:^(BOOL finished) {
            self.albumsBgView.hidden = YES;
        }];
    }
}

- (void)didClickAlbumBgView {
    [self clickTitleBtn:_titleBtn];
}

- (void)clickCancelBtn {
    if (self.selectArray.count == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.selectArray removeAllObjects];
        [self setSelectLabStatus];
        
        MIAlbumModel *model = self.albumListView.list[self.albumListView.currentIndex];
        [self setModelSelectStatus:model];
        self.dataArray = [NSMutableArray arrayWithArray:model.photos];
        [_collectionV reloadData];
    }
}

- (void)setModelSelectStatus:(MIAlbumModel *)model {
    for (NSInteger i = 0; i < model.photos.count; i++) {
        MIPhotoModel *mod = model.photos[i];
        mod.isSelected = NO;
        
        for (NSInteger j = 0; j < self.selectArray.count; j++) {
            MIPhotoModel *m = self.selectArray[j];
            if ([mod.asset.localIdentifier isEqualToString:m.asset.localIdentifier]) {
                mod.isSelected = YES;
            }
        }
    }
}

- (MIPhotoModel *)getCurrentHandleModel:(MIPhotoModel *)model {
    for (NSInteger i = 0; i < self.selectArray.count; i++) {
        MIPhotoModel *m = self.selectArray[i];
        if ([model.asset.localIdentifier isEqualToString:m.asset.localIdentifier]) {
            return m;
        }
    }
    
    return nil;
}

- (void)setSelectLabStatus {
    if (self.selectArray.count == 0) {
        _selectLab.hidden = YES;
        _uploadView.hidden = YES;
        [_cancelBtn setImage:[UIImage imageNamed:@"icon_login_back_nor"] forState:UIControlStateNormal];
        [_cancelBtn setTitle:nil forState:UIControlStateNormal];
    } else {
        _selectLab.hidden = NO;
        _selectLab.text = [NSString stringWithFormat:@"已选择（%ld）", self.selectArray.count];
        _uploadView.hidden = NO;
        [_cancelBtn setImage:nil forState:UIControlStateNormal];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    }
}

#pragma mark - MIAlbumListViewDelegate
- (void)didClickTableViewCell:(MIAlbumModel *)model animate:(BOOL)animate {
    [_titleBtn setTitle:model.name forState:UIControlStateNormal];
    [self clickTitleBtn:_titleBtn];
    
    [self setSelectLabStatus];
    [self setModelSelectStatus:model];
    self.dataArray = [NSMutableArray arrayWithArray:model.photos];
    [_collectionV reloadData];
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MIAlbumCell *cell = (MIAlbumCell *)[collectionView cellForItemAtIndexPath:indexPath];;
    MIPhotoModel *model = self.dataArray[indexPath.item];
    
    if (model.isSelected) {
        MIPhotoModel *mod = [self getCurrentHandleModel:model];
        if (mod) {
            [self.selectArray removeObject:mod];
        }
        
        model.isSelected = NO;
        cell.selectBtn.selected = NO;
    } else {
        model.isSelected = YES;
        cell.selectBtn.selected = YES;
        [self.selectArray addObject:model];
    }
    
    [self setSelectLabStatus];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MIAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];;
    MIPhotoModel *model = self.dataArray[indexPath.item];
    
    cell.selectBtn.selected = model.isSelected;
    cell.maskView.hidden = !model.isSelected;
    
    if ([MIHelpTool isBlankString:model.filePath]) {
        if (model.asset.mediaType == PHAssetMediaTypeImage) {
            cell.durationLab.hidden = YES;
        } else {
            cell.durationLab.hidden = NO;
            cell.durationLab.text = model.duration;
        }
        
        CGFloat scale = [UIScreen mainScreen].scale;
        CGFloat width = cell.bounds.size.width * scale / 1;
        CGFloat height = cell.bounds.size.height * scale / 1;

        [[MIAlbumManager manager] getPhotoWithAsset:model.asset photoSize:CGSizeMake(width, height) completion:^(UIImage * _Nonnull photo, NSDictionary * _Nonnull info) {

            dispatch_async(dispatch_get_main_queue(), ^{
                cell.imgView.image = photo;
            });
        }];
    } else {
        UIImage *image;
        if ([model.filePath.pathExtension isEqualToString:@"png"]) {
            image = [UIImage imageWithContentsOfFile:model.filePath];
            cell.durationLab.hidden = YES;
        } else {
            AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:model.filePath]];
            image = [MIHelpTool fetchThumbnailWithAVAsset:asset curTime:0.0];
            cell.durationLab.hidden = NO;
            cell.durationLab.text = [MIHelpTool convertTime:asset.duration.value / (asset.duration.timescale * 1.0)];
        }
        
        cell.imgView.image = image;
    }

    return cell;
}

@end
