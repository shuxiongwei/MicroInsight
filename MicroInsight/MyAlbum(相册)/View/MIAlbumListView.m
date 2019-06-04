//
//  MIAlbumListView.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/29.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIAlbumListView.h"
#import "MIPhotoModel.h"
#import "MIAlbumListCell.h"


@interface MIAlbumListView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end


@implementation MIAlbumListView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.currentIndex = 0;
        [self setup];
    }
    
    return self;
}

- (void)setup {
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, width, height) style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
    [tableView registerNib:[UINib nibWithNibName:@"MIAlbumListCell" bundle:nil] forCellReuseIdentifier:@"MIAlbumListCell"];
    [self addSubview:tableView];
    self.tableView = tableView;
}

- (void)setList:(NSArray *)list {
    _list = list;
    
    [self.tableView reloadData];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)setPhotoSelectStatusOfAlbumListWithId:(NSString *)photoId selected:(BOOL)isSelected {
    
    for (MIAlbumModel *albumModel in _list) {
        for (MIPhotoModel *assetModel in albumModel.photos) {
            if ([assetModel.asset.localIdentifier isEqualToString:photoId]) {
                assetModel.isSelected = isSelected;
//                if (assetModel.isSelected) {
//                    albumModel.selectedCount += 1;
//                } else {
//                    albumModel.selectedCount -= 1;
//                }
            }
        }
    }
    
    [self.tableView reloadData];
}

- (void)setPhotoSelectStatusOfAlbumListWithAssetList:(NSArray *)assetList {
    for (MIPhotoModel *model in assetList) {
        [self setPhotoSelectStatusOfAlbumListWithId:model.asset.localIdentifier selected:model.isSelected];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MIAlbumListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MIAlbumListCell"];
    cell.model = self.list[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.currentIndex = indexPath.row;
    if ([self.delegate respondsToSelector:@selector(didClickTableViewCell:animate:)]) {
        [self.delegate didClickTableViewCell:self.list[indexPath.row] animate:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 95;
}

@end
