//
//  MyPhotoSheetView.m
//  QZSQ
//
//  Created by yedexiong20 on 2018/9/15.
//  Copyright © 2018年 XMZY. All rights reserved.
//

#import "MyPhotoSheetView.h"
#import "BSVerticalButton.h"
#import "UILabel+Extension.h"


#define KCELLHEIGHT 50
#define KViewMargin 15
#define KViewH 70
#define kPerLineItemCount 4 //每行个数

@interface MyPhotoSheetView ()

@property(nonatomic,strong)UIButton *clearBtn;

@property(nonatomic,strong)NSArray *titles;

@property(nonatomic,strong)NSArray *imgs;
/* 标题 */
@property (copy,nonatomic) NSString *title;
/* <#name#> */
@property (strong,nonatomic) UIView *btnView;
/* <#name#> */
@property (strong,nonatomic) UIView *lineV;
/* <#注释#> */
@property (assign,nonatomic) CGFloat btnViewH;
/* <#注释#> */
@property (assign,nonatomic) CGFloat viewH;

@end

@implementation MyPhotoSheetView

- (instancetype)initWithFrame:(CGRect)frame shareType:(NSInteger)type {
    if (self = [super initWithFrame:frame]) {
        [self configUIWithType:type];
    }
    return self;
}

- (void)configUIWithType:(NSInteger)type {
    self.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, MIScreenWidth, 40)];
    titleLab.text = @"分享至";
    titleLab.font = [UIFont systemFontOfSize:10];
    titleLab.textColor = UIColorFromRGBWithAlpha(0x666666, 1);
    titleLab.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLab];

    CGFloat wid = 50;
    CGFloat margin = (MIScreenWidth - 5 * wid) / 6.0;
    
    NSArray *fTitles = @[@"微信好友", @"朋友圈", @"微博", @"QQ", @"QQ空间"];
    NSArray *fImgs = @[@"icon_share_weixin_nor",  @"icon_share_friends_nor",@"icon_share_weibo_nor",@"icon_share_qq_nor",@"icon_share_space_nor"];
    
    for (NSInteger i = 0; i < fImgs.count; i++) {
        UIButton *fBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        fBtn.frame = CGRectMake(margin + (margin + wid) * i, 40, wid, 80);
        [fBtn setTitleColor:UIColorFromRGBWithAlpha(0x666666, 1) forState:UIControlStateNormal];
        [fBtn setTitle:fTitles[i] forState:UIControlStateNormal];
        [fBtn setImage:[UIImage imageNamed:fImgs[i]] forState:UIControlStateNormal];
        fBtn.titleLabel.font = [UIFont systemFontOfSize:10];
        [fBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [fBtn layoutButtonWithEdgeInsetsStyle:MIButtonEdgeInsetsStyleTop imageTitleSpace:10];
        [self addSubview:fBtn];
    }
    
    if (type == 1) {
        UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(0, 120, MIScreenWidth, 1)];
        lineV.backgroundColor = UIColorFromRGBWithAlpha(0xF2F3F5, 1);
        [self addSubview:lineV];
        
        NSArray *sTitles = @[@"举报", @"拉黑"];
        NSArray *sImgs = @[@"icon_share_report_nor", @"icon_share_black_nor"];
        
        for (NSInteger i = 0; i < sImgs.count; i++) {
            UIButton *sBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            sBtn.frame = CGRectMake(margin + (margin + wid) * i, 121, wid, 64);
            [sBtn setTitleColor:UIColorFromRGBWithAlpha(0x666666, 1) forState:UIControlStateNormal];
            [sBtn setTitle:sTitles[i] forState:UIControlStateNormal];
            [sBtn setImage:[UIImage imageNamed:sImgs[i]] forState:UIControlStateNormal];
            sBtn.titleLabel.font = [UIFont systemFontOfSize:10];
            [sBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
            [sBtn layoutButtonWithEdgeInsetsStyle:MIButtonEdgeInsetsStyleTop imageTitleSpace:5];
            [self addSubview:sBtn];
        }
    } else if (type == 2) {
        UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(0, 120, MIScreenWidth, 1)];
        lineV.backgroundColor = UIColorFromRGBWithAlpha(0xF2F3F5, 1);
        [self addSubview:lineV];
        
        NSArray *sTitles = @[@"复制链接", @"回到首页", @"举报"];
        NSArray *sImgs = @[@"icon_share_link_nor", @"icon_share_home_nor", @"icon_share_report_nor"];
        
        for (NSInteger i = 0; i < sImgs.count; i++) {
            UIButton *sBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            sBtn.frame = CGRectMake(margin + (margin + wid) * i, 121, wid, 64);
            [sBtn setTitleColor:UIColorFromRGBWithAlpha(0x666666, 1) forState:UIControlStateNormal];
            [sBtn setTitle:sTitles[i] forState:UIControlStateNormal];
            [sBtn setImage:[UIImage imageNamed:sImgs[i]] forState:UIControlStateNormal];
            sBtn.titleLabel.font = [UIFont systemFontOfSize:10];
            [sBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
            [sBtn layoutButtonWithEdgeInsetsStyle:MIButtonEdgeInsetsStyleTop imageTitleSpace:5];
            [self addSubview:sBtn];
        }
    }
    
    //取消按钮
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(0, self.height - 50, MIScreenWidth, 50);
    cancelBtn.backgroundColor = [UIColor whiteColor];
    [cancelBtn setTitleColor:UIColorFromRGBWithAlpha(0x333333, 1) forState:UIControlStateNormal];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [cancelBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelBtn];
    
    UIView *segView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 60, MIScreenWidth, 10)];
    segView.backgroundColor = UIColorFromRGBWithAlpha(0xF2F3F5, 1);
    [self addSubview:segView];
}

//- (instancetype)initWithFrame:(CGRect)frame
//{
//    if (self = [super initWithFrame:frame]) {
//
//        //取消按钮
//        UIButton *cancelBtn = [[UIButton alloc] init];
//        cancelBtn.backgroundColor = [UIColor whiteColor];
//        [cancelBtn setTitleColor:UIColorFromRGBWithAlpha(0x333333, 1) forState:UIControlStateNormal];
//        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
//        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
//        [cancelBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:cancelBtn];
//        [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.bottom.left.right.equalTo(self);
//            make.height.mas_equalTo(KCELLHEIGHT);
//        }];
//
//        UIView *lineV = [[UIView alloc] init];
//        lineV.backgroundColor = UIColorFromRGBWithAlpha(0xDDDDDD, 1);
//        [self addSubview:lineV];
//        [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.height.mas_equalTo(0.5);
//            make.left.right.equalTo(self);
//            make.bottom.equalTo(cancelBtn.mas_top);
//        }];
//        self.lineV = lineV;
//
//        UIView *btnView = [[UIView alloc] init];
//        btnView.backgroundColor = [UIColor whiteColor];
//        [self addSubview:btnView];
//        [btnView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.right.equalTo(self);
//            make.height.mas_equalTo(100);
//            make.bottom.equalTo(lineV.mas_top);
//        }];
//        self.btnView = btnView;
//    }
//    return self;
//}

//+(instancetype)shareViewWithTitles:(NSArray *)titles imgs:(NSArray *)imgs title:(NSString *)title {
//    MyPhotoSheetView *sheetView = [[MyPhotoSheetView alloc] initWithFrame:CGRectZero];
//
//    sheetView.imgs = imgs;
//    sheetView.titles = titles;
//    sheetView.title = title;
//
//    return sheetView;
//}
//
//- (void)setTitle:(NSString *)title {
//    _title = title;
//
//    if (title) {
//        UIView *seperator = [[UIView alloc] init];
//        seperator.backgroundColor = UIColorFromRGBWithAlpha(0xDDDDDD, 1);
//        [self addSubview:seperator];
//        [seperator mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.right.equalTo(self);
//            make.height.mas_equalTo(0.5);
//            make.bottom.mas_equalTo(self.btnView.mas_top);
//        }];
//
//        UILabel *titleLab = [UILabel labelWithTitle:title color:UIColorFromRGBWithAlpha(0x333333, 1) fontSize:14 alignment:NSTextAlignmentCenter];
//        titleLab.backgroundColor = [UIColor whiteColor];
//        titleLab.text = title;
//        [self addSubview:titleLab];
//        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.height.mas_equalTo(KCELLHEIGHT);
//            make.left.right.equalTo(self);
//            make.bottom.mas_equalTo(seperator.mas_top);
//        }];
//
//        self.viewH += KCELLHEIGHT;
//    }
//}
//
//- (void)setTitles:(NSArray *)titles {
//    _titles = titles;
//
//    CGFloat btnW = KViewH;
//    CGFloat btnH = KViewH;
//    CGFloat marginX = (MIScreenWidth - kPerLineItemCount * btnW) / (kPerLineItemCount+1);
//    CGFloat marginY = KViewMargin;
//    CGFloat btnX;
//    CGFloat btnY;
//    for (NSInteger index = 0; index < titles.count; index ++) {
//        //列
//        NSInteger clo = index % kPerLineItemCount;
//        //行
//        NSInteger row = index / kPerLineItemCount;
//
//        BSVerticalButton *btn = [[BSVerticalButton alloc] init];
//        btn.tag = index;
//
//        btnX = clo * (btnW + marginX) + marginX;
//        btnY = row * (btnH + marginY) + marginY;
//
//        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
//
//        [btn setImage:[UIImage imageNamed:self.imgs[index]] forState:UIControlStateNormal];
//        [btn setTitle:titles[index] forState:UIControlStateNormal];
//        [btn setTitleColor:UIColorFromRGBWithAlpha(0x666666, 1) forState:UIControlStateNormal];
//        btn.titleLabel.font = [UIFont systemFontOfSize:10];
//        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
//
//        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
//        [self.btnView addSubview:btn];
//
//        if (index == titles.count-1) {
//            self.btnViewH = (row+2)*marginY + (row+1)*btnH - 7;
//            self.viewH = (clo+1) * KViewMargin + self.btnViewH + KCELLHEIGHT;
//            [self.btnView mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.height.mas_equalTo(self.btnViewH);
//            }];
//        }
//    }
//
//}

//按钮的点击
- (void)btnAction:(UIButton *)btn {
    //如果是点击二维码按钮，则不要自动消失(需求如此)
    if (![btn.titleLabel.text isEqualToString:@"二维码"]) {
        [self dismiss];
    }
    
    if (self.SheetActionBlock) {
        self.SheetActionBlock(btn.titleLabel.text);
    }
}


-(void)showInView:(UIView*)view {

    self.frame = CGRectMake(0, MIScreenHeight, MIScreenWidth, self.viewH);
    
    self.clearBtn = [[UIButton alloc] initWithFrame:view.bounds];
    [self.clearBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    self.clearBtn.backgroundColor = [UIColorFromRGBWithAlpha(0x333333, 1) colorWithAlphaComponent:0.6];
    [view addSubview:self.clearBtn];
    [view addSubview:self];

    [UIView animateWithDuration:0.2 animations:^{
        self.y = MIScreenHeight - self.viewH;
        
    }];
}

-(void)show {

//    self.frame = CGRectMake(0, MIScreenHeight, MIScreenWidth, self.viewH);
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.clearBtn = [[UIButton alloc] initWithFrame:window.bounds];
    [self.clearBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    self.clearBtn.backgroundColor = [UIColorFromRGBWithAlpha(0x333333, 1) colorWithAlphaComponent:0.6];
    [window addSubview:self.clearBtn];
    [window addSubview:self];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.y = MIScreenHeight - self.height;
    }];
}

-(void)dismiss
{
    [UIView animateWithDuration:0.2 animations:^{
        self.y = MIScreenHeight;
        
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
        [self.clearBtn removeFromSuperview];
        
    }];
}




@end
