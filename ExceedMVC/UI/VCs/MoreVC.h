//
//  MoreVC.h
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MoreVCDataSource;
@protocol MoreVCDelegate;

@interface MoreVC : UIViewController

@property (nonatomic, assign) id <MoreVCDataSource> dataSource;
@property (nonatomic, assign) id <MoreVCDelegate> delegate;

@end


@protocol MoreVCDataSource <NSObject>

@optional

@end


@protocol MoreVCDelegate <NSObject>

@optional

// 显示关于页面
- (void)moreVCShowAbout:(MoreVC *)moreVC;

@end
