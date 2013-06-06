//
//  ContactInfoVC.h
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserInfo;

@protocol ContactInfoVCDataSource;
@protocol ContactInfoVCDelegate;

@interface ContactInfoVC : UIViewController

@property (nonatomic, assign) UInt64 userID;

@property (nonatomic, assign) id <ContactInfoVCDataSource> dataSource;
@property (nonatomic, assign) id <ContactInfoVCDelegate> delegate;

@end


@protocol ContactInfoVCDataSource <NSObject>

@optional

// 加载已有资料
- (void)contactInfoVC:(ContactInfoVC *)contactInfoVC
         loadUserInfo:(UserInfo *)userInfo;

// 加载指定url的头像
- (UIImage *)contactInfoVC:(ContactInfoVC *)contactInfoVC
            pictureWithUrl:(NSString *)url;

@end


@protocol ContactInfoVCDelegate <NSObject>

@optional

// 更新用户资料
- (void)contactInfoVCGetUserInfo:(ContactInfoVC *)contactInfoVC;

// 下载指定url的头像
- (void)contactInfoVC:(ContactInfoVC *)contactInfoVC
downloadAvatarWithUrl:(NSString *)url;

@end
