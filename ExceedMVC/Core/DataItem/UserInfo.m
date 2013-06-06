//
//  UserInfo.m
//  ExceedMVC
//
//  Created by yangjh on 13-6-7.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

- (void)dealloc
{
    [_userName release];
    [_avatarUrl release];
    
    [super dealloc];
}

@end
