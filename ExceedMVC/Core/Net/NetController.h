//
//  NetController.h
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NetControllerDelegate;

@interface NetController : NSObject

@property (nonatomic, weak) id <NetControllerDelegate> delegate;

+ (instancetype)sharedInstance;

// 登录
- (void)loginWithUserName:(NSString *)userName
              andPassword:(NSString *)password;

// 获取指定用户资料
- (void)getUserInfoOf:(UInt64)userID;

@end



@protocol NetControllerDelegate <NSObject>

@optional

// 网络原因登录失败
- (void)netController:(NetController *)netController loginError:(NSError *)error;

// 登录返回数据
- (void)netController:(NetController *)netController loginResult:(NSDictionary *)userInfo;

// 网络原因用户资料获取失败
- (void)netController:(NetController *)netController userInfoError:(NSError *)error of:(UInt64)userID;

// 获取用户资料返回数据
- (void)netController:(NetController *)netController userInfo:(NSDictionary *)userInfo of:(UInt64)userID;

@end


#ifdef DEBUG

#define NETLOG(fmt,...)     NSLog((@"NET->%s(%d):"fmt),__PRETTY_FUNCTION__,__LINE__,##__VA_ARGS__)

#else

#define NETLOG(fmt,...)     NSLog(fmt,##__VA_ARGS__)

#endif
