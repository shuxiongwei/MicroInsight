//
//  MICommunityListModel.m
//  MicroInsight
//
//  Created by 舒雄威 on 2018/12/4.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "MICommunityListModel.h"
#import "YYText.h"

@implementation MICommunityTagModel

@end


@implementation MICommunityListModel

+ (NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{@"tags" : [MICommunityTagModel class]};
}

@end


@implementation MICommunityDetailModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"contentId" : @"id"};
}

+ (NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{@"tags" : [MICommunityTagModel class]};
}

@end


@implementation MICommunityCommentModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"contentId" : @"id"};
}

@end


@implementation MIChildCommentModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"modelId" : @"id"};
}

@end


@implementation MICommentModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"modelId" : @"id"};
}

+ (NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{@"child" : [MIChildCommentModel class]};
}

- (CGFloat)getRowHeight {
    
    CGFloat otherHeight = 63 + 15 + 20;
    CGFloat tableViewHeight = [self getChildCommentTableViewHeight];
    YYTextLayout *layout = [self getContentHeightWithStr:_content width:MIScreenWidth - 95 font:12 lineSpace:5 maxRow:3];

    return otherHeight + tableViewHeight + layout.textBoundingSize.height + 5;
}

- (CGFloat)getChildCommentTableViewHeight {
    if (self.childCount == 0) {
        return 0;
    } else {
        NSInteger line = 0;
        if (self.childCount < 4) {
            line = self.childCount;
        } else {
            line = 3;
        }
        
        return 22 * line;
    }
}

@end


@implementation MIPraiseModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"modelId" : @"id"};
}

@end
