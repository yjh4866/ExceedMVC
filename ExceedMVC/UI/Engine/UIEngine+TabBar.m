//
//  UIEngine+TabBar.m
//  ExceedMVC
//
//  Created by yangjh on 13-6-7.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "UIEngine+TabBar.h"
#import "CoreEngine+DB.h"
#import "CoreEngine+Send.h"
#import "FileManager.h"
#import "FileManager+Picture.h"

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
    UITabBarItem *tabItemChats = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemBookmarks tag:0];
    navChats.tabBarItem = tabItemChats;
    [tabItemChats release];
    [marray addObject:navChats];
    [navChats release];
    [chatsVC release];
    //联系人
    ContactsVC *contactsVC = [[ContactsVC alloc] init];
    contactsVC.dataSource = self;
    contactsVC.delegate = self;
    UINavigationController *navContacts = [[UINavigationController alloc] initWithRootViewController:contactsVC];
    UITabBarItem *tabItemContacts = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemContacts tag:1];
    navContacts.tabBarItem = tabItemContacts;
    [tabItemContacts release];
    [marray addObject:navContacts];
    [navContacts release];
    [contactsVC release];
    //更多
    MoreVC *moreVC = [[MoreVC alloc] init];
    moreVC.dataSource = self;
    moreVC.delegate = self;
    UINavigationController *navMore = [[UINavigationController alloc] initWithRootViewController:moreVC];
    UITabBarItem *tabItemMore = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:2];
    navMore.tabBarItem = tabItemMore;
    [tabItemMore release];
    [marray addObject:navMore];
    [navMore release];
    [moreVC release];
}


#pragma mark - ChatsVCDataSource

// 加载会话列表
- (void)chatsVC:(ChatsVC *)chatsVC loadChats:(NSMutableArray *)marrChat
{
    [self.engineCore loadChats:marrChat];
}

// 加载指定url的图片
- (UIImage *)chatsVC:(ChatsVC *)chatsVC pictureWithUrl:(NSString *)url
{
    return [FileManager pictureOfUrl:url];
}


#pragma mark - ChatsVCDelegate

// 下载指定url的头像
- (void)chatsVC:(ChatsVC *)chatsVC downloadAvatarWithUrl:(NSString *)url
{
    [self.engineCore downloadPictureWithUrl:url];
}

// 进入聊天页面
- (void)chatsVC:(ChatsVC *)chatsVC chatWithFriend:(UInt64)friendID
{
    ChatVC *chatVC = [[ChatVC alloc] init];
    chatVC.friendID = friendID;
    chatVC.dataSource = self;
    chatVC.delegate = self;
    [chatsVC.navigationController pushViewController:chatVC animated:YES];
    [chatVC release];
}


#pragma mark - ContactsVCDataSource

// 加载已有联系人
- (void)contactsVC:(ContactsVC *)contactsVC loadContacts:(NSMutableArray *)marray
{
    [self.engineCore loadContacts:marray];
}

// 加载指定url的头像
- (UIImage *)contactsVC:(ContactsVC *)contactsVC pictureWithUrl:(NSString *)url
{
    return [FileManager pictureOfUrl:url];
}


#pragma mark - ContactsVCDelegate

// 下载指定url的头像
- (void)contactsVC:(ContactsVC *)contactsVC downloadAvatarWithUrl:(NSString *)url
{
    [self.engineCore downloadPictureWithUrl:url];
}

// 进入用户详细资料页面
- (void)contactsVC:(ContactsVC *)contactsVC showContactsInfo:(UInt64)userID
{
    ContactInfoVC *contactInfoVC = [[ContactInfoVC alloc] init];
    contactInfoVC.userID = userID;
    contactInfoVC.dataSource = self;
    contactInfoVC.delegate = self;
    [contactsVC.navigationController pushViewController:contactInfoVC
                                               animated:YES];
    [contactInfoVC release];
}


#pragma mark - MoreVCDelegate

// 显示关于页面
- (void)moreVCShowAbout:(MoreVC *)moreVC
{
    AboutVC *aboutVC = [[AboutVC alloc] init];
    aboutVC.delegate = self;
    UINavigationController *navAbout = [[UINavigationController alloc] initWithRootViewController:aboutVC];
    [self showViewController:navAbout onViewController:moreVC.navigationController.tabBarController];
    [navAbout release];
    [aboutVC release];
}

@end
