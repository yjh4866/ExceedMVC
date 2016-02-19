//
//  RootVC.h
//  ExceedMVC
//
//  Created by CocoaChina_yangjh on 16/2/18.
//  Copyright © 2016年 yjh4866. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RootVCDelegate;

@interface RootVC : UIViewController

@property (nonatomic, weak) id <RootVCDelegate> delegate;

@end


@protocol RootVCDelegate <NSObject>

@optional

// 是否为第一次显示
- (void)rootVC:(RootVC *)rootVC didFirstAppear:(BOOL)firstAppear;

@end
