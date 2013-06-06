//
//  ChatVC.m
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "ChatVC.h"
#import "CoreEngine.h"

@interface ChatVC ()

@end

@implementation ChatVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"用户资料" style:UIBarButtonItemStylePlain target:self action:@selector(clickInfo:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    [rightItem release];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self];
    [defaultCenter addObserver:self selector:@selector(notifUserInfoSuccess:)
                          name:NetUserInfoSuccess object:nil];
    
    if ([self.dataSource respondsToSelector:@selector(chatVC:getUserNameOf:)]) {
        self.title = [self.dataSource chatVC:self getUserNameOf:self.friendID];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}


#pragma mark - ClickEvent

- (void)clickInfo:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(chatVCShowUserInfo:)]) {
        [self.delegate chatVCShowUserInfo:self];
    }
}


#pragma mark - Notification

- (void)notifUserInfoSuccess:(NSNotification *)notif
{
    UInt64 userID = [[notif.userInfo objectForKey:@"userid"] longLongValue];
    NSString *userName = [notif.userInfo objectForKey:@"username"];
    //
    if (self.friendID == userID) {
        self.title = userName;
    }
}

@end
