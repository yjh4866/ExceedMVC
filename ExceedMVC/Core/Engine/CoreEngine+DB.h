//
//  CoreEngine+DB.h
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "CoreEngine.h"

@interface CoreEngine (DB)

// 从数据库读取会话列表
- (void)loadChats:(NSMutableArray *)marrChat;

// 查询姓名
- (NSString *)getUserNameOf:(UInt64)userID;

// 从数据库加载好友列表
- (void)loadContacts:(NSMutableArray *)marrContact;

@end
