//
//  DLConnection.m
//  
//
//  Created by Jianhong Yang on 13-3-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DLConnection.h"
#import "HTTPConnection.h"


#define TempFilePath_File(filePath)  [filePath stringByAppendingPathExtension:@"temp"]


enum {
    NetDownloadType_None,
    NetDownloadType_FileSize,
    NetDownloadType_Download,
};
typedef NSInteger NetDownloadType;


@interface DLConnection () <HTTPConnectionDelegate> {
    
    HTTPConnection *_httpDownload;
}

@end

@implementation DLConnection

- (id)init
{
    self = [super init];
    if (self) {
        _httpDownload = [[HTTPConnection alloc] init];
        _httpDownload.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    [_httpDownload release];
    
    [super dealloc];
}


#pragma mark - Public

// 是否为下载状态
- (BOOL)fileIsDownloadingWith:(NSString *)filePath andUrl:(NSString *)url
{
    NSDictionary *dicParam0 = [[NSDictionary alloc] initWithObjectsAndKeys:
                               [NSNumber numberWithInt:NetDownloadType_FileSize], @"type",
                               filePath, @"filePath", url, @"url", nil];
    BOOL exist0 = [_httpDownload requestIsExist:dicParam0];
    [dicParam0 release];
    NSDictionary *dicParam1 = [[NSDictionary alloc] initWithObjectsAndKeys:
                               [NSNumber numberWithInt:NetDownloadType_Download], @"type",
                               filePath, @"filePath", url, @"url", nil];
    BOOL exist1 = [_httpDownload requestIsExist:dicParam1];
    [dicParam1 release];
    //
    return exist0 || exist1;
}

// 下载文件到指定路径
- (void)downloadFile:(NSString *)filePath from:(NSString *)url
           withParam:(NSDictionary *)dicParam
{
    NSString *tempFilePath = TempFilePath_File(filePath);
    //如果临时文件不存在则先查看文件大小
    if (![[NSFileManager defaultManager] fileExistsAtPath:tempFilePath]) {
        //
        NSMutableURLRequest *mURLRequest = [[NSMutableURLRequest alloc] init];
        [mURLRequest setHTTPMethod:@"HEAD"];
        [mURLRequest setURL:[NSURL URLWithString:url]];
        NSDictionary *dicInterParam = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:NetDownloadType_FileSize], @"type",
                                       filePath, @"filePath",
                                       url, @"url", dicParam, @"param", nil];
        [_httpDownload requestWebDataWithRequest:mURLRequest
                                        andParam:dicInterParam
                                           cache:NO priority:YES];
        [dicInterParam release];
        [mURLRequest release];
    }
    else {
        //先读取已经下载到的数据
        NSUInteger partSize = [DLConnection receivedSizeOf:filePath];
        //
        NSMutableURLRequest *mURLRequest = [[NSMutableURLRequest alloc] init];
        [mURLRequest setURL:[NSURL URLWithString:url]];
        [mURLRequest setValue:[NSString stringWithFormat:@"bytes=%i-", partSize]
           forHTTPHeaderField:@"RANGE"];
        [mURLRequest setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
        [mURLRequest setTimeoutInterval:10.0f];
        //
        NSDictionary *dicInterParam = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:NetDownloadType_Download], @"type",
                                       filePath, @"filePath",
                                       url, @"url", dicParam, @"param", nil];
        [_httpDownload requestWebDataWithRequest:mURLRequest
                                        andParam:dicInterParam
                                           cache:NO priority:YES];
        [dicInterParam release];
        [mURLRequest release];
    }
}

// 暂停下载文件
- (void)pauseDownloadFile:(NSString *)filePath from:(NSString *)url
{
    //取消正在获取文件大小的
    NSDictionary *dicParam0 = [[NSDictionary alloc] initWithObjectsAndKeys:
                               [NSNumber numberWithInt:NetDownloadType_FileSize], @"type",
                               filePath, @"filePath", url, @"url", nil];
    [_httpDownload cancelRequest:dicParam0];
    [dicParam0 release];
    //取消正在下载的
    NSDictionary *dicParam1 = [[NSDictionary alloc] initWithObjectsAndKeys:
                               [NSNumber numberWithInt:NetDownloadType_Download], @"type",
                               filePath, @"filePath", url, @"url", nil];
    [_httpDownload cancelRequest:dicParam1];
    [dicParam1 release];
}

// 查看指定路径的文件总大小
+ (NSUInteger)fileSizeOf:(NSString *)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tempFilePath = TempFilePath_File(filePath);
    if ([fileManager fileExistsAtPath:tempFilePath]) {
        //从文件尾部读4个字节
        UInt32 fileSize;
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:tempFilePath];
        unsigned long long tempFileSize = [fileHandle seekToEndOfFile];
        [fileHandle seekToFileOffset:tempFileSize-4];
        NSData *dataFileSize = [fileHandle readDataOfLength:4];
        [dataFileSize getBytes:&fileSize length:4];
        [fileHandle closeFile];
        //
        return fileSize;
    }
    else if ([fileManager fileExistsAtPath:filePath]) {
        NSUInteger fileSize;
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
        fileSize = [fileHandle seekToEndOfFile];
        [fileHandle closeFile];
        //
        return fileSize;
    }
    return 0;
}

// 查看指定路径的文件已经下载到的大小
+ (NSUInteger)receivedSizeOf:(NSString *)filePath
{
    NSString *tempFilePath = TempFilePath_File(filePath);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:tempFilePath]) {
        NSDictionary *dicAttributes = [fileManager attributesOfItemAtPath:tempFilePath error:nil];
        NSUInteger tempFileSize = [[dicAttributes objectForKey:NSFileSize] intValue];
        //
        return tempFileSize-4;
    }
    return 0;
}


#pragma mark - HTTPConnectionDelegate

// 网络数据下载失败
- (void)httpConnect:(HTTPConnection *)httpConnect error:(NSError *)error with:(NSDictionary *)dicParam
{
    if ([self.delegate respondsToSelector:@selector(dlConnection:downloadFailure:withPath:url:andParam:)]) {
        NSString *filePath = [dicParam objectForKey:@"filePath"];
        NSString *url = [dicParam objectForKey:@"url"];
        
        [self.delegate dlConnection:self downloadFailure:error
                           withPath:filePath url:url
                           andParam:[dicParam objectForKey:@"param"]];
    }
}

// 服务器返回的HTTP信息头
- (void)httpConnect:(HTTPConnection *)httpConnect receiveResponseWithStatusCode:(NSInteger)statusCode
 andAllHeaderFields:(NSDictionary *)dicAllHeaderFields with:(NSDictionary *)dicParam
{
    //网络请求类型
    NSUInteger requesttype = [[dicParam objectForKey:@"type"] intValue];
    //
    switch (requesttype) {
            //查看文件大小
        case NetDownloadType_FileSize:
        {
            NSString *filePath = [dicParam objectForKey:@"filePath"];
            NSString *url = [dicParam objectForKey:@"url"];
            UInt32 fileSize = [[dicAllHeaderFields objectForKey:@"Content-Length"] intValue];
            //将文件大小保存到临时文件尾部
            NSString *tempFilePath = TempFilePath_File(filePath);
            NSData *dataFileSize = [NSData dataWithBytes:&fileSize length:4];
            [dataFileSize writeToFile:tempFilePath atomically:YES];
            //通知文件大小
            if ([self.delegate respondsToSelector:@selector(dlConnection:fileSize:withPath:url:andParam:)]) {
                [self.delegate dlConnection:self fileSize:fileSize
                                   withPath:filePath url:url
                                   andParam:[dicParam objectForKey:@"param"]];
            }
            //请求下载
            [self downloadFile:filePath from:url
                     withParam:[dicParam objectForKey:@"param"]];
        }
            break;
        default:
            break;
    }
}

// 接收到部分数据
- (void)httpConnect:(HTTPConnection *)httpConnect receivePartData:(NSData *)partData with:(NSDictionary *)dicParam
{
    //网络请求类型
    NSUInteger requesttype = [[dicParam objectForKey:@"type"] intValue];
    //
    switch (requesttype) {
            //文件下载
        case NetDownloadType_Download:
        {
            NSString *filePath = [dicParam objectForKey:@"filePath"];
            UInt32 fileSize = [DLConnection fileSizeOf:filePath];
            NSUInteger receivedSize = [DLConnection receivedSizeOf:filePath];
            //将下载到的数据写到文件相应位置
            NSString *tempFilePath = TempFilePath_File(filePath);
            NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:tempFilePath];
            [fileHandle seekToFileOffset:receivedSize];
            [fileHandle writeData:partData];
            [fileHandle seekToFileOffset:receivedSize+partData.length];//再把文件大小写到临时文件尾部
            [fileHandle writeData:[NSData dataWithBytes:&fileSize length:4]];
            [fileHandle synchronizeFile];
            [fileHandle closeFile];
            //更新文件尺寸
            receivedSize += partData.length;
            //通知下载进度
            if ([self.delegate respondsToSelector:@selector(dlConnection:receivedSize:withPath:url:andParam:)]) {
                NSString *url = [dicParam objectForKey:@"url"];
                [self.delegate dlConnection:self receivedSize:receivedSize
                                   withPath:filePath url:url
                                   andParam:[dicParam objectForKey:@"param"]];
            }
        }
            break;
        default:
            break;
    }
}

// 网络数据下载完成
- (void)httpConnect:(HTTPConnection *)httpConnect finish:(NSData *)data with:(NSDictionary *)dicParam
{
    //网络请求类型
    NSUInteger requesttype = [[dicParam objectForKey:@"type"] intValue];
    //
    switch (requesttype) {
            //文件下载
        case NetDownloadType_Download:
        {
            NSString *filePath = [dicParam objectForKey:@"filePath"];
            NSUInteger partSize = [DLConnection receivedSizeOf:filePath];
            //将临时文件尾部的文件大小数据截断
            NSString *tempFilePath = TempFilePath_File(filePath);
            NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:tempFilePath];
            [fileHandle truncateFileAtOffset:partSize];
            [fileHandle closeFile];
            //修改文件名
            [[NSFileManager defaultManager] moveItemAtPath:tempFilePath toPath:filePath error:nil];
            //通知下载完成
            if ([self.delegate respondsToSelector:@selector(dlConnection:finishedWithPath:url:andParam:)]) {
                NSString *url = [dicParam objectForKey:@"url"];
                [self.delegate dlConnection:self
                           finishedWithPath:filePath url:url
                                   andParam:[dicParam objectForKey:@"param"]];
            }
        }
            break;
        default:
            break;
    }
}


#pragma mark - Private

@end
