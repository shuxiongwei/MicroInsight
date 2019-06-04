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
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    _reportList = @[@"广告", @"标题夸张", @"低俗色情", @"错别字多", @"涉嫌违法犯罪"];
    
    _reportTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 350, self.bounds.size.width, 350) style:UITableViewStylePlain];
    _reportTableView.backgroundColor = UIColorFromRGBWithAlpha(0xCCCCCC, 1);
    _reportTableView.separatorColor = UIColorFromRGBWithAlpha(0x0000000, 0.6);
    _reportTableView.delegate = self;
    _reportTableView.dataSource = self;
    [_reportTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self addSubview:_reportTableView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
}

- (void)tap:(UIGestureRecognizer *)rec {
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
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *sectionLab = [MIUIFactory createLabelWithCenter:CGPointMake(MIScreenWidth / 2.0, 30) withBounds:CGRectMake(0, 0, MIScreenWidth, 50) withText:@"举报内容问题" withFont:18 withTextColor:[UIColor blackColor] withTextAlignment:NSTextAlignmentCenter];
    sectionLab.backgroundColor = [UIColor clearColor];
    
    return sectionLab;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = _reportList[indexPath.row];
    
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
