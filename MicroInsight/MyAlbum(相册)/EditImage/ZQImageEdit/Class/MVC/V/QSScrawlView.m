//
//  QSScrawlView.m
//  QSPS
//
//  Created by 舒雄威 on 2018/1/18.
//  Copyright © 2018年 舒雄威. All rights reserved.
//

#import "QSScrawlView.h"

@interface QSScrawlView ()

@property (strong, nonatomic) NSMutableArray *paths;

@end

@implementation QSScrawlView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    [[UIColor redColor] set];
    for (UIBezierPath *path in self.paths) {
        path.lineWidth = 2;
        [path stroke];
    }
}

#pragma mark - 懒加载
- (NSMutableArray *)paths {
    if (!_paths) {
        _paths = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _paths;
}

#pragma mark - 清屏
- (void)clear {
    [self.paths removeAllObjects];
    [self setNeedsDisplay];
}

#pragma mark - touch事件
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    CGPoint startPoint = [touches.anyObject locationInView:self];
    UIBezierPath *currenPath = [UIBezierPath bezierPath];
    currenPath.lineCapStyle = kCGLineCapRound;
    currenPath.lineJoinStyle = kCGLineJoinRound;
    [currenPath moveToPoint:startPoint];
    [self.paths addObject:currenPath];
    
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];

    CGPoint endPoint = [touches.anyObject locationInView:self];
    UIBezierPath *currentPath = [self.paths lastObject];
    [currentPath addLineToPoint:endPoint];
    
    [self setNeedsDisplay];
}

@end
