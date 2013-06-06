//
//  DBController+Message.h
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "DBController.h"

@interface DBController (Message)

// 从数据库读取会话列表
+ (void)loadChats:(NSMutableArray *)marrChat;

@end
