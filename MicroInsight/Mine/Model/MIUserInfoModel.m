//
//  MIUserInfoModel.m
//  MicroInsight
//
//  Created by 舒雄威 on 2018/12/22.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "MIUserInfoModel.h"

@implementation MIUserInfoModel

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:_uid forKey:@"uid"];
    [aCoder encodeObject:_username forKey:@"username"];
    [aCoder encodeObject:_avatar forKey:@"avatar"];
    [aCoder encodeInteger:_gender forKey:@"gender"];
    [aCoder encodeObject:_birthday forKey:@"birthday"];
    [aCoder encodeObject:_nickname forKey:@"nickname"];
    [aCoder encodeObject:_token forKey:@"token"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super init]) {
        _uid = [aDecoder decodeIntegerForKey:@"uid"];
        _username = [aDecoder decodeObjectForKey:@"username"];
        _avatar = [aDecoder decodeObjectForKey:@"avatar"];
        _gender = [aDecoder decodeIntegerForKey:@"gender"];
        _birthday = [aDecoder decodeObjectForKey:@"birthday"];
        _nickname = [aDecoder decodeObjectForKey:@"nickname"];
        _token = [aDecoder decodeObjectForKey:@"token"];
    }
    
    return self;
}

@end
