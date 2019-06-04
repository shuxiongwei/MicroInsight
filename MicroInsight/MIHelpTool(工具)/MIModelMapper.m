//
//  GPResponseObjectParser.m
//  GoonPa
//
//  Created by Jonphy on 4/27/17.
//  Copyright © 2018 Jonphy. All rights reserved.
//

#import "MIModelMapper.h"
#import "YYModel.h"

@implementation MIModelMapper

+ (id)modelWithDictionary:(NSDictionary *)responseDictionary modelClass:(Class)cls{
    
    return [cls yy_modelWithDictionary:responseDictionary];
}

+ (NSArray *)modelArrayWithJsonArray:(NSArray *)jsonArray modelClass:(Class)cls{
    
    return [NSArray yy_modelArrayWithClass:cls json:jsonArray];
}

+ (NSDictionary *)modelDictionaryWithJsonDictionary:(NSDictionary *)jsonDictionary modelClass:(Class)cls{
    
    return [NSDictionary yy_modelDictionaryWithClass:cls json:jsonDictionary];
}

@end
