//
//  MIUserInfoModel.h
//  MicroInsight
//
//  Created by 舒雄威 on 2018/12/22.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "MIBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MIUserInfoModel : MIBaseModel<NSCoding>

@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, assign) NSInteger gender;
@property (nonatomic, copy) NSString *birthday;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *token;

@end

NS_ASSUME_NONNULL_END
