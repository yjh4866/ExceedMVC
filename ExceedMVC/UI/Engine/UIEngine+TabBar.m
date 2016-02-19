//
//  UIEngine+TabBar.m
//  ExceedMVC
//
//  Created by yangjh on 13-6-7.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "UIEngine+TabBar.h"
#import "DBController+Message.h"
#import "DBController+UserInfo.h"

@implementation UIEngine (TabBar)


#pragma mark - MainVCDataSource

// 加载Tab页面
- (void)mainVC:(MainVC *)mainVC loadViewControllers:(NSMutableArray *)marray
{
    //会话
    ChatsVC *chatsVC = [[ChatsVC alloc] init];
    chatsVC.dataSource = self;
    chatsVC.delegate = self;
    UINavigationController *navChats = [[UINavigationController alloc] initWithRootViewController:chatsVC];
    navChats.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemBookmarks tag:0];
    [marray addObject:navChats];
    //联系人
    ContactsVC *contactsVC = [[ContactsVC alloc] init];
    contactsVC.dataSource = self;
    contactsVC.delegate = self;
    UINavigationController *navContacts = [[UINavigationController alloc] initWithRootViewController:contactsVC];
    navContacts.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemContacts tag:1];
    [marray addObject:navContacts];
    //更多
    MoreVC *moreVC = [[MoreVC alloc] init];
    moreVC.dataSource = self;
    moreVC.delegate = self;
    UINavigationController *navMore = [[UINavigationController alloc] initWithRootViewController:moreVC];
    navMore.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:2];
    [marray addObject:navMore];
}


#pragma mark - ChatsVCDataSource

// 加载会话列表
- (void)chatsVC:(ChatsVC *)chatsVC loadChats:(NSMutableArray *)marrChat
{
    [DBController loadChats:marrChat];
}


#pragma mark - ChatsVCDelegate

// 进入聊天页面
- (void)chatsVC:(ChatsVC *)chatsVC chatWithFriend:(UInt64)friendID
{
    ChatVC *chatVC = [[ChatVC alloc] init];
    chatVC.friendID = friendID;
    chatVC.dataSource = self;
    chatVC.delegate = self;
    [chatsVC.navigationController pushViewController:chatVC animated:YES];
}


#pragma mark - ContactsVCDataSource

// 加载已有联系人
- (void)contactsVC:(ContactsVC *)contactsVC loadContacts:(NSMutableArray *)marray
{
    [DBController loadContacts:marray];
}


#pragma mark - ContactsVCDelegate

// 进入用户详细资料页面
- (void)contactsVC:(ContactsVC *)contactsVC showContactsInfo:(UInt64)userID
{
    ContactInfoVC *contactInfoVC = [[ContactInfoVC alloc] init];
    contactInfoVC.userID = userID;
    contactInfoVC.dataSource = self;
    contactInfoVC.delegate = self;
    [contactsVC.navigationController pushViewController:contactInfoVC
                                               animated:YES];
}


#pragma mark - MoreVCDelegate

// 显示关于页面
- (void)moreVCShowAbout:(MoreVC *)moreVC
{
    AboutVC *aboutVC = [[AboutVC alloc] init];
    aboutVC.delegate = self;
    [moreVC.navigationController pushViewController:aboutVC animated:YES];
}

@end
