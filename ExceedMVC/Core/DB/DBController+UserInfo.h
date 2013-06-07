//
//  DBController+UserInfo.h
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "DBController.h"

@interface DBController (UserInfo)

// 从数据库加载好友列表
+ (void)loadContacts:(NSMutableArray *)marrContact;

// 查询姓名
+ (NSString *)getUserNameOf:(UInt64)userID;

@end
