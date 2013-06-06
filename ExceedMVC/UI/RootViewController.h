//
//  RootViewController.h
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RootVCDelegate;

@interface RootViewController : UIViewController

@property (nonatomic, assign) id <RootVCDelegate> delegate;

@end


@protocol RootVCDelegate <NSObject>

@optional

// 是否为第一次显示
- (void)rootVC:(RootViewController *)rootVC didFirstAppear:(BOOL)firstAppear;

@end
