//
//  UIEngine.m
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "UIEngine.h"
#import "UIDevice+Custom.h"
#import "CoreEngine+DB.h"
#import "CoreEngine+Send.h"
#import "FileManager.h"
#import "FileManager+Picture.h"

@interface UIEngine () {
    
    RootViewController *_rootViewController;
}

@end

@implementation UIEngine

@synthesize rootViewController = _rootViewController;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        //
        _rootViewController = [[RootViewController alloc] init];
        _rootViewController.delegate = self;
        UILOG(@"创建UIEngine");
    }
    return self;
}

- (void)dealloc
{
    //
    [_rootViewController release];
    //
    [_engineCore release];
    
    [super dealloc];
}


#pragma mark - RootVCDelegate

// 是否为第一次显示
- (void)rootVC:(RootViewController *)rootVC didFirstAppear:(BOOL)firstAppear
{
    if (firstAppear) {
        if (self.engineCore.online) {
            MainVC *mainVC = [[MainVC alloc] init];
            mainVC.dataSource = self;
            if ([UIDevice systemVersionID] < __IPHONE_5_0) {
                [_rootViewController presentModalViewController:mainVC
                                                       animated:NO];
            }
            else {
                [_rootViewController presentViewController:mainVC
                                                  animated:NO completion:nil];
            }
            [mainVC release];
        }
        else {
            LoginVC *loginVC = [[LoginVC alloc] init];
            loginVC.delegate = self;
            UINavigationController *navLogin = [[UINavigationController alloc] initWithRootViewController:loginVC];
            if ([UIDevice systemVersionID] < __IPHONE_5_0) {
                [_rootViewController presentModalViewController:navLogin
                                                       animated:NO];
            }
            else {
                [_rootViewController presentViewController:navLogin
                                                  animated:NO completion:nil];
            }
            [navLogin release];
            [loginVC release];
        }
    }
}


#pragma mark - ChatVCDataSource

// 查询姓名
- (NSString *)chatVC:(ChatVC *)chatVC getUserNameOf:(UInt64)userID
{
    return [self.engineCore getUserNameOf:userID];
}


#pragma mark - ChatVCDelegate

// 进入用户详细资料页面
- (void)chatVCShowUserInfo:(ChatVC *)chatVC
{
    ContactInfoVC *contactInfoVC = [[ContactInfoVC alloc] init];
    contactInfoVC.userID = chatVC.friendID;
    contactInfoVC.dataSource = self;
    contactInfoVC.delegate = self;
    [chatVC.navigationController pushViewController:contactInfoVC animated:YES];
    [contactInfoVC release];
}


#pragma mark - ContactInfoVCDataSource

// 加载已有资料
- (void)contactInfoVC:(ContactInfoVC *)contactInfoVC
         loadUserInfo:(UserInfo *)userInfo
{
    //加载已有资料
}

// 加载指定url的头像
- (UIImage *)contactInfoVC:(ContactInfoVC *)contactInfoVC
            pictureWithUrl:(NSString *)url
{
    return [FileManager pictureOfUrl:url];
}


#pragma mark - ContactInfoVCDelegate

// 更新用户资料
- (void)contactInfoVCGetUserInfo:(ContactInfoVC *)contactInfoVC
{
    [self.engineCore getUserInfoOf:contactInfoVC.userID];
}

// 下载指定url的头像
- (void)contactInfoVC:(ContactInfoVC *)contactInfoVC
downloadAvatarWithUrl:(NSString *)url
{
    [self.engineCore downloadPictureWithUrl:url];
}


#pragma mark - LoginVCDelegate

- (void)loginVC:(LoginVC *)loginVC loginWithUserName:(NSString *)userName
    andPasswrod:(NSString *)password
{
    [self.engineCore loginWithUserName:userName andPassword:password];
}

- (void)loginVCLoginSuccess:(LoginVC *)loginVC
{
    UIViewController *navLogin = [loginVC.navigationController retain];
    if ([UIDevice systemVersionID] < __IPHONE_5_0) {
        [_rootViewController dismissModalViewControllerAnimated:NO];
        //
        MainVC *mainVC = [[MainVC alloc] init];
        mainVC.dataSource = self;
        [_rootViewController presentModalViewController:mainVC animated:NO];
        [mainVC presentModalViewController:navLogin animated:NO];
        [mainVC release];
        
        [navLogin.parentViewController dismissModalViewControllerAnimated:YES];
    }
    else {
        [_rootViewController dismissViewControllerAnimated:NO completion:nil];
        //
        MainVC *mainVC = [[MainVC alloc] init];
        mainVC.dataSource = self;
        [_rootViewController presentViewController:mainVC
                                          animated:NO completion:nil];
        [mainVC presentViewController:navLogin animated:NO completion:nil];
        [mainVC release];
        
        [navLogin dismissViewControllerAnimated:YES
                                                          completion:nil];
    }
    [navLogin release];
}

@end
