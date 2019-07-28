//
//  MIPrivateLetterAlbumVC.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/7/9.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIPrivateLetterAlbumVC.h"
#import "MIAlbumCollectionLayout.h"
#import "MIAlbumCell.h"
#import "MIPhotoModel.h"
#import "MIAlbumManager.h"
#import "MIAlbumListView.h"
#import "MIPrivateImageReviewVC.h"

static NSString * const privateCellId = @"privateCellId";

@interface MIPrivateLetterAlbumVC () <UICollectionViewDelegate, UICollectionViewDataSource, MIAlbumListViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionV;
@property (nonatomic, strong) UIView *uploadView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIButton *titleBtn;
@property (nonatomic, strong) MIAlbumListView *albumListView;
@property (nonatomic, strong) UIView *albumBgView;
@property (nonatomic, strong) NSMutableArray *selectArray;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, strong) UIButton *originalBtn;

@end

@implementation MIPrivateLetterAlbumVC

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
    [super configLeftBarButtonItem:nil];
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 69, 24)];
    rightView.backgroundColor = [UIColor clearColor];
    _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBtn.frame = CGRectMake(0, 0, 49, 24);
    [_rightBtn setTitle:[MILocalData appLanguage:@"community_key_6"] forState:UIControlStateNormal];
    [_rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _rightBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_rightBtn setEnlargeEdge:10];
    _rightBtn.backgroundColor = UIColorFromRGBWithAlpha(0x4A9DD5, 1);
    _rightBtn.alpha = 0.5;
    _rightBtn.userInteractionEnabled = NO;
    [_rightBtn round:3 RectCorners:UIRectCornerAllCorners];
    [_rightBtn addTarget:self action:@selector(clickRightBtn) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:_rightBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightView];
    
    _titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _titleBtn.frame = CGRectMake(0, 0, 200, 30);
    [_titleBtn setTitle:[MILocalData appLanguage:@"album_key_1"] forState:UIControlStateNormal];
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
    _collectionV = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 2, MIScreenWidth, MIScreenHeight - KNaviBarAllHeight - 2 - 60) collectionViewLayout:layout];
    _collectionV.delegate = self;
    _collectionV.dataSource = self;
    _collectionV.showsVerticalScrollIndicator = NO;
    _collectionV.backgroundColor = [UIColor whiteColor];
    [_collectionV registerNib:[UINib nibWithNibName:@"MIAlbumCell" bundle:nil] forCellWithReuseIdentifier:privateCellId];
    [self.view addSubview:_collectionV];
}

- (void)configUploadBottomView {
    _uploadView = [[UIView alloc] initWithFrame:CGRectMake(0, MIScreenHeight - KNaviBarAllHeight - 60, MIScreenWidth, 60)];
    _uploadView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_uploadView];
    
    UIButton *reviewBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(15, 0, 109, 60) normalTitle:[MILocalData appLanguage:@"community_key_25"] normalTitleColor:UIColorFromRGBWithAlpha(0x333333, 1) highlightedTitleColor:nil selectedColor:nil titleFont:15 normalImage:nil highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(clickReviewBtn:)];
    [_uploadView addSubview:reviewBtn];
    
    _originalBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(MIScreenWidth - 109 - 15, 0, 109, 60) normalTitle:[MILocalData appLanguage:@"community_key_26"] normalTitleColor:UIColorFromRGBWithAlpha(0x333333, 1) highlightedTitleColor:nil selectedColor:nil titleFont:15 normalImage:[UIImage imageNamed:@"icon_letter_original_nor"] highlightedImage:nil selectedImage:[UIImage imageNamed:@"icon_letter_original_sel"] touchUpInSideTarget:self action:@selector(clickOriginalBtn:)];
    [_originalBtn layoutButtonWithEdgeInsetsStyle:MIButtonEdgeInsetsStyleLeft imageTitleSpace:5];
    [_uploadView addSubview:_originalBtn];
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
            
            NSMutableArray *copyModels = [NSMutableArray arrayWithCapacity:0];
            for (MIAlbumModel *model in models) {
                NSMutableArray *copyPhotos = [NSMutableArray arrayWithCapacity:0];
                for (MIPhotoModel *photo in model.photos) {
                    if (photo.asset.mediaType == PHAssetMediaTypeImage) {
                        [copyPhotos addObject:photo];
                    }
                }
                
                if (copyPhotos.count > 0) {
                    model.photos = copyPhotos;
                    [copyModels addObject:model];
                }
            }
            
            MIAlbumModel *model = copyModels.firstObject;
            if (model.count > 0) {
                [weakSelf configAlbumViewWithHeight:MIN(models.count * 95, MIScreenHeight - KNaviBarAllHeight)];
                weakSelf.albumListView.list = copyModels;
                
                MIPhotoModel *mod = weakSelf.albumListView.list[weakSelf.albumListView.currentIndex];
                if (mod) {
                    weakSelf.titleBtn.selected = YES;
                    [weakSelf didClickTableViewCell:weakSelf.albumListView.list[weakSelf.albumListView.currentIndex] animate:YES];
                }
            }
        });
    }];
}

- (void)clickReviewBtn:(UIButton *)sender {
    if (self.selectArray.count == 0) {
        return;
    }
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("getImagesQueue", DISPATCH_QUEUE_SERIAL);
    __block NSMutableArray *images = [NSMutableArray arrayWithCapacity:0];
    
    for (MIPhotoModel *model in self.selectArray) {
        dispatch_group_enter(group);
        
        if (_originalBtn.selected) {
            [[MIAlbumManager manager] getOriginalPhotoDataWithAsset:model.asset progressHandler:^(double progress, NSError * _Nonnull error, BOOL * _Nonnull stop, NSDictionary * _Nonnull info) {
                
            } completion:^(NSData * _Nonnull data, NSDictionary * _Nonnull info, BOOL isDegraded) {
                
                dispatch_group_leave(group);
                
                UIImage *img = [UIImage imageWithData:data];
                [images addObject:img];
            }];
        } else {
            [[MIAlbumManager manager] getPhotoWithAsset:model.asset photoSize:PHImageManagerMaximumSize completion:^(UIImage * _Nonnull photo, NSDictionary * _Nonnull info) {
                
                dispatch_group_leave(group);
                
                [images addObject:photo];
            }];
        }
    }
    
    dispatch_group_notify(group, queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            MIPrivateImageReviewVC *vc = [[MIPrivateImageReviewVC alloc] init];
            vc.imageArray = images;
            [self.navigationController pushViewController:vc animated:YES];
        });
    });
}

- (void)clickOriginalBtn:(UIButton *)sender {
    sender.selected = !sender.selected;
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

- (void)clickRightBtn {
    
    [MBProgressHUD showStatus:[NSString stringWithFormat:@"%@...", [MILocalData appLanguage:@"other_key_7"]]];
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("getImagesQueue", DISPATCH_QUEUE_SERIAL);
    __block NSMutableArray *images = [NSMutableArray arrayWithCapacity:0];
    
    for (MIPhotoModel *model in self.selectArray) {
        dispatch_group_enter(group);
        
        if (_originalBtn.selected) {
            [[MIAlbumManager manager] getOriginalPhotoDataWithAsset:model.asset progressHandler:^(double progress, NSError * _Nonnull error, BOOL * _Nonnull stop, NSDictionary * _Nonnull info) {
                
            } completion:^(NSData * _Nonnull data, NSDictionary * _Nonnull info, BOOL isDegraded) {
                
                dispatch_group_leave(group);
                
                UIImage *img = [UIImage imageWithData:data];
                [images addObject:img];
            }];
        } else {
            [[MIAlbumManager manager] getPhotoWithAsset:model.asset photoSize:PHImageManagerMaximumSize completion:^(UIImage * _Nonnull photo, NSDictionary * _Nonnull info) {
                
                dispatch_group_leave(group);
                
                [images addObject:photo];
            }];
        }
    }
    
    dispatch_group_notify(group, queue, ^{
        
        dispatch_group_t sendGroup = dispatch_group_create();
        dispatch_queue_t sendQueue = dispatch_queue_create("sendImagesQueue", DISPATCH_QUEUE_SERIAL);
        
        for (UIImage *img in images) {
            dispatch_group_enter(sendGroup);
            NSString *fileName = [[MIHelpTool timeStampSecond] stringByAppendingString:@".jpg"];
            [MIRequestManager sendImageLetterWithReceiveId:[NSString stringWithFormat:@"%ld", self.user_receive_id] fileName:fileName image:img requestToken:[MILocalData getCurrentRequestToken] completed:^(id  _Nonnull jsonData, NSError * _Nonnull error) {
                
                dispatch_group_leave(sendGroup);
            }];
        }
        
        dispatch_group_notify(sendGroup, sendQueue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"sendImageLetterFinish" object:nil];
                [MBProgressHUD hideHUD];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    [self.navigationController popViewControllerAnimated:YES];
                });
            });
        });
    });
}

- (void)didClickAlbumBgView {
    [self clickTitleBtn:_titleBtn];
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
        _rightBtn.alpha = 0.5;
        _rightBtn.userInteractionEnabled = NO;
    } else {
        _rightBtn.alpha = 1;
        _rightBtn.userInteractionEnabled = YES;
    }
}

#pragma mark - MIAlbumListViewDelegate
- (void)didClickTableViewCell:(MIAlbumModel *)model animate:(BOOL)animate {
    [_titleBtn setTitle:model.name forState:UIControlStateNormal];
    [_titleBtn layoutButtonWithEdgeInsetsStyle:MIButtonEdgeInsetsStyleRight imageTitleSpace:15];
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
    
    MIAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:privateCellId forIndexPath:indexPath];
    MIPhotoModel *model = self.dataArray[indexPath.item];
    cell.selectBtn.hidden = NO;
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
