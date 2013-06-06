//
//  UIEngine.m
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "UIEngine.h"
#import "UIDevice+Custom.h"

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


#pragma mark -
#pragma mark RootVCDelegate

//根页面显示
- (void)rootViewController:(RootViewController *)rootVC didFirstAppear:(BOOL)first
{
    if (first) {
        UIViewController *firstVC = [[UIViewController alloc] init];
        if ([UIDevice systemVersionID] < __IPHONE_5_0) {
            [_rootViewController presentModalViewController:firstVC animated:NO];
        }
        else {
            [_rootViewController presentViewController:firstVC animated:NO completion:nil];
        }
        [firstVC release];
    }
}

@end
