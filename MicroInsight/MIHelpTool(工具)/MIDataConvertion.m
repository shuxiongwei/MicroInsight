//
//  MIDataConvertion.m
//  MicroInsight
//
//  Created by Jonphy on 2018/12/6.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "MIDataConvertion.h"

@implementation MIDataConvertion

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

- (NSString*)jsonStringWithPrettyPrint:(BOOL)prettyPrint withDictionary:(NSDictionary *)dic{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:(NSJSONWritingOptions)  (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"%s: error: %@", __func__, error.localizedDescription);
        return @"{}";
    } else {
        return [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    }
}

@end
