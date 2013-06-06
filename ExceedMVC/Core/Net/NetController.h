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

@property (nonatomic, assign) id <NetControllerDelegate> delegate;

// 下载指定url的文件
- (void)downloadFile:(NSString *)filePath withUrl:(NSString *)url;

// 获取指定用户资料
- (void)getUserInfoOf:(UInt64)userID;

@end



@protocol NetControllerDelegate <NSObject>

@optional

// 网络原因用户资料获取失败
- (void)netController:(NetController *)netController userInfoError:(NSError *)error of:(UInt64)userID;

// 网络原因用户资料获取失败
- (void)netController:(NetController *)netController userInfoSuccess:(NSString *)strWebData of:(UInt64)userID;

// 网络原因下载失败
- (void)netController:(NetController *)netController downloadFileError:(NSError *)error with:(NSString *)filePath andUrl:(NSString *)url;

// 下载成功
- (void)netController:(NetController *)netController downloadFileSuccessWith:(NSString *)filePath andUrl:(NSString *)url;

@end


#ifdef DEBUG

#define NETLOG(fmt,...)     NSLog((@"NET->%s(%d):"fmt),__PRETTY_FUNCTION__,__LINE__,##__VA_ARGS__)

#else

#define NETLOG(fmt,...)     NSLog(fmt,##__VA_ARGS__)

#endif
