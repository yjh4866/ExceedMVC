//
//  DBController+Message.m
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "DBController+Message.h"
#import "ChatsItem.h"

@implementation DBController (Message)

// 从数据库读取会话列表
+ (void)loadChats:(NSMutableArray *)marrChat
{
    NSArray *arrAvatar = [NSArray arrayWithObjects:
                          @"http://avatar.csdn.net/6/3/8/1_yjh4866.jpg",
                          @"http://avatar.csdn.net/E/2/4/1_carefree31441.jpg",
                          @"http://avatar.csdn.net/4/3/4/1_zhy_cheng.jpg",
                          @"http://cc.cocimg.com/bbs/attachment/upload/71/1257711352020236.png", nil];
    //
    for (int i = 0; i < 8; i++) {
        ChatsItem *chatsItem = [[ChatsItem alloc] init];
        chatsItem.userID = 10+i;
        chatsItem.userName = [NSString stringWithFormat:@"好友%i", i+1];
        chatsItem.latestMsg = [NSString stringWithFormat:@"最新消息 %i", 10*i+rand()%13];
        chatsItem.avatarUrl = [arrAvatar objectAtIndex:rand()%arrAvatar.count];
        [marrChat addObject:chatsItem];
        [chatsItem release];
    }
}

@end
