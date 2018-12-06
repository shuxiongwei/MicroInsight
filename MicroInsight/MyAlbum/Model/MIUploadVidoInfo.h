//
//  MIUploadVidoInfo.h
//  MicroInsight
//
//  Created by Jonphy on 2018/12/6.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MIUploadVidoInfo : NSObject

@property (copy, nonatomic) NSString *VideoId;
@property (copy, nonatomic) NSString *RequestId;
@property (copy, nonatomic) NSString *Endpoint;
@property (copy, nonatomic) NSString *Bucket;
@property (copy, nonatomic) NSString *FileName;
@property (copy, nonatomic) NSString *SecurityToken;
@property (copy, nonatomic) NSString *AccessKeyId;
@property (copy, nonatomic) NSString *AccessKeySecret;
@property (copy, nonatomic) NSString *Expiration;
@property (copy, nonatomic) NSString *Region;

@end

NS_ASSUME_NONNULL_END
