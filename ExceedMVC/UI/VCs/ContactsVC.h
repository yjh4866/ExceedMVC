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

@property (nonatomic, assign) id <ContactsVCDataSource> dataSource;
@property (nonatomic, assign) id <ContactsVCDelegate> delegate;

@end


@protocol ContactsVCDataSource <NSObject>

@optional

// 加载已有联系人
- (void)contactsVC:(ContactsVC *)contactsVC loadContacts:(NSMutableArray *)marray;

// 加载指定url的头像
- (UIImage *)contactsVC:(ContactsVC *)contactsVC pictureWithUrl:(NSString *)url;

@end


@protocol ContactsVCDelegate <NSObject>

@optional

// 下载指定url的头像
- (void)contactsVC:(ContactsVC *)contactsVC downloadAvatarWithUrl:(NSString *)url;

// 进入用户详细资料页面
- (void)contactsVC:(ContactsVC *)contactsVC showContactsInfo:(UInt64)userID;

@end
