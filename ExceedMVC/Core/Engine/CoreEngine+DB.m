//
//  CoreEngine+DB.m
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "CoreEngine+DB.h"
#import "DBController+Message.h"
#import "DBController+UserInfo.h"

@implementation CoreEngine (DB)

// 从数据库读取会话列表
- (void)loadChats:(NSMutableArray *)marrChat
{
    [DBController loadChats:marrChat];
}

// 查询姓名
- (NSString *)getUserNameOf:(UInt64)userID
{
    return [DBController getUserNameOf:userID];
}

// 从数据库加载好友列表
- (void)loadContacts:(NSMutableArray *)marrContact
{
    [DBController loadContacts:marrContact];
}

@end
