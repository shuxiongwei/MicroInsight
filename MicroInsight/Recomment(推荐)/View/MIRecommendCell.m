//
//  MIRecommendCell.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/8.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIRecommendCell.h"
#import "MIRecommendListModel.h"
#import "UIImageView+WebCache.h"
#import "YYText.h"

@interface MIRecommendCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UIButton *browseBtn;
@property (weak, nonatomic) IBOutlet UILabel *contentLab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;

@end


@implementation MIRecommendCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setCellWithModel:(MIRecommendListModel *)model {
    _contentLab.text = model.title;
    [_browseBtn setTitle:[NSString stringWithFormat:@"%ld", model.readings] forState:UIControlStateNormal];
    
    NSArray *strs = [model.createdAt componentsSeparatedByString:@" "];
    _timeLab.text = strs.firstObject;
    
    //等比缩放，限定在矩形框外
    NSString *imgUrl = [NSString stringWithFormat:@"%@?x-oss-process=image/resize,m_fill,h_%ld,w_%ld", model.content, (NSInteger)_imgView.size.width / 1, (NSInteger)_imgView.size.width / 1];
    [_imgView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"account"] options:SDWebImageRetryFailed];
    
    YYTextLayout *layout = [model getContentHeightWithStr:model.title width:self.width - 176 font:15 lineSpace:5 maxRow:2];
    _heightConstraint.constant = layout.textBoundingSize.height;
}

@end
