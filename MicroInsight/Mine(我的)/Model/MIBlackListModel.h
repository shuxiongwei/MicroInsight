//
//  MIBlackListModel.h
//  MicroInsight
//
//  Created by 舒雄威 on 2019/1/19.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MIBlackListModel : MIBaseModel

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *createdAt;

@end

NS_ASSUME_NONNULL_END
