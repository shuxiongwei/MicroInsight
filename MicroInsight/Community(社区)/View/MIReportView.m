//
//  MIReportView.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/1/10.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIReportView.h"

@interface MIReportView () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSArray *reportList;
@property (nonatomic, strong) UITableView *reportTableView;

@end

@implementation MIReportView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configReportUI];
    }
    
    return self;
}

- (void)configReportUI {
    self.backgroundColor = [UIColorFromRGBWithAlpha(0x666666, 1) colorWithAlphaComponent:0.8];
    _reportList = @[[MILocalData appLanguage:@"community_key_18"],
                    [MILocalData appLanguage:@"community_key_19"],
                    [MILocalData appLanguage:@"community_key_20"],
                    [MILocalData appLanguage:@"community_key_21"],
                    [MILocalData appLanguage:@"community_key_22"]];
    
    _reportTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.height - 287, self.width, 227) style:UITableViewStylePlain];
    _reportTableView.backgroundColor = UIColorFromRGBWithAlpha(0xCCCCCC, 1);
    _reportTableView.separatorColor = UIColorFromRGBWithAlpha(0x0000000, 0.6);
    _reportTableView.delegate = self;
    _reportTableView.dataSource = self;
    _reportTableView.scrollEnabled = NO;
    _reportTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_reportTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self addSubview:_reportTableView];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(0, self.height - 50, MIScreenWidth, 50);
    cancelBtn.backgroundColor = [UIColor whiteColor];
    [cancelBtn setTitleColor:UIColorFromRGBWithAlpha(0x333333, 1) forState:UIControlStateNormal];
    [cancelBtn setTitle:[MILocalData appLanguage:@"personal_key_13"] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [cancelBtn addTarget:self action:@selector(clickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelBtn];
    
    UIView *segView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 60, MIScreenWidth, 10)];
    segView.backgroundColor = UIColorFromRGBWithAlpha(0xF2F3F5, 1);
    [self addSubview:segView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
}

- (void)tap:(UIGestureRecognizer *)rec {
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height);
    }];
}

- (void)clickCancelBtn {
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height);
    }];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {

    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]){
        return NO;
    }

    return YES;
}

#pragma mark - UITableViewDataSource
//设置分割线距tableview左右的距离
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 20, 0, 20)];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 20, 0, 20)];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _reportList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 37;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 38;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *sectionLab = [MIUIFactory createLabelWithCenter:CGPointMake(MIScreenWidth / 2.0, 18.5) withBounds:CGRectMake(0, 0, MIScreenWidth, 37) withText:[MILocalData appLanguage:@"community_key_17"] withFont:11 withTextColor:[UIColor blackColor] withTextAlignment:NSTextAlignmentCenter];
    sectionLab.backgroundColor = [UIColor whiteColor];
    
    return sectionLab;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = _reportList[indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.textLabel.textColor = UIColorFromRGBWithAlpha(0x333333, 1);
    
    UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.width, 1)];
    lineV.backgroundColor = UIColorFromRGBWithAlpha(0xF2F3F5, 1);
    [cell addSubview:lineV];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *text = _reportList[indexPath.row];
    if (_selectReportContent) {
        _selectReportContent(text);
        
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height);
        }];
    }
}

@end
