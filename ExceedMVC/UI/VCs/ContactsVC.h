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

@end


@protocol ContactsVCDelegate <NSObject>

@optional

@end
