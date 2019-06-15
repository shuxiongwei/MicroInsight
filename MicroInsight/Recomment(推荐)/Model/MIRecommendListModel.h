//
//  MIRecommendListModel.h
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/9.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MIRecommendListModel : MIBaseModel

@property (nonatomic, assign) NSInteger modelId;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, assign) NSInteger readings;

@end

NS_ASSUME_NONNULL_END
