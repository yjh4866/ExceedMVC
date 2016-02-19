//
//  ContactsVC.h
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ContactsVCDataSource;
@protocol ContactsVCDelegate;

@interface ContactsVC : UIViewController

@property (nonatomic, weak) id <ContactsVCDataSource> dataSource;
@property (nonatomic, weak) id <ContactsVCDelegate> delegate;

@end


@protocol ContactsVCDataSource <NSObject>

@optional

// 加载已有联系人
- (void)contactsVC:(ContactsVC *)contactsVC loadContacts:(NSMutableArray *)marray;

@end


@protocol ContactsVCDelegate <NSObject>

@optional

// 进入用户详细资料页面
- (void)contactsVC:(ContactsVC *)contactsVC showContactsInfo:(UInt64)userID;

@end
