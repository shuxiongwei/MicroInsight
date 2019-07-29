//
//  QSDatabase.h
//  QSPS
//
//  Created by 舒雄威 on 2018/1/3.
//  Copyright © 2018年 舒雄威. All rights reserved.
//

#import <Foundation/Foundation.h>

//所有表对象父类，提供了所有的数据管理方法
@interface QSDatabase : NSObject

/**
 保存某条数据，如果对象所在的表不存在，则创建表

 @return 返回保存成功与否
 */
- (BOOL)saveToDatabase;

/**
 删除数据对象，按主键rowid来删除

 @return 返回删除成功与否
 */
- (BOOL)deleteToDatabase;

/**
 获取查询的数据

 @param index 起始rowid,无需此条件则传0
 @param count 数量
 @param condition 查询条件，如：@“name='🐻多多'”;
 @param order 排序方式，如：@"creat_time desc"，"creat_time"是创建时间，"desc"是降序
 @return 返回查询到的模型数组
 */
+ (NSMutableArray *)searchToDatabaseFromIndex:(NSInteger)index count:(NSInteger)count condition:(id)condition orderBy:(NSString *)order;

/**
 更新数据对象，按主键rowid来更新

 @return 返回更新成功与否
 */
- (BOOL)updateToDatabase;

/**
 是否存在某条数据，按主键rowid来判断

 @return 返回存在与否
 */
- (BOOL)isExistToDatabase;

/**
 *  获取满足所给条件的数据条数
 *  @param condition 条件语句，如：@“name='🐻多多'”
 *  @return 返回数量
 */
- (NSInteger)rowCountWithCondition:(id)condition;

@end
