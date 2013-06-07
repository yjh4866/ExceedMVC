//
//  LoginVC.h
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoginVCDelegate;

@interface LoginVC : UIViewController

@property (nonatomic, assign) id <LoginVCDelegate> delegate;

@end


@protocol LoginVCDelegate <NSObject>

@optional

- (void)loginVC:(LoginVC *)loginVC loginWithUserName:(NSString *)userName
    andPasswrod:(NSString *)password;

- (void)loginVCLoginSuccess:(LoginVC *)loginVC;

@end
