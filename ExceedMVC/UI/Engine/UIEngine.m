//
//  UIEngine.m
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "UIEngine.h"
#import "UIDevice+Custom.h"
#import "PictureEditor.h"
#import "CoreEngine+DB.h"
#import "CoreEngine+Send.h"
#import "FileManager.h"
#import "FileManager+Picture.h"

#define AnimationID_ShowViewController        @"AnimationID_ShowViewController"
#define AnimationID_RemoveViewController      @"AnimationID_RemoveViewController"

@interface UIEngine () {
    
    RootViewController *_rootViewController;
    UIViewController *_parentViewController;
    UIViewController *_childViewController;
    UIImageView *_imageViewChild;
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
        
        _imageViewChild = [[UIImageView alloc] init];
        UILOG(@"创建UIEngine");
    }
    return self;
}

- (void)dealloc
{
    //
    [_rootViewController release];
    [_parentViewController release];
    [_childViewController release];
    [_imageViewChild release];
    //
    [_engineCore release];
    
    [super dealloc];
}


#pragma mark - Public

// 在parentViewController上叠加viewController
- (void)showViewController:(UIViewController *)viewController
          onViewController:(UIViewController *)parentViewController
{
    if (_childViewController) {
        return;
    }
    _childViewController = [viewController retain];
    _parentViewController = [parentViewController retain];
    //截屏
    @autoreleasepool {
        UIImage *screenshot = [PictureEditor screenshotFromView:_childViewController.view];
        _imageViewChild.image = screenshot;
        _imageViewChild.frame = CGRectMake(screenshot.size.width, 0.0f,
                                           screenshot.size.width, screenshot.size.height);
        [_parentViewController.view addSubview:_imageViewChild];
        [UIView beginAnimations:AnimationID_ShowViewController context:nil];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [UIView setAnimationDelegate:self];
        _imageViewChild.frame = CGRectMake(0.0f, 0.0f, screenshot.size.width, screenshot.size.height);
        [UIView commitAnimations];
    }
}

// 从parentViewController上移除viewController
- (void)removeViewController:(UIViewController *)viewController
{
    if (_childViewController) {
        return;
    }
    _childViewController = [viewController retain];
    //可以移除viewController了
    if ([UIDevice systemVersionID] < __IPHONE_5_0) {
        _parentViewController = [_childViewController.parentViewController retain];
        [_parentViewController dismissModalViewControllerAnimated:NO];
    }
    else {
        _parentViewController = [_childViewController.presentingViewController retain];
        [_parentViewController dismissViewControllerAnimated:NO completion:nil];
    }
    //截屏
    @autoreleasepool {
        UIImage *screenshot = [PictureEditor screenshotFromView:_childViewController.view];
        _imageViewChild.image = screenshot;
        _imageViewChild.frame = CGRectMake(0.0f, 0.0f, screenshot.size.width, screenshot.size.height);
        [_parentViewController.view addSubview:_imageViewChild];
        [UIView beginAnimations:AnimationID_RemoveViewController context:nil];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [UIView setAnimationDelegate:self];
        _imageViewChild.frame = CGRectMake(screenshot.size.width, 0.0f,
                                           screenshot.size.width, screenshot.size.height);
        [UIView commitAnimations];
    }
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


#pragma mark - AboutVCDelegate

- (void)aboutVCClose:(AboutVC *)aboutVC
{
    [self removeViewController:aboutVC];
}


#pragma mark - Private

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([animationID isEqualToString:AnimationID_ShowViewController]) {
        [_imageViewChild removeFromSuperview];
        //
        if ([UIDevice systemVersionID] < __IPHONE_5_0) {
            [_parentViewController presentModalViewController:_childViewController animated:NO];
        }
        else {
            [_parentViewController presentViewController:_childViewController animated:NO completion:nil];
        }
        [_childViewController release];
        _childViewController = nil;
        [_parentViewController release];
        _parentViewController = nil;
    }
    else if ([animationID isEqualToString:AnimationID_RemoveViewController]) {
        [_imageViewChild removeFromSuperview];
        //
        [_childViewController release];
        _childViewController = nil;
        [_parentViewController release];
        _parentViewController = nil;
    }
}

@end
