//
//  MILocalAlbumVC.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/20.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MILocalAlbumVC.h"
#import "MIAlbumCell.h"
#import "MIPhotoModel.h"
#import "MIAlbumCollectionLayout.h"
#import "MicroInsight-Swift.h"
#import "MISystemAlbumVC.h"

static NSString * const allCellId = @"allCellId";
static NSString * const photoCellId = @"photoCellId";
static NSString * const videoCellId = @"videoCellId";

@interface MILocalAlbumVC () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *allCollectionV;
@property (nonatomic, strong) UICollectionView *photoCollectionV;
@property (nonatomic, strong) UICollectionView *videoCollectionV;
@property (nonatomic, strong) NSMutableArray *allArray;
@property (nonatomic, strong) NSMutableArray *photoArray;
@property (nonatomic, strong) NSMutableArray *videoArray;
@property (nonatomic, strong) NSMutableArray *selectArray;
@property (nonatomic, strong) UIView *selectView;
@property (nonatomic, strong) UIView *uploadView;
@property (nonatomic, strong) UIButton *allBtn;
@property (nonatomic, strong) UIButton *photoBtn;
@property (nonatomic, strong) UIButton *videoBtn;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *phoneAlbumBtn;

@end

@implementation MILocalAlbumVC

- (NSMutableArray *)allArray {
    if (!_allArray) {
        _allArray = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _allArray;
}

- (NSMutableArray *)photoArray {
    if (!_photoArray) {
        _photoArray = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _photoArray;
}

- (NSMutableArray *)videoArray {
    if (!_videoArray) {
        _videoArray = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _videoArray;
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
    
    NSString *assetPath = [MIHelpTool assetsPath];
    NSString *path = [NSString stringWithFormat:@"%@/%@", assetPath, @"movie.mov"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    };
    
    [self configLocalAlbumUI];
    [self requestAssets];
}

- (void)configLocalAlbumUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    _cancelBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(0, 0, 38, 28) normalTitle:nil normalTitleColor:UIColorFromRGBWithAlpha(0x333333, 1) highlightedTitleColor:nil selectedColor:nil titleFont:12 normalImage:[UIImage imageNamed:@"icon_login_back_nor"] highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(clickCancelBtn)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_cancelBtn];
    
    _phoneAlbumBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(0, 0, 60, 30) normalTitle:@"手机相册" normalTitleColor:UIColorFromRGBWithAlpha(0x333333, 1) highlightedTitleColor:nil selectedColor:nil titleFont:12 normalImage:nil highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(selectPhotoFromSystemAlbum)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_phoneAlbumBtn];
    
    _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    _titleLab.text = @"相册";
    _titleLab.font = [UIFont systemFontOfSize:15];
    _titleLab.textColor = UIColorFromRGBWithAlpha(0x333333, 1);
    _titleLab.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = _titleLab;
    
    UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MIScreenWidth, 1)];
    lineV.backgroundColor = UIColorFromRGBWithAlpha(0xDDDDDD, 1);
    [self.view addSubview:lineV];
    
    [self configCollectionView];
    [self configSelectBottomView];
    [self configUploadBottomView];
}

- (void)configCollectionView {
    MIAlbumCollectionLayout *allLayout = [[MIAlbumCollectionLayout alloc] init];
    CGFloat hgt = [MIUIFactory getNavigitionBarHeight:self] + StatusBarHeight;
    _allCollectionV = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 2, MIScreenWidth, MIScreenHeight - hgt - 60 - 2) collectionViewLayout:allLayout];
    _allCollectionV.delegate = self;
    _allCollectionV.dataSource = self;
    _allCollectionV.showsVerticalScrollIndicator = NO;
    _allCollectionV.backgroundColor = [UIColor whiteColor];
    [_allCollectionV registerNib:[UINib nibWithNibName:@"MIAlbumCell" bundle:nil] forCellWithReuseIdentifier:allCellId];
    [self.view addSubview:_allCollectionV];
    
    MIAlbumCollectionLayout *photoLayout = [[MIAlbumCollectionLayout alloc] init];
    _photoCollectionV = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 2, MIScreenWidth, MIScreenHeight - hgt - 60 - 2) collectionViewLayout:photoLayout];
    _photoCollectionV.delegate = self;
    _photoCollectionV.dataSource = self;
    _photoCollectionV.hidden = YES;
    _photoCollectionV.showsVerticalScrollIndicator = NO;
    _photoCollectionV.backgroundColor = [UIColor whiteColor];
    [_photoCollectionV registerNib:[UINib nibWithNibName:@"MIAlbumCell" bundle:nil] forCellWithReuseIdentifier:photoCellId];
    [self.view addSubview:_photoCollectionV];

    MIAlbumCollectionLayout *videoLayout = [[MIAlbumCollectionLayout alloc] init];
    _videoCollectionV = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 2, MIScreenWidth, MIScreenHeight - hgt - 60 - 2) collectionViewLayout:videoLayout];
    _videoCollectionV.delegate = self;
    _videoCollectionV.dataSource = self;
    _videoCollectionV.hidden = YES;
    _videoCollectionV.showsVerticalScrollIndicator = NO;
    _videoCollectionV.backgroundColor = [UIColor whiteColor];
    [_videoCollectionV registerNib:[UINib nibWithNibName:@"MIAlbumCell" bundle:nil] forCellWithReuseIdentifier:videoCellId];
    [self.view addSubview:_videoCollectionV];
}

- (void)configSelectBottomView {
    CGFloat hgt = [MIUIFactory getNavigitionBarHeight:self] + StatusBarHeight;
    _selectView = [[UIView alloc] initWithFrame:CGRectMake(0, MIScreenHeight - hgt - 60, MIScreenWidth, 60)];
    [self.view addSubview:_selectView];
    
    _allBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(15, 0, 109, 60) normalTitle:@"全部" normalTitleColor:UIColorFromRGBWithAlpha(0x333333, 1) highlightedTitleColor:nil selectedColor:nil titleFont:15 normalImage:[UIImage imageNamed:@"icon_album_line_nor"] highlightedImage:nil selectedImage:[UIImage imageNamed:@"icon_album_line_sel"] touchUpInSideTarget:self action:@selector(clickAllBtn:)];
    _allBtn.selected = YES;
    [_allBtn layoutButtonWithEdgeInsetsStyle:MIButtonEdgeInsetsStyleBottom imageTitleSpace:5];
    [_selectView addSubview:_allBtn];
    
    _photoBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(0, 0, 109, 60) normalTitle:@"相册" normalTitleColor:UIColorFromRGBWithAlpha(0x333333, 1) highlightedTitleColor:nil selectedColor:nil titleFont:15 normalImage:[UIImage imageNamed:@"icon_album_line_nor"] highlightedImage:nil selectedImage:[UIImage imageNamed:@"icon_album_line_sel"] touchUpInSideTarget:self action:@selector(clickPhotoBtn:)];
    _photoBtn.center = CGPointMake(_selectView.centerX, 30);
    [_photoBtn layoutButtonWithEdgeInsetsStyle:MIButtonEdgeInsetsStyleBottom imageTitleSpace:5];
    [_selectView addSubview:_photoBtn];
    
    _videoBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(MIScreenWidth - 109 - 15, 0, 109, 60) normalTitle:@"视频" normalTitleColor:UIColorFromRGBWithAlpha(0x333333, 1) highlightedTitleColor:nil selectedColor:nil titleFont:15 normalImage:[UIImage imageNamed:@"icon_album_line_nor"] highlightedImage:nil selectedImage:[UIImage imageNamed:@"icon_album_line_sel"] touchUpInSideTarget:self action:@selector(clickVideoBtn:)];
    [_videoBtn layoutButtonWithEdgeInsetsStyle:MIButtonEdgeInsetsStyleBottom imageTitleSpace:5];
    [_selectView addSubview:_videoBtn];
}

- (void)configUploadBottomView {
    CGFloat hgt = [MIUIFactory getNavigitionBarHeight:self] + StatusBarHeight;
    _uploadView = [[UIView alloc] initWithFrame:CGRectMake(0, MIScreenHeight - hgt - 60, MIScreenWidth, 60)];
    _uploadView.hidden = YES;
    [self.view addSubview:_uploadView];
    
    UIButton *deleteBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(15, 0, 109, 60) normalTitle:@"删除" normalTitleColor:UIColorFromRGBWithAlpha(0x333333, 1) highlightedTitleColor:nil selectedColor:nil titleFont:9 normalImage:[UIImage imageNamed:@"icon_album_delete_nor"] highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(clickDeleteBtn:)];
    [deleteBtn layoutButtonWithEdgeInsetsStyle:MIButtonEdgeInsetsStyleTop imageTitleSpace:5];
    [_uploadView addSubview:deleteBtn];
    
    UIButton *uploadBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(MIScreenWidth - 109 - 15, 0, 109, 60) normalTitle:@"上传" normalTitleColor:UIColorFromRGBWithAlpha(0x333333, 1) highlightedTitleColor:nil selectedColor:nil titleFont:9 normalImage:[UIImage imageNamed:@"icon_album_upload_nor"] highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(clickUploadBtn:)];
    [uploadBtn layoutButtonWithEdgeInsetsStyle:MIButtonEdgeInsetsStyleTop imageTitleSpace:5];
    [_uploadView addSubview:uploadBtn];
}

- (void)requestAssets {
    [self.allArray removeAllObjects];
    [self.photoArray removeAllObjects];
    [self.videoArray removeAllObjects];
    
    NSString *assetsPath = [MIHelpTool assetsPath];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:assetsPath]) {
        NSArray *contentOfFolder = [fm contentsOfDirectoryAtPath:assetsPath error:nil];
        if (contentOfFolder.count > 0) {
            NSMutableArray *paths = [NSMutableArray arrayWithArray:contentOfFolder];
            [paths sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                return [obj2 compare:obj1];
            }];
            
            for (NSString *aPath in paths) {
                NSString *fullPath = [assetsPath stringByAppendingPathComponent:aPath];
                
                MIPhotoModel *model = [[MIPhotoModel alloc] init];
                model.filePath = fullPath;

                if ([aPath.pathExtension isEqualToString:@"png"]) {
                    model.type = MIAlbumTypePhoto;
                    [self.photoArray addObject:model];
                } else if ([aPath.pathExtension isEqualToString:@"mov"]) {
                    model.type = MIAlbumTypeVideo;
                    [self.videoArray addObject:model];
                }
                
                MIPhotoModel *copyModel = [model copy];
                copyModel.type = MIAlbumTypeAll;
                [self.allArray addObject:copyModel];
            }
            
            [_allCollectionV reloadData];
            [_photoCollectionV reloadData];
            [_videoCollectionV reloadData];
        }
    }
}

#pragma mark - 事件响应
- (void)selectPhotoFromSystemAlbum {
    MISystemAlbumVC *vc = [[MISystemAlbumVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)clickAllBtn:(UIButton *)sender {
    if (!sender.selected) {
        _allBtn.selected = YES;
        _photoBtn.selected = NO;
        _videoBtn.selected = NO;
        _allCollectionV.hidden = NO;
        _photoCollectionV.hidden = YES;
        _videoCollectionV.hidden = YES;
    }
}

- (void)clickPhotoBtn:(UIButton *)sender {
    if (!sender.selected) {
        _allBtn.selected = NO;
        _photoBtn.selected = YES;
        _videoBtn.selected = NO;
        _allCollectionV.hidden = YES;
        _photoCollectionV.hidden = NO;
        _videoCollectionV.hidden = YES;
    }
}

- (void)clickVideoBtn:(UIButton *)sender {
    if (!sender.selected) {
        _allBtn.selected = NO;
        _photoBtn.selected = NO;
        _videoBtn.selected = YES;
        _allCollectionV.hidden = YES;
        _photoCollectionV.hidden = YES;
        _videoCollectionV.hidden = NO;
    }
}

- (void)clickDeleteBtn:(UIButton *)sender {
 
    [MICustomAlertView showAlertViewWithFrame:MIScreenBounds alertTitle:@"温馨提示" alertMessage:@"确定要删除这些图片或视频吗？" leftAction:^(void) {
        
    } rightAction:^(void) {
        for (MIPhotoModel *model in self.selectArray) {
            NSFileManager *fm = [NSFileManager defaultManager];
            if ([fm fileExistsAtPath:model.filePath]) {
                [fm removeItemAtPath:model.filePath error:nil];
            }
        }
        
        [self requestAssets];
        [self.selectArray removeAllObjects];
        [self showOrHideBottomView];
    }];
}

- (void)clickUploadBtn:(UIButton *)sender {
    if (self.selectArray.count > 1) {
        [MIHudView showMsg:@"只支持上传单张图片或视频"];
    } else {
        MIPhotoModel *model = self.selectArray.firstObject;
        
        if ([model.filePath.pathExtension isEqualToString:@"png"]) {
            MIEditOrUploadVC *vc = [[MIEditOrUploadVC alloc] init];
            vc.imgUrl = model.filePath;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            MIVideoUploadVC *vc = [[MIVideoUploadVC alloc] init];
            vc.videoUrl = model.filePath;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void)clickCancelBtn {
    if (self.selectArray.count == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.selectArray removeAllObjects];
        [self showOrHideBottomView];
        
        if (_allBtn.selected) {
            for (MIPhotoModel *model in self.allArray) {
                model.isSelected = NO;
            }
            [_allCollectionV reloadData];
        }
        
        if (_photoBtn.selected) {
            for (MIPhotoModel *model in self.photoArray) {
                model.isSelected = NO;
            }
            [_photoCollectionV reloadData];
        }
        
        if (_videoBtn.selected) {
            for (MIPhotoModel *model in self.videoArray) {
                model.isSelected = NO;
            }
            [_videoCollectionV reloadData];
        }
    }
}

#pragma mark - helper
- (void)showOrHideBottomView {
    if (self.selectArray.count == 0) {
        _selectView.hidden = NO;
        _uploadView.hidden = YES;
        [_cancelBtn setImage:[UIImage imageNamed:@"icon_login_back_nor"] forState:UIControlStateNormal];
        [_cancelBtn setTitle:nil forState:UIControlStateNormal];
        _titleLab.text = @"相册";
        _phoneAlbumBtn.hidden = NO;
    } else {
        _selectView.hidden = YES;
        _uploadView.hidden = NO;
        [_cancelBtn setImage:nil forState:UIControlStateNormal];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        _titleLab.text = [NSString stringWithFormat:@"已选择（%ld）", self.selectArray.count];
        _phoneAlbumBtn.hidden = YES;
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MIAlbumCell *cell = (MIAlbumCell *)[collectionView cellForItemAtIndexPath:indexPath];;
    MIPhotoModel *model;
    if (collectionView == _allCollectionV) {
        model = self.allArray[indexPath.item];
    } else if (collectionView == _photoCollectionV) {
        model = self.photoArray[indexPath.item];
    } else {
        model = self.videoArray[indexPath.item];
    }
    
    if (model.isSelected) {
        model.isSelected = NO;
        cell.selectBtn.selected = NO;
        cell.maskView.hidden = YES;
        [self.selectArray removeObject:model];
    } else {
        model.isSelected = YES;
        cell.selectBtn.selected = YES;
        cell.maskView.hidden = NO;
        [self.selectArray addObject:model];
    }
    [self showOrHideBottomView];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (collectionView == _allCollectionV) {
        return self.allArray.count;
    } else if (collectionView == _photoCollectionV) {
        return self.photoArray.count;
    } else {
        return self.videoArray.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MIAlbumCell *cell;
    MIPhotoModel *model;
    
    if (collectionView == _allCollectionV) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:allCellId forIndexPath:indexPath];
        model = self.allArray[indexPath.item];
    } else if (collectionView == _photoCollectionV) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:photoCellId forIndexPath:indexPath];
        model = self.photoArray[indexPath.item];
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:videoCellId forIndexPath:indexPath];
        model = self.videoArray[indexPath.item];
    }
    
    UIImage *image;
    if ([model.filePath.pathExtension isEqualToString:@"png"]) {
        image = [UIImage imageWithContentsOfFile:model.filePath];
        cell.durationLab.hidden = YES;
        cell.playBtn.hidden = YES;
    } else {
        AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:model.filePath]];
        image = [MIHelpTool fetchThumbnailWithAVAsset:asset curTime:0.0];
        cell.playBtn.hidden = NO;
        cell.durationLab.hidden = NO;
        cell.durationLab.text = [MIHelpTool convertTime:asset.duration.value / (asset.duration.timescale * 1.0)];
    }
    
    cell.selectBtn.selected = model.isSelected;
    cell.maskView.hidden = !model.isSelected;
    cell.imgView.image = image;
    
    return cell;
}

@end
