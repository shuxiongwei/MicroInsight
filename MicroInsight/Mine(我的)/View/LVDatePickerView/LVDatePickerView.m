//
//  LVDatePickerView.m
//  TravelWithPetApp
//
//  Created by 吕亚斌 on 2018/4/10.
//  Copyright © 2018年 吕亚斌. All rights reserved.
//

#import "LVDatePickerView.h"
#import "NSDate+LVDatePicker.h"
#import "UIPickerView+LVPickerView.h"
#import "MicroInsight-Swift.h"

@interface LVDatePickerView () <UIPickerViewDelegate,UIPickerViewDataSource>

{
    // 时间数据源的数组中，选中元素的索引
    NSInteger _yearIndex;
    NSInteger _monthIndex;
    NSInteger _dayIndex;
    // 最小和最大限制时间、滚动到指定时间实体对象实例
    LVDatePickerModel *_datePickerDateMinLimited;
    LVDatePickerModel *_datePickerDateMaxLimited;
    LVDatePickerModel *_datePickerDateScrollTo;
}

@property (nonatomic, strong) UIView *bgView;

//picker
@property (nonatomic, strong) UIPickerView *yearPicker;
@property (nonatomic, strong) UIPickerView *monthPicker;
@property (nonatomic, strong) UIPickerView *dayPicker;
//数据源
@property (nonatomic, strong) NSMutableArray *yearArr;
@property (nonatomic, strong) NSMutableArray *monthArr;
@property (nonatomic, strong) NSMutableArray *dayArr;
//年 月 日
@property (nonatomic, strong) UILabel *yearLabel;
@property (nonatomic, strong) UILabel *monthLabel;
@property (nonatomic, strong) UILabel *dayLabel;
//其他
@property (nonatomic, strong) NSCalendar *calendar;//系统日历

@end

@implementation LVDatePickerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configUI];
        [self loadDataSouce];
    }
    return self;
}

- (void)configUI {
    self.backgroundColor = UIColorFromRGBWithAlpha(0x666666, 1);
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MIScreenWidth - 80, (MIScreenWidth - 80) * 340.0 / 295.0)];
    bgView.center = self.center;
    bgView.backgroundColor = [UIColor whiteColor];
    [bgView round:3 RectCorners:UIRectCornerAllCorners];
    [self addSubview:bgView];
    _bgView = bgView;
    
    UILabel *birthdayLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, bgView.width - 20, 16)];
    birthdayLab.text = @"请选择你的生日";
    birthdayLab.textColor = UIColorFromRGBWithAlpha(0x333333, 1);
    birthdayLab.font = [UIFont systemFontOfSize:16];
    birthdayLab.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:birthdayLab];
    
    UIButton *leftBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(0, bgView.height - 50, bgView.width / 2.0, 50) normalTitle:@"取消" normalTitleColor:UIColorFromRGBWithAlpha(0xBEBEBE, 1) highlightedTitleColor:nil selectedColor:nil titleFont:17 normalImage:nil highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(clickLeftBtn:)];
    leftBtn.backgroundColor = UIColorFromRGBWithAlpha(0xF9F9F9, 1);
    [bgView addSubview:leftBtn];
    
    UIButton *rightBtn = [MIUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(bgView.width / 2.0, bgView.height - 50, bgView.width / 2.0, 50) normalTitle:@"确定" normalTitleColor:UIColorFromRGBWithAlpha(0xFFFFFF, 1) highlightedTitleColor:nil selectedColor:nil titleFont:17 normalImage:nil highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(clickRightBtn:)];
    [rightBtn setButtonCustomBackgroudImageWithBtn:rightBtn fromColor:UIColorFromRGBWithAlpha(0x72B3E2, 1) toColor:UIColorFromRGBWithAlpha(0x6DD1CC, 1)];
    [bgView addSubview:rightBtn];
    
    [bgView addSubview:self.yearPicker];
    [bgView addSubview:self.monthPicker];
    [bgView addSubview:self.dayPicker];
    [bgView addSubview:self.yearLabel];
    [bgView addSubview:self.monthLabel];
    [bgView addSubview:self.dayLabel];
    
    [self.yearLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(bgView);
        make.left.equalTo(self.yearPicker.mas_right);
        make.right.equalTo(self.monthPicker.mas_left);
        make.width.equalTo(self.monthLabel);
    }];
    
    [self.monthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.monthPicker.mas_right);
        make.right.equalTo(self.dayPicker.mas_left);
        make.centerY.equalTo(bgView);
    }];
    
    [self.dayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-24);
        make.left.equalTo(self.dayPicker.mas_right);
        make.centerY.equalTo(bgView);
    }];
}

- (void)loadDataSouce {
    //最小显示时间
    if (!_minLimitedDate) {
        //现在时间前100
        _minLimitedDate = [self.calendar dateByAddingUnit:NSCalendarUnitYear value:-100 toDate:[NSDate date] options:NSCalendarWrapComponents];
    }
    //最大显示时间
    if (!_maxLimitedDate) {
        _maxLimitedDate = [self.calendar dateByAddingUnit:NSCalendarUnitYear value:100 toDate:[NSDate date] options:NSCalendarWrapComponents];
    }
    //（这里是判断 设置的最大和最小默认时间是否争取 是否比最小时间小 或者比最大时间大。看起来不可能,因为刚开始就是根据最小时间和最大时间来初始化数组的。但是有一种情况就是 使用者设置的时间最小时间 大于设置的最大时间。所以在初始化时间的时候应该比较一下设置的最小和最大时间）
    //第一种异常情况。最小时间大于最大时间  //换一下位置
    if ([_minLimitedDate compare:_maxLimitedDate] == NSOrderedDescending) {
        NSDate *tem = _maxLimitedDate;
        _maxLimitedDate = _minLimitedDate;
        _minLimitedDate = tem;
    }
    //最小选择时间
    if (!_defaultLimitedminDate) {
        //限制的最小时间
        _defaultLimitedminDate = _minLimitedDate;
    }
    //最大选择时间
    if (!_defailtLimitedMaxDate) {
        _defailtLimitedMaxDate = _maxLimitedDate;
    }
    //异常情况。最小时间大于最大时间  //换一下位置
    if ([_defaultLimitedminDate compare:_defailtLimitedMaxDate] == NSOrderedDescending) {
        NSDate *tem = _defailtLimitedMaxDate;
        _defailtLimitedMaxDate = _defaultLimitedminDate;
        _defaultLimitedminDate = tem;
    }
    //异常2 限制最小时间 小于显示最小时间
    if ([_defaultLimitedminDate compare:_minLimitedDate] == NSOrderedAscending) {
        _defaultLimitedminDate = _minLimitedDate;
    }
    //同理
    if ([_defailtLimitedMaxDate compare:_maxLimitedDate] == NSOrderedDescending) {
        _defailtLimitedMaxDate = _maxLimitedDate;
    }
    //设置 可选择的时间区域
    _datePickerDateMinLimited = [[LVDatePickerModel alloc] initWithLVDate:_defaultLimitedminDate];
    
    _datePickerDateMaxLimited = [[LVDatePickerModel alloc] initWithLVDate:_defailtLimitedMaxDate];
    
    //异常情况 默认时间 如果是使用自定义时间小于最小限制时间，这时就以最小限制时间为准；如果是使用自定义时间大于最大限制时间，这时就以最大限制时间为准
    // 滚动到指定时间；默认值为当前时间。
    if (!_scrollToDate) {
        _scrollToDate = [LVDateHelper fetchLocalDate];
    }
    //可以等于限制的时间
    if ([_scrollToDate compare:_defaultLimitedminDate] != NSOrderedDescending) {
        _scrollToDate = _defaultLimitedminDate;
    } else if ([_scrollToDate compare:_defailtLimitedMaxDate] != NSOrderedAscending) {
        _scrollToDate = _defailtLimitedMaxDate;
    }
    //滚动到指定时间
    _datePickerDateScrollTo = [[LVDatePickerModel alloc] initWithLVDate:_scrollToDate];
    // 初始化存储时间数据源的数组
    //年
    if (self.yearArr.count > 0) {
        [self.yearArr removeAllObjects];
    }
    LVDatePickerModel *minModel = [[LVDatePickerModel alloc] initWithLVDate:_minLimitedDate];
    LVDatePickerModel *maxModel = [[LVDatePickerModel alloc] initWithLVDate:_maxLimitedDate];
    for (NSInteger beginVal=[minModel.year integerValue], endVal=[maxModel.year integerValue]; beginVal<=endVal; beginVal++) {
        [self.yearArr addObject:[NSString stringWithFormat:@"%ld", (long)beginVal]];
    }
    //当前指定时间年的索引
    _yearIndex = [_datePickerDateScrollTo.year integerValue] - [_datePickerDateMinLimited.year integerValue];
    // 月
    if (self.monthArr.count > 0) {
        [self.monthArr removeAllObjects];
    }
    for (NSInteger i=1; i<=12; i++) {
        [self.monthArr addObject:[NSString stringWithFormat:@"%02ld", (long)i]];
    }
    //当前指定时间月份的索引
    _monthIndex = [_datePickerDateScrollTo.month integerValue] - 1;
    // 日
    [self reloadDayArray];
    _dayIndex = [_datePickerDateScrollTo.day integerValue] - 1;
    //滚动到选择的时间
    [self.yearPicker selectRow:_yearIndex inComponent:0 animated:YES];
    [self.monthPicker selectRow:_monthIndex inComponent:0 animated:YES];
    [self.dayPicker selectRow:_dayIndex inComponent:0 animated:YES];
}

//更新每月的日期 每月的天数不一样
- (void)reloadDayArray {
    if (self.dayArr.count > 0) {
        [self.dayArr removeAllObjects];
    }
    //获取到当年当月天数
    for (NSUInteger i=1, len=[self fetchDaysOfMonth]; i<=len; i++) {
        [self.dayArr addObject:[NSString stringWithFormat:@"%02ld", (long)i]];
    }
    
    [self.dayPicker reloadAllComponents];
    //这里需要更改一下天数的索引 eg 以前是3月最后一天 索引30 现在到2月 索引取2月的最后一天的 比如是 27
    while (self.dayArr.count-1 < _dayIndex) {
        _dayIndex = self.dayArr.count-1;
    }
    //刷新picker
    [self.dayPicker selectRow:_dayIndex inComponent:0 animated:YES];
}

//获取到当年当月天数
- (NSUInteger)fetchDaysOfMonth {
    NSString *dateStr = [NSString stringWithFormat:@"%@-%@-01", self.yearArr[_yearIndex], self.monthArr[_monthIndex]];
    return [[LVDateHelper fetchDateFromString:dateStr withFormat:@"yyyy-MM-dd"] fetchDaysOfMonth];
}

//（这里是判断 选择的时间 是否比最小时间小 或者比最大时间大。看起来不可能,因为刚开始就是根据最小时间和最大时间来初始化数组的。但是有一种情况就是 使用者设置的时间最小时间 大于设置的最大时间。所以在初始化时间的时候应该比较一下设置的最小和最大时间）
- (BOOL)validatedDate:(NSDate *)date {
    NSString *minDateStr = [NSString stringWithFormat:@"%@-%@-%@",
                            _datePickerDateMinLimited.year,
                            _datePickerDateMinLimited.month,
                            _datePickerDateMinLimited.day];
    
    return !([date compare:[LVDateHelper fetchDateFromString:minDateStr withFormat:@"yyyy-MM-dd"]] == NSOrderedAscending ||
             [date compare:_maxLimitedDate] == NSOrderedDescending);
}

//滑动到默认时间
- (void)scrollToDateIndexPositionWithDate:(NSDate *)date {
    _scrollToDate = date;
    _datePickerDateScrollTo = [[LVDatePickerModel alloc] initWithLVDate:_scrollToDate];
    _yearIndex = [_datePickerDateScrollTo.year integerValue] - [_datePickerDateMinLimited.year integerValue];
    _monthIndex = [_datePickerDateScrollTo.month integerValue] - 1;
    _dayIndex = [_datePickerDateScrollTo.day integerValue] - 1;
    //    [self scrollToDateIndexPosition];
    //滚动
    [self.yearPicker selectRow:_yearIndex inComponent:0 animated:YES];
    [self.monthPicker selectRow:_monthIndex inComponent:0 animated:YES];
    [self.dayPicker selectRow:_dayIndex inComponent:0 animated:YES];
    if (self.timeBlock) {
        self.timeBlock(_datePickerDateScrollTo);
    }
}

- (void)clickLeftBtn:(UIButton *)sender {
    [self removeFromSuperview];
}

- (void)clickRightBtn:(UIButton *)sender {
    [self removeFromSuperview];
    
    NSString *dateStr = [NSString stringWithFormat:@"%@-%@-%@",
                         self.yearArr[_yearIndex],
                         self.monthArr[_monthIndex],
                         self.dayArr[_dayIndex]];
    if (self.confimAction) {
        self.confimAction(dateStr);
    }
}

#pragma mark --UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (pickerView == self.yearPicker) {
        return self.yearArr.count;
    }
    if (pickerView == self.monthPicker) {
        return self.monthArr.count;
    }
    return self.dayArr.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    [pickerView clearSpearatorLine];
    
    UILabel *lblCustom = (UILabel *)view;
    if (!lblCustom) {
        lblCustom = [UILabel new];
        lblCustom.textColor = UIColorFromRGBWithAlpha(0xC1C1C1, 1);
        lblCustom.font = [UIFont systemFontOfSize:16.0];
    }
    if (pickerView == self.yearPicker) {
        lblCustom.text = self.yearArr[row];
        lblCustom.textAlignment = NSTextAlignmentRight;
        
        if (_yearIndex == row) {
            lblCustom.textColor = UIColorFromRGBWithAlpha(0x333333, 1);
            lblCustom.font = [UIFont systemFontOfSize:18.0];
        }
    }
    else if (pickerView == self.monthPicker){
        lblCustom.text = self.monthArr[row];
        lblCustom.textAlignment = NSTextAlignmentCenter;
        
        if (_monthIndex == row) {
            lblCustom.textColor = UIColorFromRGBWithAlpha(0x333333, 1);
            lblCustom.font = [UIFont systemFontOfSize:18.0];
        }
    }
    else{
        lblCustom.text = self.dayArr[row];
        lblCustom.textAlignment = NSTextAlignmentLeft;
        
        if (_dayIndex == row) {
            lblCustom.textColor = UIColorFromRGBWithAlpha(0x333333, 1);
            lblCustom.font = [UIFont systemFontOfSize:18.0];
        }
    }
//    [pickerView setDefaultsSpearatorLine];
    return lblCustom;
}

#pragma mark --UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 30;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (pickerView == self.yearPicker) {
        _yearIndex = row;
        //这里要调用reloadDayArray 是因为年变了 天数可能会变
        [self reloadDayArray];
    }
    if (pickerView == self.monthPicker) {
        _monthIndex = row;
        //同理
        [self reloadDayArray];
    }
    if (pickerView == self.dayPicker) {
        _dayIndex = row;
    }
    
    UILabel *lab = (UILabel *)[pickerView viewForRow:row forComponent:0];
    lab.textColor = UIColorFromRGBWithAlpha(0x333333, 1);
    lab.font = [UIFont systemFontOfSize:18.0];
    
    NSString *dateStr = [NSString stringWithFormat:@"%@-%@-%@",
                         self.yearArr[_yearIndex],
                         self.monthArr[_monthIndex],
                         self.dayArr[_dayIndex]];
    _scrollToDate = [LVDateHelper fetchDateFromString:dateStr withFormat:@"yyyy-MM-dd"];
    _datePickerDateScrollTo = [[LVDatePickerModel alloc] initWithLVDate:_scrollToDate];
    //如果当前选择的时间大于限制时间。滚回到最大限制时间 重新选择时间
    if ([_scrollToDate compare:_defailtLimitedMaxDate] == NSOrderedDescending) {
        _scrollToDate = _defailtLimitedMaxDate;
        [self scrollToDateIndexPositionWithDate:_scrollToDate];
        return;
    }
    //如果当前选择的时间小于限制时间。滚回到最小限制时间 重新选择时间
    if ([_scrollToDate compare:_defaultLimitedminDate] == NSOrderedAscending) {
        _scrollToDate = _defaultLimitedminDate;
        [self scrollToDateIndexPositionWithDate:_scrollToDate];
        return;
    }
    if (self.timeBlock) {
        self.timeBlock(_datePickerDateScrollTo);
    }
}

#pragma mark - 懒加载
- (UIPickerView *)yearPicker {
    if (!_yearPicker) {
        _yearPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(45, 111, 45, _bgView.height - 222)];
        _yearPicker.delegate = self;
        _yearPicker.dataSource = self;
    }
    return _yearPicker;
}

- (UIPickerView *)monthPicker {
    if (!_monthPicker) {
        _monthPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 111, 25, _bgView.height - 222)];
        _monthPicker.centerX = _bgView.width / 2.0;
        _monthPicker.delegate = self;
        _monthPicker.dataSource = self;
    }
    return _monthPicker;
}

- (UIPickerView *)dayPicker {
    if (!_dayPicker) {
        _dayPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(_bgView.width - 61 - 25, 111, 25, _bgView.height - 222)];
        _dayPicker.delegate = self;
        _dayPicker.dataSource = self;
    }
    return _dayPicker;
}

- (UILabel *)yearLabel {
    if (!_yearLabel) {
        _yearLabel = [[UILabel alloc] init];
        _yearLabel.text = @"年";
        _yearLabel.textColor = UIColorFromRGBWithAlpha(0xFF980D, 1);
        _yearLabel.font = [UIFont systemFontOfSize:15.0f];
        _yearLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _yearLabel;
}

- (UILabel *)monthLabel {
    if (!_monthLabel) {
        _monthLabel = [[UILabel alloc] init];
        _monthLabel.text = @"月";
        _monthLabel.textColor = UIColorFromRGBWithAlpha(0xFF980D, 1);
        _monthLabel.font = [UIFont systemFontOfSize:15.0f];
        _monthLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _monthLabel;
}

- (UILabel *)dayLabel {
    if (!_dayLabel) {
        _dayLabel = [[UILabel alloc] init];
        _dayLabel.text = @"日";
        _dayLabel.textColor = UIColorFromRGBWithAlpha(0xFF980D, 1);
        _dayLabel.font = [UIFont systemFontOfSize:15.0f];
        _dayLabel.textAlignment = NSTextAlignmentRight;
    }
    return _dayLabel;
}

- (NSMutableArray *)yearArr {
    if (!_yearArr) {
        _yearArr = [[NSMutableArray alloc] init];
    }
    return _yearArr;
}

- (NSMutableArray *)monthArr {
    if (!_monthArr) {
        _monthArr = [[NSMutableArray alloc] init];
    }
    return _monthArr;
}

- (NSMutableArray *)dayArr {
    if (!_dayArr) {
        _dayArr = [[NSMutableArray alloc] init];
    }
    return _dayArr;
}

- (NSCalendar *)calendar {
    if (!_calendar) {
        _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    }
    return _calendar;
}

@end
