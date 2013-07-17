//
//  DLConnection.h
//  BookReader
//
//  Created by CocoaChina_yangjh on 13-3-14.
//  Copyright (c) 2013年 CocoaChina. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DownloadStatus) {
    DownloadStatus_Null,
    DownloadStatus_Downloading,
    DownloadStatus_Waiting,
    DownloadStatus_NotExist,
};

@protocol DLConnectionDelegate;

@interface DLConnection : NSObject

@property (nonatomic, assign) NSUInteger maxNumberOfDLConnection;//同时下载数
@property (nonatomic, assign) id <DLConnectionDelegate> delegate;

// 文件下载状态
- (DownloadStatus)fileDownloadStatusWith:(NSString *)filePath andUrl:(NSString *)url;

// 下载文件到指定路径
- (void)downloadFile:(NSString *)filePath from:(NSString *)url
           withParam:(NSDictionary *)dicParam;

// 暂停下载文件
- (void)pauseDownloadFile:(NSString *)filePath from:(NSString *)url;

// 取消下载图书文件
- (void)cancelDownloadFile:(NSString *)filePath from:(NSString *)url;

// 查看指定路径的文件总大小
+ (NSUInteger)fileSizeOf:(NSString *)filePath;

// 查看指定路径的文件已经下载到的大小
+ (NSUInteger)receivedSizeOf:(NSString *)filePath;

@end


@protocol DLConnectionDelegate <NSObject>

@optional

// 下载项由等待状态变为下载状态
- (void)dlConnection:(DLConnection *)dlConnection statusChangedWithPath:(NSString *)filePath
                 url:(NSString *)url andParam:(NSDictionary *)dicParam;

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
