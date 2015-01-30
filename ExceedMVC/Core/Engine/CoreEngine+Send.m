//
//  CoreEngine+Send.m
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "CoreEngine+Send.h"
#import "FileManager+Picture.h"

@implementation CoreEngine (Send)

// 登录
- (void)loginWithUserName:(NSString *)userName
              andPassword:(NSString *)password
{
    [_netController loginWithUserName:userName andPassword:password];
}

// 获取指定用户资料
- (void)getUserInfoOf:(UInt64)userID
{
    [_netController getUserInfoOf:userID];
}

@end
