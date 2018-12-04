//
//  MIHelpTool.m
//  MicroInsight
//
//  Created by 舒雄威 on 2018/7/10.
//  Copyright © 2018年 舒雄威. All rights reserved.
//

#import "MIHelpTool.h"

static NSInteger const maxLength = 20;

@implementation MIHelpTool

+ (NSString *)timeStampSecond {
    long long stamp = [[NSDate date] timeIntervalSince1970] * 1000; //毫秒
    NSString *curStamp = [NSString stringWithFormat:@"%lld", stamp];
    
    return curStamp;
}

+ (NSString *)getDocumentPath {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+ (NSString *)assetsPath{
    return [[self getDocumentPath] stringByAppendingPathComponent:@"Assets"];
}

+ (NSString *)createAssetsPath{
   return  [self createFolderWithLastComponent:@"Assets"];
}

+ (NSString *)createFolderWithLastComponent:(NSString *)component {
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *pathDocuments = [self getDocumentPath];
    NSString *createPath = [NSString stringWithFormat:@"%@/%@",pathDocuments,component];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:createPath]) {
        [fileManager createDirectoryAtPath:createPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return createPath;
}

+ (CGFloat)measureSingleLineStringWidthWithString:(NSString *)str font:(UIFont *)font {
    if (str == nil) {
        return 0;
    }
    
    CGSize measureSize = [str boundingRectWithSize:CGSizeMake(0, 0) options:NSStringDrawingUsesFontLeading attributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil] context:nil].size;
    return ceil(measureSize.width);
}

+ (CGFloat)measureMutilineStringHeightWithString:(NSString *)str font:(UIFont *)font width:(CGFloat)width {
    
    if (str == nil || width <= 0) {
        return 0;
    }
    
    CGSize measureSize = [str boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil] context:nil].size;
    
    return ceil(measureSize.height);
}

+ (UIImage *)fetchThumbnailWithAVAsset:(AVAsset *)asset curTime:(CGFloat)curTime {
    @autoreleasepool {
        AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        gen.appliesPreferredTrackTransform = YES;
        CMTime time = CMTimeMakeWithSeconds(curTime, asset.duration.timescale);
        NSError *error = nil;
        CGImageRef imageRef = [gen copyCGImageAtTime:time actualTime:NULL error:&error];
        UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
        
        if (image == nil) {
            time = CMTimeMakeWithSeconds(curTime + 1, asset.duration.timescale);
            imageRef = [gen copyCGImageAtTime:time actualTime:NULL error:&error];
            image = [[UIImage alloc] initWithCGImage:imageRef];
        }
        
        CGImageRelease(imageRef);
        return image;
    }
}

+ (BOOL) isBlankString:(NSString *)str {
    if (str == nil || str == NULL) {
        return YES;
    }
    
    if ([str isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    if ([[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isInputRuleAndNumber:(NSString *)str {
    
    NSString *other = @"➋➌➍➎➏➐➑➒";     //九宫格的输入值
    unsigned long len = str.length;
    for (int i = 0; i< len; i++) {
        unichar a = [str characterAtIndex:i];
        if(!((isalpha(a))
             ||(isalnum(a))
             //             ||((a=='_') || (a == '-')) //判断是否允许下划线，昵称可能会用上
             ||((a==' '))                 //判断是否允许控制
             ||((a >= 0x4e00 && a <= 0x9fa6))
             ||([other rangeOfString:str].location != NSNotFound)
             ))
            return NO;
    }
    
    return YES;
}

+ (NSString *)getSubString:(NSString*)string {
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData* data = [string dataUsingEncoding:encoding];
    NSInteger length = [data length];
    if (length > maxLength) {
        NSData *data1 = [data subdataWithRange:NSMakeRange(0, maxLength)];
        //注意：当截取maxLength长度字符时，把中文字符截断返回的content会是nil
        NSString *content = [[NSString alloc] initWithData:data1 encoding:encoding];
        
        if (!content || content.length == 0) {
            data1 = [data subdataWithRange:NSMakeRange(0, maxLength - 1)];
            content =  [[NSString alloc] initWithData:data1 encoding:encoding];
        }
        return content;
    }
    return nil;
}

+ (BOOL)hasEmoji:(NSString *)str {
    NSString *pattern = @"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:str];
    return isMatch;
}

+ (NSString *)disable_emoji:(NSString *)text {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]"options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:text
                                                               options:0
                                                                 range:NSMakeRange(0, [text length])
                                                          withTemplate:@""];
    return modifiedString;
}

@end
