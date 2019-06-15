//
//  MICommunityDetailTopView.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/8.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MICommunityDetailTopView.h"
#import "YYText.h"
#import "MICommunityListModel.h"
#import "MICommunityVideoInfo.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"

@interface MICommunityDetailTopView ()

@property (weak, nonatomic) IBOutlet UIButton *headIconBtn;
@property (weak, nonatomic) IBOutlet UIImageView *recommendV;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLab;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UIButton *readingBtn;
@property (weak, nonatomic) IBOutlet UILabel *tagLab;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageV;
@property (weak, nonatomic) IBOutlet YYLabel *contentLab;
@property (weak, nonatomic) IBOutlet UIImageView *playImageV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;

@end


@implementation MICommunityDetailTopView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
        self = nibs[0];
        self.frame = frame;
        [self configUI];
    }
    
    return self;
}

- (void)configUI {
    [_headIconBtn round:20 RectCorners:UIRectCornerAllCorners];
    [_tagLab rounded:5 width:1 color:UIColorFromRGBWithAlpha(0x999999, 1)];
    [_readingBtn layoutButtonWithEdgeInsetsStyle:MIButtonEdgeInsetsStyleLeft imageTitleSpace:5];
}

- (IBAction)clickHeadIconBtn:(UIButton *)sender {
    if (self.clickUserIcon) {
        if ([_model isKindOfClass:[MICommunityDetailModel class]]) {
            MICommunityDetailModel *model = (MICommunityDetailModel *)_model;
            self.clickUserIcon(model.userId);
        } else {
            MICommunityVideoInfo *model = (MICommunityVideoInfo *)_model;
            self.clickUserIcon([model.userId integerValue]);
        }
        
    }
}

- (void)setModel:(id)model {
    _model = model;
    
    if ([model isKindOfClass:[MICommunityDetailModel class]]) {
        MICommunityDetailModel *detailM = model;
        _nicknameLab.text = detailM.nickname;
        NSArray *strs = [detailM.createdAt componentsSeparatedByString:@" "];
        _timeLab.text = strs.firstObject;
        _contentLab.text = detailM.title;
        [_readingBtn setTitle:[NSString stringWithFormat:@"%ld", detailM.readings] forState:UIControlStateNormal];
        _playImageV.hidden = YES;
        
        if (detailM.tags.count > 0) {
            _tagLab.hidden = NO;
            MICommunityTagModel *tagM = detailM.tags.firstObject;
            _tagLab.text = tagM.title;
            _widthConstraint.constant = [MIHelpTool measureSingleLineStringWidthWithString:tagM.title font:[UIFont systemFontOfSize:8]] + 10;
        } else {
            _tagLab.hidden = YES;
        }
        
        NSString *imgUrl = [NSString stringWithFormat:@"%@?x-oss-process=image/resize,m_fill,h_40,w_40", detailM.avatar];
        [_headIconBtn sd_setImageWithURL:[NSURL URLWithString:imgUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"icon_personal_head_nor"]];
        
        [_contentImageV sd_setImageWithURL:[NSURL URLWithString:detailM.url] placeholderImage:nil];
    } else {
        MICommunityVideoInfo *info = model;
        _nicknameLab.text = info.nickname;
        NSArray *strs = [info.createdAt componentsSeparatedByString:@" "];
        _timeLab.text = strs.firstObject;
        MIVideoTag *tagM = info.tags.firstObject;
        _tagLab.text = tagM.title;
        _contentLab.text = info.title;
        [_readingBtn setTitle:[NSString stringWithFormat:@"%ld", info.readings] forState:UIControlStateNormal];
        _playImageV.hidden = NO;
        _widthConstraint.constant = [MIHelpTool measureSingleLineStringWidthWithString:tagM.title font:[UIFont systemFontOfSize:8]] + 10;
        
        NSString *imgUrl = [NSString stringWithFormat:@"%@?x-oss-process=image/resize,m_fill,h_40,w_40", info.avatar];
        [_headIconBtn sd_setImageWithURL:[NSURL URLWithString:imgUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"icon_personal_head_nor"]];
        
        [_contentImageV sd_setImageWithURL:[NSURL URLWithString:info.coverUrl] placeholderImage:nil];
    }
}

@end
