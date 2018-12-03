//
//  GPResponseObjectParser.h
//  GoonPa
//
//  Created by Jonphy on 4/27/17.
//  Copyright © 2018 Jonphy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MIModelMapper : NSObject

+ (id)modelWithDictionary:(NSDictionary *)responseDictionary modelClass:(Class)cls;

+ (NSArray *)modelArrayWithJsonArray:(NSArray *)jsonArray modelClass:(Class)cls;

+ (NSDictionary *)modelDictionaryWithJsonDictionary:(NSDictionary *)jsonDictionary modelClass:(Class)cls;

@end
