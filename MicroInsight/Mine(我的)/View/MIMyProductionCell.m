//
//  MIMyProductionCell.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/1.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIMyProductionCell.h"
#import "MICommunityListModel.h"
#import "UIImageView+WebCache.h"

@implementation MIMyProductionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.layer.cornerRadius = 2;
    self.layer.masksToBounds = YES;
}

- (void)setCellWithModel:(MICommunityListModel *)model {
    
    _titleLab.text = model.title;
    
    NSString *url;
    if (model.contentType == 0) {
        url = model.url;
        _playBtn.hidden = YES;
    } else {
        url = model.coverUrl;
        _playBtn.hidden = NO;
    }
    
    url = [NSString stringWithFormat:@"%@?x-oss-process=image/resize,m_fill,h_%ld,w_%ld", url, (NSInteger)(_imgView.width / 1) , (NSInteger)(_imgView.width * 125.0 / 168.0 / 1)];
    [_imgView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"img_app_placeholder_default"]];
}

@end
