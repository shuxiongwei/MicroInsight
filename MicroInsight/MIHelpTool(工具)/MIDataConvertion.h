//
//  MIDataConvertion.h
//  MicroInsight
//
//  Created by Jonphy on 2018/12/6.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MIDataConvertion : NSObject

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

- (NSString*)jsonStringWithPrettyPrint:(BOOL)prettyPrint withDictionary:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
