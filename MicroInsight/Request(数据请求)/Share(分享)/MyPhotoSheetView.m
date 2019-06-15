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

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {

        //取消按钮
        UIButton *cancelBtn = [[UIButton alloc] init];
        cancelBtn.backgroundColor = [UIColor whiteColor];
        [cancelBtn setTitleColor:UIColorFromRGBWithAlpha(0x333333, 1) forState:UIControlStateNormal];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [cancelBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelBtn];
        [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(self);
            make.height.mas_equalTo(KCELLHEIGHT);
        }];
        
        UIView *lineV = [[UIView alloc] init];
        lineV.backgroundColor = UIColorFromRGBWithAlpha(0xDDDDDD, 1);
        [self addSubview:lineV];
        [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0.5);
            make.left.right.equalTo(self);
            make.bottom.equalTo(cancelBtn.mas_top);
        }];
        self.lineV = lineV;

        UIView *btnView = [[UIView alloc] init];
        btnView.backgroundColor = [UIColor whiteColor];
        [self addSubview:btnView];
        [btnView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.height.mas_equalTo(100);
            make.bottom.equalTo(lineV.mas_top);
        }];
        self.btnView = btnView;
    }
    return self;
}

+(instancetype)shareViewWithTitles:(NSArray *)titles imgs:(NSArray *)imgs title:(NSString *)title {
    MyPhotoSheetView *sheetView = [[MyPhotoSheetView alloc] initWithFrame:CGRectZero];
    
    sheetView.imgs = imgs;
    sheetView.titles = titles;
    sheetView.title = title; 
    
    return sheetView;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    if (title) {
        UIView *seperator = [[UIView alloc] init];
        seperator.backgroundColor = UIColorFromRGBWithAlpha(0xDDDDDD, 1);
        [self addSubview:seperator];
        [seperator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.height.mas_equalTo(0.5);
            make.bottom.mas_equalTo(self.btnView.mas_top);
        }];
        
        UILabel *titleLab = [UILabel labelWithTitle:title color:UIColorFromRGBWithAlpha(0x333333, 1) fontSize:14 alignment:NSTextAlignmentCenter];
        titleLab.backgroundColor = [UIColor whiteColor];
        titleLab.text = title;
        [self addSubview:titleLab];
        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(KCELLHEIGHT);
            make.left.right.equalTo(self);
            make.bottom.mas_equalTo(seperator.mas_top);
        }];
        
        self.viewH += KCELLHEIGHT;
    }
}

- (void)setTitles:(NSArray *)titles {
    _titles = titles;
    
    CGFloat btnW = KViewH;
    CGFloat btnH = KViewH;
    CGFloat marginX = (MIScreenWidth - kPerLineItemCount * btnW) / (kPerLineItemCount+1);
    CGFloat marginY = KViewMargin;
    CGFloat btnX;
    CGFloat btnY;
    for (NSInteger index = 0; index < titles.count; index ++) {
        //列
        NSInteger clo = index % kPerLineItemCount;
        //行
        NSInteger row = index / kPerLineItemCount;
        
        BSVerticalButton *btn = [[BSVerticalButton alloc] init];
        btn.tag = index;
        
        btnX = clo * (btnW + marginX) + marginX;
        btnY = row * (btnH + marginY) + marginY;
        
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
    
        [btn setImage:[UIImage imageNamed:self.imgs[index]] forState:UIControlStateNormal];
        [btn setTitle:titles[index] forState:UIControlStateNormal];
        [btn setTitleColor:UIColorFromRGBWithAlpha(0x666666, 1) forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:10];
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnView addSubview:btn];
        
        if (index == titles.count-1) {
            self.btnViewH = (row+2)*marginY + (row+1)*btnH - 7;
            self.viewH = (clo+1) * KViewMargin + self.btnViewH + KCELLHEIGHT;
            [self.btnView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(self.btnViewH);
            }];
        }
    }
    
}

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

    self.frame = CGRectMake(0, MIScreenHeight, MIScreenWidth, self.viewH);
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.clearBtn = [[UIButton alloc] initWithFrame:window.bounds];
    [self.clearBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    self.clearBtn.backgroundColor = [UIColorFromRGBWithAlpha(0x333333, 1) colorWithAlphaComponent:0.6];
    [window addSubview:self.clearBtn];
    [window addSubview:self];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.y = MIScreenHeight - self.viewH;
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
