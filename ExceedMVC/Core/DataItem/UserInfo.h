//
//  UserInfo.h
//  ExceedMVC
//
//  Created by yangjh on 13-6-7.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

@property (nonatomic, assign) UInt64 userID;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *avatarUrl;

@end
