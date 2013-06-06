//
//  ChatsItem.m
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "ChatsItem.h"

@implementation ChatsItem

- (void)dealloc
{
    [_userName release];
    [_latestMsg release];
    [_avatarUrl release];
    
    [super dealloc];
}

@end
