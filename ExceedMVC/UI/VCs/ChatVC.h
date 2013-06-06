//
//  ChatVC.h
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChatVCDataSource;
@protocol ChatVCDelegate;

@interface ChatVC : UIViewController

@property (nonatomic, assign) UInt64 friendID;

@property (nonatomic, assign) id <ChatVCDataSource> dataSource;
@property (nonatomic, assign) id <ChatVCDelegate> delegate;

@end


@protocol ChatVCDataSource <NSObject>

@optional

// 查询姓名（把userID带在协议方法里，而不是通过chatVC获取，好处是给ChatVC个friendID就可以加载ChatVC所有的数据，而不必另外获取userName）
- (NSString *)chatVC:(ChatVC *)chatVC getUserNameOf:(UInt64)userID;

@end


@protocol ChatVCDelegate <NSObject>

@optional

// 进入用户详细资料页面
- (void)chatVCShowUserInfo:(ChatVC *)chatVC;

@end
