//
//  MIRecommendDetailCell.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/15.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIRecommendDetailCell.h"
#import "MITweetModel.h"
#import "UIImageView+WebCache.h"

@interface MIRecommendDetailCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *contentLab;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;

@end


@implementation MIRecommendDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(MITweetSectionModel *)model {
    if ([model.type isEqualToString:@"1"]) {
        _contentLab.hidden = NO;
        _imgView.hidden = YES;
        _playBtn.hidden = YES;
        
        _contentLab.text = model.content;
    } else {
        _contentLab.hidden = YES;
        _imgView.hidden = NO;
        if ([model.type isEqualToString:@"2"]) {
            _playBtn.hidden = YES;
        } else {
            _playBtn.hidden = NO;
        }
        
        NSString *url = [NSString stringWithFormat:@"%@?x-oss-process=image/resize,m_fill,h_%ld,w_%ld", model.content, (NSInteger)(_imgView.width / 1) , (NSInteger)(_imgView.height / 1)];
        [_imgView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil];
    }
}

- (IBAction)clickPlayBtn:(UIButton *)sender {
    
}

@end
