//
//  DBController+UserInfo.m
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "DBController+UserInfo.h"
#import "UserInfo.h"

@implementation DBController (UserInfo)

// 从数据库加载好友列表
+ (void)loadContacts:(NSMutableArray *)marrContact
{
    //从数据库中读取好友列表
    
    NSArray *arrAvatar = [NSArray arrayWithObjects:
                          @"http://avatar.csdn.net/6/3/8/1_yjh4866.jpg",
                          @"http://avatar.csdn.net/E/2/4/1_carefree31441.jpg",
                          @"http://avatar.csdn.net/4/3/4/1_zhy_cheng.jpg",
                          @"http://cc.cocimg.com/bbs/attachment/upload/71/1257711352020236.png", nil];
    //随便加些测试数据吧
    for (int i = 0; i < 5; i++) {
        UserInfo *friendInfo = [[UserInfo alloc] init];
        friendInfo.userID = 10+i;
        friendInfo.userName = [NSString stringWithFormat:@"好友%i", 10+i];
        friendInfo.avatarUrl = [arrAvatar objectAtIndex:i%arrAvatar.count];
        [marrContact addObject:friendInfo];
        [friendInfo release];
    }
}

// 查询姓名
+ (NSString *)getUserNameOf:(UInt64)userID
{
    //跟数据库接上，就能读到最新的名字了
    return [NSString stringWithFormat:@"好友%lld", userID];
}

@end
