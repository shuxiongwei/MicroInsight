//
//  MILetterListModel.h
//  MicroInsight
//
//  Created by 舒雄威 on 2019/7/9.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MILetterListModel : MIBaseModel

@property (nonatomic, copy) NSString *modelId;
@property (nonatomic, copy) NSString *user_send_id;
@property (nonatomic, copy) NSString *user_receive_id;
@property (nonatomic, copy) NSString *type; //3:文本，6:图片
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *created_at;

@property (nonatomic, assign) BOOL isSelf;
@property (nonatomic, strong) UIImage *image;

- (CGRect)timeFrame;
- (CGRect)logoFrame;
- (CGRect)messageFrame;
- (CGRect)imageFrame;
- (CGFloat)cellHeight;
- (CGRect)pointFrame;

@end

NS_ASSUME_NONNULL_END
