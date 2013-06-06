//
//  UIEngine.h
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import <Foundation/Foundation.h>


//Root
#import "RootViewController.h"

#import "MainVC.h"
#import "ChatsVC.h"
#import "ContactsVC.h"
#import "MoreVC.h"
#import "ChatVC.h"
#import "LoginVC.h"
#import "ContactInfoVC.h"


@class CoreEngine;

@interface UIEngine : NSObject <RootVCDelegate, MainVCDataSource,
ChatsVCDataSource, ChatsVCDelegate, ContactsVCDataSource, ContactsVCDelegate,
MoreVCDataSource, MoreVCDelegate, ChatVCDataSource, ChatVCDelegate,
ContactInfoVCDataSource, ContactInfoVCDelegate, LoginVCDelegate>

@property (nonatomic, readonly) UIViewController *rootViewController;
@property (nonatomic, retain) CoreEngine *engineCore;

@end
