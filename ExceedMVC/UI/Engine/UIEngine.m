//
//  UIEngine.m
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "UIEngine.h"

#import "DBController+UserInfo.h"

#import "CoreEngine.h"
#import "NetController.h"

@interface UIEngine () {
    
    RootVC *_rootViewController;
}
@property (nonatomic, strong) RootVC *rootViewController;
@end

@implementation UIEngine

@synthesize rootViewController = _rootViewController;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        //
        self.rootViewController = [[RootVC alloc] init];
        self.rootViewController.delegate = self;
    }
    return self;
}

- (void)dealloc
{
}


#pragma mark - Public


#pragma mark - RootVCDelegate

// 是否为第一次显示
- (void)rootVC:(RootVC *)rootVC didFirstAppear:(BOOL)firstAppear
{
    if (firstAppear) {
        if (self.engineCore.online) {
            MainVC *mainVC = [[MainVC alloc] init];
            mainVC.dataSource = self;
            [_rootViewController presentViewController:mainVC animated:NO completion:nil];
        }
        else {
            LoginVC *loginVC = [[LoginVC alloc] init];
            loginVC.delegate = self;
            UINavigationController *navLogin = [[UINavigationController alloc] initWithRootViewController:loginVC];
            [_rootViewController presentViewController:navLogin animated:NO completion:nil];
        }
    }
}


#pragma mark - ChatVCDataSource

// 查询姓名
- (NSString *)chatVC:(ChatVC *)chatVC getUserNameOf:(UInt64)userID
{
    return [DBController getUserNameOf:userID];
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
}


#pragma mark - ContactInfoVCDataSource

// 加载已有资料
- (void)contactInfoVC:(ContactInfoVC *)contactInfoVC
         loadUserInfo:(UserInfo *)userInfo
{
    //加载已有资料
}


#pragma mark - ContactInfoVCDelegate

// 更新用户资料
- (void)contactInfoVCGetUserInfo:(ContactInfoVC *)contactInfoVC
{
    [[NetController sharedInstance] getUserInfoOf:contactInfoVC.userID];
}


#pragma mark - LoginVCDelegate

- (void)loginVC:(LoginVC *)loginVC loginWithUserName:(NSString *)userName
    andPasswrod:(NSString *)password
{
    [[NetController sharedInstance] loginWithUserName:userName andPassword:password];
}

- (void)loginVCLoginSuccess:(LoginVC *)loginVC
{
    [self.rootViewController dismissViewControllerAnimated:NO completion:nil];
    //
    MainVC *mainVC = [[MainVC alloc] init];
    mainVC.dataSource = self;
    [self.rootViewController presentViewController:mainVC animated:NO completion:nil];
    [mainVC presentViewController:loginVC.navigationController animated:NO completion:nil];
    
    [mainVC dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - AboutVCDelegate

- (void)aboutVCClose:(AboutVC *)aboutVC
{
    [aboutVC.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Private

@end
