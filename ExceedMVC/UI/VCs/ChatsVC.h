//
//  ChatsVC.h
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChatsVCDataSource;
@protocol ChatsVCDelegate;

@interface ChatsVC : UIViewController

@property (nonatomic, assign) id <ChatsVCDataSource> dataSource;
@property (nonatomic, assign) id <ChatsVCDelegate> delegate;

@end


@protocol ChatsVCDataSource <NSObject>

@optional

// 加载会话列表
- (void)chatsVC:(ChatsVC *)chatsVC loadChats:(NSMutableArray *)marrChat;

// 加载指定url的头像
- (UIImage *)chatsVC:(ChatsVC *)chatsVC pictureWithUrl:(NSString *)url;

@end


@protocol ChatsVCDelegate <NSObject>

@optional

// 下载指定url的头像
- (void)chatsVC:(ChatsVC *)chatsVC downloadAvatarWithUrl:(NSString *)url;

// 进入聊天页面
- (void)chatsVC:(ChatsVC *)chatsVC chatWithFriend:(UInt64)friendID;

@end
