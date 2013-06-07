//
//  LoginVC.m
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "LoginVC.h"
#import "CoreEngine.h"
#import "UIView+MBProgressHUD.h"

@interface LoginVC ()

@end

@implementation LoginVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"登录";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(100.0f, 100.0f, 120.0f, 50.0f);
    [button setTitle:@"登录" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickLogin:)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self];
    [defaultCenter addObserver:self selector:@selector(notifLoginFailure:)
                          name:NetLoginFailure object:nil];
    [defaultCenter addObserver:self selector:@selector(notifLoginSuccess:)
                          name:NetLoginSuccess object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Notification

- (void)notifLoginFailure:(NSNotification *)notif
{
    
}

- (void)notifLoginSuccess:(NSNotification *)notif
{
    if ([self.delegate respondsToSelector:@selector(loginVCLoginSuccess:)]) {
        [self.delegate loginVCLoginSuccess:self];
    }
    [self.navigationController.view hideActivity];
}


#pragma mark - ClickEvent

- (void)clickLogin:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(loginVC:loginWithUserName:andPasswrod:)]) {
        [self.navigationController.view showActivityWithText:@"登录中..."];
        [self.delegate loginVC:self
             loginWithUserName:@"userName" andPasswrod:@"password"];
    }
    else {
        UILOG(@"未实现LoginVC的登录协议");
    }
}

@end
