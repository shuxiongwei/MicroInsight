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
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView)];
    [_imgView addGestureRecognizer:tap];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(MITweetSectionModel *)model {
    _model = model;
    
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
            
            NSString *url = [NSString stringWithFormat:@"?x-oss-process=image/resize,m_fill,h_%ld,w_%ld", (NSInteger)self.imgView.size.height / 1, (NSInteger)self.imgView.size.width / 1];
            [_imgView sd_setImageWithURL:[NSURL URLWithString:[model.content stringByAppendingString:url]] placeholderImage:[UIImage imageNamed:@"img_app_placeholder_default"]];
        } else {
            _playBtn.hidden = NO;
            
            AVAsset *asset = [AVAsset assetWithURL:[NSURL URLWithString:_model.content]];
            _imgView.image = [MIHelpTool fetchThumbnailWithAVAsset:asset curTime:0];
        }
    }
}

- (IBAction)clickPlayBtn:(UIButton *)sender {
    if (self.clickPlayBtn) {
        self.clickPlayBtn(_model.content);
    }
}

- (void)tapImageView {
    if ([_model.type isEqualToString:@"2"]) {
        if (self.clickImageView) {
            self.clickImageView(_model.content);
        }
    }
}

@end
