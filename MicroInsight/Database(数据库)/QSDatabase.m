//
//  QSDatabase.m
//  QSPS
//
//  Created by 舒雄威 on 2018/1/3.
//  Copyright © 2018年 舒雄威. All rights reserved.
//

#import "QSDatabase.h"


@implementation QSDatabase

- (BOOL)saveToDatabase {
    BOOL success = [self saveToDB];
    [self logHandleStatue:success selector:__FUNCTION__];
    return success;
}

- (BOOL)deleteToDatabase {
    BOOL success = [self deleteToDB];
    [self logHandleStatue:success selector:__FUNCTION__];
    return success;
}

+ (NSMutableArray *)searchToDatabaseFromIndex:(NSInteger)index count:(NSInteger)count condition:(NSString *)condition orderBy:(NSString *)order {
    NSMutableArray *array = [self searchWithWhere:condition orderBy:order offset:index count:count];
    return array;
}

- (BOOL)updateToDatabase {
    BOOL success = [self updateToDB];
    [self logHandleStatue:success selector:__FUNCTION__];
    return success;
}

- (BOOL)isExistToDatabase {
    BOOL exist = [self isExistsFromDB];
    [self logHandleStatue:exist selector:__FUNCTION__];
    return exist;
}

- (NSInteger)rowCountWithCondition:(id)condition {
    NSInteger count = [self.class rowCountWithWhere:condition];
    return count;
}

//打印成功与否的信息
- (void)logHandleStatue:(BOOL)result selector:(const char[])selector {
    if (result)
        NSLog(@"%@ %s handle success!",NSStringFromClass(self.class),selector);
    else
        NSLog(@"%@ %s handle failed!",NSStringFromClass(self.class),selector);
}

@end
