//
//  MICommentAlertView.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/7/17.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MICommentAlertView.h"

@implementation MICommentAlertView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _bgView.layer.cornerRadius = 3;
    _bgView.layer.masksToBounds = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:tap];
}

+ (instancetype)commentAlertView {
    return [[NSBundle mainBundle] loadNibNamed:@"MICommentAlertView" owner:nil options:nil].lastObject;
}

- (IBAction)clickCommentBtn:(UIButton *)sender {
    [self dismiss];
    if (self.alertType) {
        self.alertType(0);
    }
}

- (IBAction)clickReportBtn:(UIButton *)sender {
    [self dismiss];
    if (self.alertType) {
        self.alertType(1);
    }
}

- (IBAction)clickBlackBtn:(UIButton *)sender {
    [self dismiss];
    if (self.alertType) {
        self.alertType(2);
    }
}

- (void)tap:(UITapGestureRecognizer *)rec {
    [self dismiss];
}

- (void)dismiss {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    }];
}

@end
