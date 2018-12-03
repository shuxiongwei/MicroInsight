//
//  MIAlbum.h
//  MicroInsight
//
//  Created by Jonphy on 2018/11/28.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MIAlbum : NSObject

@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, copy) NSString *fileUrl;

@end

NS_ASSUME_NONNULL_END
