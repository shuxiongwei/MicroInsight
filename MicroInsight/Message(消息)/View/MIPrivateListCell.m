//
//  MIPrivateListCell.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/7/10.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIPrivateListCell.h"
#import "MILetterListModel.h"
#import "YYText.h"
#import "NSDate+Extension.h"

@interface MIPrivateListCell ()

@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) YYLabel     *messageLabel;
@property (nonatomic, strong) UILabel     *timeLabel;
@property (nonatomic, strong) UIImageView *imageImageView;
@property (nonatomic, strong) MILetterListModel *letterModel;
@property (nonatomic, strong) UIView *leftPointView;
@property (nonatomic, strong) UIView *rightPointView;

@end

@implementation MIPrivateListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (instancetype)cellWithTableView:(UITableView *)tableView
                      letterModel:(MILetterListModel *)model {
    
    static NSString *identifier = @"letterListCell";
    MIPrivateListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[MIPrivateListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.letterModel = model;
    
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle=UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        [self createLeftPointView];
        [self createRightPointView];
        [self creatSubViewTime];
        [self creatSubViewLogo];
        [self creatSubViewMessage];
        [self creatSubViewImage];
    }
    return self;
}

#pragma mark - 创建子视图
- (void)creatSubViewMessage {
    _messageLabel = [[YYLabel alloc] init];
    [self.contentView addSubview:_messageLabel];
    _messageLabel.numberOfLines = 0;
    _messageLabel.lineBreakMode=NSLineBreakByWordWrapping;
    _messageLabel.font = [UIFont systemFontOfSize:12];
    _messageLabel.layer.cornerRadius = 2;
    _messageLabel.layer.masksToBounds = YES;
    _messageLabel.textVerticalAlignment = YYTextVerticalAlignmentCenter;
}

- (void)createLeftPointView {
    _leftPointView = [[UIView alloc] init];
    [self.contentView addSubview:_leftPointView];
}

- (void)createRightPointView {
    _rightPointView = [[UIView alloc] init];
    [self.contentView addSubview:_rightPointView];
}

- (void)creatSubViewTime {
    _timeLabel = [[UILabel alloc] init];
    [self.contentView addSubview:_timeLabel];
    _timeLabel.font = [UIFont systemFontOfSize:9];
    _timeLabel.textColor = UIColorFromRGBWithAlpha(0x999999, 1);
    _timeLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)creatSubViewLogo {
    _logoImageView = [[UIImageView alloc] init];
    _logoImageView.layer.cornerRadius = 20;
    _logoImageView.layer.masksToBounds = YES;
    [self.contentView addSubview:_logoImageView];
}

- (void)creatSubViewImage {
    _imageImageView = [[UIImageView alloc] init];
    _imageImageView.layer.cornerRadius = 5;
    _imageImageView.layer.masksToBounds = YES;
    _imageImageView.userInteractionEnabled = YES;
    [self.contentView addSubview:_imageImageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImageView)];
    [_imageImageView addGestureRecognizer:tap];
}

- (UIBezierPath *)drawBottomAngleView {
    CGRect rect = [_letterModel pointFrame];
    CGPoint leftPoint;
    CGPoint rightPoint;
    CGPoint bottomPoint;

    if (_letterModel.isSelf) {
        leftPoint = CGPointMake(rect.size.width, rect.size.height / 2.0);
        rightPoint = CGPointMake(0, 0);
        bottomPoint = CGPointMake(0, rect.size.height);
    } else {
        leftPoint = CGPointMake(0, rect.size.height / 2.0);
        rightPoint = CGPointMake(rect.size.width, 0);
        bottomPoint = CGPointMake(rect.size.width, rect.size.height);
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:leftPoint];
    [path addLineToPoint:bottomPoint];
    [path addLineToPoint:rightPoint];
    
    return path;
}

- (void)setLetterModel:(MILetterListModel *)letterModel {
    _letterModel = letterModel;
    
    _leftPointView.hidden = YES;
    _rightPointView.hidden = YES;
    if (letterModel.isSelf && [letterModel.type isEqualToString:@"3"]) {
        _rightPointView.frame = [letterModel pointFrame];
        UIBezierPath *path = [self drawBottomAngleView];
        [_rightPointView.layer addSublayer:[MIUIFactory createShapeLayerWithPath:path.CGPath strokeColor:nil fillColor:UIColorFromRGBWithAlpha(0x49A2D8, 1).CGColor lineWidth:0]];
        _rightPointView.hidden = NO;
    }
    
    if (!letterModel.isSelf && [letterModel.type isEqualToString:@"3"]) {
        _leftPointView.frame = [letterModel pointFrame];
        UIBezierPath *path = [self drawBottomAngleView];
        [_leftPointView.layer addSublayer:[MIUIFactory createShapeLayerWithPath:path.CGPath strokeColor:nil fillColor:UIColorFromRGBWithAlpha(0xFFFFFF, 1).CGColor lineWidth:0]];
        _leftPointView.hidden = NO;
    }
    
    _logoImageView.frame = [letterModel logoFrame];
    [_logoImageView sd_setImageWithURL:[NSURL URLWithString:letterModel.avatar] placeholderImage:[UIImage imageNamed:@"icon_personal_head_nor"] options:SDWebImageRetryFailed];
    
    _timeLabel.frame = [letterModel timeFrame];
    NSDate *date = [NSDate date:letterModel.created_at WithFormat:@"yyyy-MM-dd HH:mm:ss"];
    _timeLabel.text = [self formattedDateDescription:date];
    if (letterModel.isSelf) {
        _timeLabel.textAlignment = NSTextAlignmentRight;
    } else {
        _timeLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    if ([letterModel.type isEqualToString:@"3"]) {
        UIColor *color;
        if (letterModel.isSelf) {
            _messageLabel.backgroundColor = UIColorFromRGBWithAlpha(0x49A2D8, 1);
            color = [UIColor whiteColor];
        } else {
            _messageLabel.backgroundColor = [UIColor whiteColor];
            color = UIColorFromRGBWithAlpha(0x333333, 1);
        }
        
        NSMutableAttributedString *introText = [[NSMutableAttributedString alloc] initWithString:letterModel.content];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        [paragraphStyle setLineSpacing:5];
        paragraphStyle.headIndent = 5;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
        paragraphStyle.firstLineHeadIndent = 5;
        [introText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, letterModel.content.length)];
        [introText addAttribute:NSForegroundColorAttributeName
                          value:color
                          range:NSMakeRange(0, letterModel.content.length)];
        
        _messageLabel.frame = letterModel.messageFrame;
        _messageLabel.attributedText = introText;
        _imageImageView.frame = letterModel.imageFrame;
        _imageImageView.image = nil;
    } else {
        _messageLabel.frame = letterModel.messageFrame;
        _messageLabel.text = nil;
        _imageImageView.frame = letterModel.imageFrame;
        _imageImageView.image = letterModel.image;
    }
}

- (NSString *)formattedDateDescription:(NSDate *)newsDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *theDay = [dateFormatter stringFromDate:newsDate];//日期的年月日
    NSString *currentDay = [dateFormatter stringFromDate:[NSDate date]];//当前年月日
    
    NSInteger timeInterval = -[newsDate timeIntervalSinceNow];
    if (newsDate.isThisYear) { //今年
        if (timeInterval < 60) {
            return @"刚刚";
        } else if (timeInterval < 3600) {//1小时内
            return [NSString stringWithFormat:@"%ld分钟前", timeInterval / 60];
        }else if ([theDay isEqualToString:currentDay]) {//当天
            return [NSString stringWithFormat:@"%ld小时前", timeInterval / 3600];
        }else {//以前
            [dateFormatter setDateFormat:@"MM月dd日"];
            return [dateFormatter stringFromDate:newsDate];
        }
    } else { //非今年
        dateFormatter.dateFormat = @"yyyy年MM月dd日";
        return [dateFormatter stringFromDate:newsDate];
    }
}

- (void)clickImageView {
    if (self.tapImageView) {
        self.tapImageView(_letterModel.content);
    }
}

@end
