//
//  DLConnection.h
//  
//
//  Created by Jianhong Yang on 13-3-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DLConnectionDelegate;

@interface DLConnection : NSObject

@property (nonatomic, assign) id <DLConnectionDelegate> delegate;

// 是否为下载状态
- (BOOL)fileIsDownloadingWith:(NSString *)filePath andUrl:(NSString *)url;

// 下载文件到指定路径
- (void)downloadFile:(NSString *)filePath from:(NSString *)url
           withParam:(NSDictionary *)dicParam;

// 暂停下载文件
- (void)pauseDownloadFile:(NSString *)filePath from:(NSString *)url;

// 查看指定路径的文件总大小
+ (NSUInteger)fileSizeOf:(NSString *)filePath;

// 查看指定路径的文件已经下载到的大小
+ (NSUInteger)receivedSizeOf:(NSString *)filePath;

@end


@protocol DLConnectionDelegate <NSObject>

@optional

// 下载失败
- (void)dlConnection:(DLConnection *)dlConnection downloadFailure:(NSError *)error
            withPath:(NSString *)filePath url:(NSString *)url
            andParam:(NSDictionary *)dicParam;

// 得到文件实际大小
- (void)dlConnection:(DLConnection *)dlConnection fileSize:(NSUInteger)fileSize
            withPath:(NSString *)filePath url:(NSString *)url
            andParam:(NSDictionary *)dicParam;

// 收到的数据发生变化
- (void)dlConnection:(DLConnection *)dlConnection receivedSize:(NSUInteger)receivedSize
            withPath:(NSString *)filePath url:(NSString *)url
            andParam:(NSDictionary *)dicParam;

// 下载完成
- (void)dlConnection:(DLConnection *)dlConnection finishedWithPath:(NSString *)filePath
                 url:(NSString *)url andParam:(NSDictionary *)dicParam;

@end
