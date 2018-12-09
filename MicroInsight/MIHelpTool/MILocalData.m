//
//  MILocalData.m
//  MicroInsight
//
//  Created by 舒雄威 on 2018/12/3.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "MILocalData.h"

static NSString * const currentLoginUser = @"currentLoginUser";
static NSString * const currentRequestToken = @"currentRequestToken";

@implementation MILocalData

+ (void)setCurrentLoginUsername:(NSString *)username {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setValue:username forKey:currentLoginUser];
}

+ (NSString *)getCurrentLoginUsername {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    return [def valueForKey:currentLoginUser];
}

+ (void)setCurrentRequestToken:(NSString *)token {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setValue:token forKey:currentRequestToken];
}

+ (NSString *)getCurrentRequestToken {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    return [def valueForKey:currentRequestToken];
}

+ (NSString *)getFirstLocalAssetPath {
    
    NSString *assetsPath = [MIHelpTool assetsPath];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:assetsPath]) {
        NSArray *contentOfFolder = [fm contentsOfDirectoryAtPath:assetsPath error:nil];
        if (contentOfFolder.count > 0) {
            NSMutableArray *paths = [NSMutableArray arrayWithArray:contentOfFolder];
            [paths sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                return [obj2 compare:obj1];
            }];

            NSString *path = paths.firstObject;
            NSString *fullPath = [assetsPath stringByAppendingPathComponent:path];
            
            return fullPath;
        } else {
            return nil;
        }
    }
    
    return nil;
}

@end
