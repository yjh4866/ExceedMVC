//
//  DBController+UserInfo.m
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "DBController+UserInfo.h"

@implementation DBController (UserInfo)

// 查询姓名
+ (NSString *)getUserNameOf:(UInt64)userID
{
    return [NSString stringWithFormat:@"好友%lld", userID];
}

@end
