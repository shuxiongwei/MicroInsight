//
//  MIMessageListModel.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/12.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIMessageListModel.h"
#import "MILetterListModel.h"

@implementation MIMessageListModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"modelId" : @"id"};
}

+ (NSInteger)getNotReadMessageCount {
    NSString *sql = [NSString stringWithFormat:@"status == 0"];
    NSUInteger count = [MIMessageListModel rowCountWithWhere:sql];
//    NSArray *list = [MILetterListModel searchToDatabaseFromIndex:0 count:count condition:sql orderBy:nil];
//
//    NSUInteger letterCount = [MILetterListModel rowCountWithWhere:nil];
//    NSArray *letterList = [MILetterListModel searchToDatabaseFromIndex:0 count:letterCount condition:nil orderBy:nil];
//
//    for (MIMessageListModel *model in list) {
//        for (MILetterListModel *mod in letterList) {
//            if ([mod.modelId integerValue] == model.modelId) {
//                count -= 1;
//            }
//        }
//    }
    
    return count;
}

@end


@implementation MIMessageModel

@end
