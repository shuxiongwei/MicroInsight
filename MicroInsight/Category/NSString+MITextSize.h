//
//  NSString+MITextSize.h
//  MicroInsight
//
//  Created by J on 2018/12/4.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (MITextSize)

- (CGSize)sizeWithFont:(UIFont *)font;

@end

NS_ASSUME_NONNULL_END
