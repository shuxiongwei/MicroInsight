//
//  MILocalData.m
//  MicroInsight
//
//  Created by 舒雄威 on 2018/12/3.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "MILocalData.h"

static NSString * const currentLoginUserInfo = @"currentLoginUserInfo";
static NSString * const currentDemarcateInfo = @"currentDemarcateInfo";
static NSString * const openRuleWatermark = @"openRuleWatermark";

@implementation MILocalData

+ (NSString *)getCurrentRequestToken {
    MIUserInfoModel *model = [self getCurrentLoginUserInfo];
    return model.token;
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

+ (void)saveCurrentLoginUserInfo:(nullable MIUserInfoModel *)info {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:info];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:data forKey:currentLoginUserInfo];
}

+ (MIUserInfoModel *)getCurrentLoginUserInfo {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSData *data = [def objectForKey:currentLoginUserInfo];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

+ (BOOL)hasLogin {
    MIUserInfoModel *model = [self getCurrentLoginUserInfo];
    if (model) {
        return YES;
    }
    
    return NO;
}

+ (void)saveCurrentDemarcateInfo:(CGFloat)length {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setValue:@(length) forKey:currentDemarcateInfo];
}

+ (CGFloat)getCurrentDemarcateInfo {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSNumber *length = [def valueForKey:currentDemarcateInfo];
    return length.floatValue;
}

+ (void)setAppLanguage:(NSString *)lan {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setValue:lan forKey:appLanguage];
}

+ (NSString *)getAppLanguage {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    return [def valueForKey:appLanguage];
}

+ (void)setLanguageMapping {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = @{
                          @"简体中文" : @"zh-Hans",
                          @"English" : @"en",
                          @"日本语" : @"ja",
                          @"zh-Hans" : @"简体中文",
                          @"en" : @"English",
                          @"ja" : @"日本语"
                          };
    [def setValue:dic forKey:languageMapping];
}

+ (NSDictionary *)getLanguageMapping {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    return [def valueForKey:languageMapping];
}

+ (NSString *)getCurrentAppLangugeName {
    NSString *key = [self getAppLanguage];
    NSDictionary *dic = [self getLanguageMapping];
    return dic[key];
}

+ (NSString *)appLanguage:(NSString *)key {
    return [[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:appLanguage]] ofType:@"lproj"]] localizedStringForKey:(key) value:nil table:@"Languages"];
}

+ (void)saveOpenRuleWatermark:(BOOL)open {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setValue:@(open) forKey:openRuleWatermark];
}

+ (BOOL)getOpenRuleWatermark {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSNumber *open = [def valueForKey:openRuleWatermark];
    return open.integerValue;
}

@end
