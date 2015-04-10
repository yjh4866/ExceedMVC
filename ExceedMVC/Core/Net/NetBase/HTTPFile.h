//
//  HTTPFile.h
//
//
//  Created by Jianhong Yang on 15/1/26.
//  Copyright (c) 2015年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(unsigned int, DownloadStatus) {
    DownloadStatus_NotExist = 1,
    DownloadStatus_Waiting,
    DownloadStatus_Downloading,
};

@protocol HTTPFileDelegate;

@interface HTTPFile : NSObject

@property (nonatomic, assign) unsigned int sizePartFile;  // 默认256*1024，最小值为4*1024
@property (nonatomic, assign) id <HTTPFileDelegate> delegate;

// 文件下载状态
- (DownloadStatus)downloadStatusWith:(NSString *)filePath andUrl:(NSString *)url;

// 下载文件到指定路径
- (void)downloadFile:(NSString *)filePath from:(NSString *)url
           withParam:(NSDictionary *)param;

// 取消下载
- (void)cancelDownloadFile:(NSString *)filePath from:(NSString *)url
                 withParam:(NSDictionary *)param;

// 查看指定路径的文件大小
+ (unsigned long)fileSizeOf:(NSString *)filePath;

// 查看指定路径的文件已经下载到的大小
+ (unsigned long)receivedSizeOf:(NSString *)filePath;

@end


@protocol HTTPFileDelegate <NSObject>

// 下载失败
- (void)httpFile:(HTTPFile *)httpFile downloadFailure:(NSError *)error
            from:(NSString *)url withPath:(NSString *)filePath
        andParam:(NSDictionary *)param;

// 得到文件实际大小
- (void)httpFile:(HTTPFile *)httpFile fileSize:(unsigned long)fileSize
            from:(NSString *)url withPath:(NSString *)filePath
        andParam:(NSDictionary *)param;

// 下载进度发生变化
- (void)httpFile:(HTTPFile *)httpFile progressChanged:(float)progress
            from:(NSString *)url withPath:(NSString *)filePath
        andParam:(NSDictionary *)param;

// 下载完成，下载到的文件不一定完整
- (void)httpFile:(HTTPFile *)httpFile downloadSuccess:(BOOL)success
            from:(NSString *)url withPath:(NSString *)filePath
        andParam:(NSDictionary *)param;

@end
