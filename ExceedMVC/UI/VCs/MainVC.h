//
//  MainVC.h
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MainVCDataSource;

@interface MainVC : UITabBarController

@property (nonatomic, assign) id <MainVCDataSource> dataSource;

@end


@protocol MainVCDataSource <NSObject>

@optional

// 加载Tab页面 
- (void)mainVC:(MainVC *)mainVC loadViewControllers:(NSMutableArray *)marray;

@end
