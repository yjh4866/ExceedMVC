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

#pragma mark - SaveFileDataOperation

@class SaveFileDataOperation;

@protocol SaveFileDataOperationDelegate <NSObject>

// 数据保存完毕
- (void)saveFileDataOperationFinished:(SaveFileDataOperation *)operation;

@end

@interface SaveFileDataOperation : NSOperation

@property (nonatomic, retain) NSString *filePath;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSDictionary *param;
@property (nonatomic, retain) NSData *receivedData;
@property (nonatomic, readonly) NSUInteger finishedSize;
@property (nonatomic, assign) id <SaveFileDataOperationDelegate> delegate;

@end

@implementation SaveFileDataOperation

- (void)dealloc
{
    self.filePath = nil;
    self.url = nil;
    self.param = nil;
    self.receivedData = nil;
    
    [super dealloc];
}

- (void)main
{
    if (self.receivedData) {
        UInt32 fileSize = [DLConnection fileSizeOf:self.filePath];
        NSUInteger receivedSize = [DLConnection receivedSizeOf:self.filePath];
        //将下载到的数据写到文件相应位置
        NSString *tempFilePath = TempFilePath_File(self.filePath);
        @autoreleasepool {
            NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:tempFilePath];
            [fileHandle seekToFileOffset:receivedSize];
            [fileHandle writeData:self.receivedData];
            [fileHandle seekToFileOffset:receivedSize+self.receivedData.length];//再把文件大小写到临时文件尾部
            [fileHandle writeData:[NSData dataWithBytes:&fileSize length:4]];
            [fileHandle synchronizeFile];
            [fileHandle closeFile];
        }
        //
        _finishedSize = receivedSize+self.receivedData.length;
    }
    else {
        NSUInteger receivedSize = [DLConnection receivedSizeOf:self.filePath];
        //将临时文件尾部的文件大小数据截断
        NSString *tempFilePath = TempFilePath_File(self.filePath);
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:tempFilePath];
        [fileHandle truncateFileAtOffset:receivedSize];
        [fileHandle closeFile];
        //修改文件名
        [[NSFileManager defaultManager] moveItemAtPath:tempFilePath toPath:self.filePath error:nil];
    }
    //
    [self performSelectorOnMainThread:@selector(saveDataFinishedOnMainThread)
                           withObject:nil waitUntilDone:YES];
}


#pragma mark - Private_MainThread

- (void)saveDataFinishedOnMainThread
{
    [self.delegate saveFileDataOperationFinished:self];
}

@end


#pragma mark - DLConnection

enum {
    NetDownloadType_None,
    NetDownloadType_FileSize,
    NetDownloadType_Download,
};
typedef NSInteger NetDownloadType;


@interface DLConnection () <HTTPConnectionDelegate, SaveFileDataOperationDelegate> {
    
    HTTPConnection *_httpDownload;
    
    NSMutableArray *_marrDownloadItem;
    NSMutableArray *_marrWaitItem;
    NSOperationQueue *_queueSaveData;
}

@end

@implementation DLConnection

- (id)init
{
    self = [super init];
    if (self) {
        self.maxNumberOfDLConnection = 5;
        _marrDownloadItem = [[NSMutableArray alloc] init];
        _marrWaitItem = [[NSMutableArray alloc] init];
        //
        _httpDownload = [[HTTPConnection alloc] init];
        _httpDownload.maxNumberOfURLConnection = 2;
        _httpDownload.delegate = self;
        //
        _queueSaveData = [[NSOperationQueue alloc] init];
        _queueSaveData.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)dealloc
{
    [_marrDownloadItem release];
    [_marrWaitItem release];
    [_httpDownload release];
    //
    [_queueSaveData release];
    
    [super dealloc];
}


#pragma mark - Public

// 文件下载状态
- (DownloadStatus)fileDownloadStatusWith:(NSString *)filePath andUrl:(NSString *)url
{
    if ([self containTaskWithFilePath:filePath andUrl:url
                              inArray:_marrDownloadItem]) {
        return DownloadStatus_Downloading;
    }
    else if ([self containTaskWithFilePath:filePath andUrl:url
                                   inArray:_marrWaitItem]) {
        return DownloadStatus_Waiting;
    }
    return DownloadStatus_NotExist;
}

// 下载文件到指定路径
- (void)downloadFile:(NSString *)filePath from:(NSString *)url
           withParam:(NSDictionary *)dicParam
{
    //下载或等待均不做处理
    DownloadStatus status = [self fileDownloadStatusWith:filePath andUrl:url];
    if (DownloadStatus_Downloading == status ||
        DownloadStatus_Waiting == status) {
        return;
    }
    //添加到等待队列
    if (dicParam) {
        [_marrWaitItem addObject:@{@"filepath": filePath, @"url": url,
         @"param": dicParam}];
    }
    else {
        [_marrWaitItem addObject:@{@"filepath": filePath, @"url": url}];
    }
    //从等待队列启动
    [self startNewTaskFromWaitQueue];
}

// 暂停下载文件
- (void)pauseDownloadFile:(NSString *)filePath from:(NSString *)url
{
    //从当前下载任务中移除
    if ([self removeTaskWithFilePath:filePath andUrl:url fromArray:_marrDownloadItem]) {
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
        //从等待队列启动其他任务
        [self startNewTaskFromWaitQueue];
    }
    else {
        [self removeTaskWithFilePath:filePath andUrl:url fromArray:_marrWaitItem];
    }
}

// 取消下载图书文件
- (void)cancelDownloadFile:(NSString *)filePath from:(NSString *)url
{
    //暂停下载
    [self pauseDownloadFile:filePath from:url];
    //删除临时文件
    NSString *tempFilePath = TempFilePath_File(filePath);
    [[NSFileManager defaultManager] removeItemAtPath:tempFilePath error:nil];
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
    NSString *filePath = [dicParam objectForKey:@"filePath"];
    NSString *url = [dicParam objectForKey:@"url"];
    //告知失败
    if ([self.delegate respondsToSelector:@selector(dlConnection:downloadFailure:withPath:url:andParam:)]) {
        NSDictionary *param = [self getParamWithFilePath:filePath andUrl:url
                                               fromArray:_marrDownloadItem];
        [self.delegate dlConnection:self downloadFailure:error
                           withPath:filePath url:url andParam:param];
    }
    //从下载队列移除
    [self removeTaskWithFilePath:filePath andUrl:url fromArray:_marrDownloadItem];
    //启动新任务
    [self startNewTaskFromWaitQueue];
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
                NSDictionary *param = [self getParamWithFilePath:filePath andUrl:url fromArray:_marrDownloadItem];
                [self.delegate dlConnection:self fileSize:fileSize withPath:filePath url:url andParam:param];
            }
            //启动下载任务
            [self startTaskWithFilePath:filePath andUrl:url];
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
            NSString *url = [dicParam objectForKey:@"url"];
            //
            SaveFileDataOperation *operation = [[SaveFileDataOperation alloc] init];
            operation.filePath = filePath;
            operation.url = url;
            operation.param = [self getParamWithFilePath:filePath andUrl:url fromArray:_marrDownloadItem];
            operation.receivedData = partData;
            operation.delegate = self;
            [_queueSaveData addOperation:operation];
            [operation release];
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
            NSString *url = [dicParam objectForKey:@"url"];
            //
            SaveFileDataOperation *operation = [[SaveFileDataOperation alloc] init];
            operation.filePath = filePath;
            operation.url = url;
            operation.param = [self getParamWithFilePath:filePath andUrl:url fromArray:_marrDownloadItem];
            operation.receivedData = nil;
            operation.delegate = self;
            [_queueSaveData addOperation:operation];
            [operation release];
            
            //从下载队列移除
            [self removeTaskWithFilePath:filePath andUrl:url
                               fromArray:_marrDownloadItem];
            //启动新任务
            [self startNewTaskFromWaitQueue];
        }
            break;
        default:
            break;
    }
}


#pragma mark - SaveFileDataOperationDelegate

// 数据保存完毕
- (void)saveFileDataOperationFinished:(SaveFileDataOperation *)operation
{
    if (operation.receivedData) {
        //通知下载进度
        if ([self.delegate respondsToSelector:@selector(dlConnection:receivedSize:withPath:url:andParam:)]) {
            [self.delegate dlConnection:self receivedSize:operation.finishedSize
                               withPath:operation.filePath url:operation.url
                               andParam:operation.param];
        }
    }
    else {
        //通知下载完成
        if ([self.delegate respondsToSelector:@selector(dlConnection:finishedWithPath:url:andParam:)]) {
            [self.delegate dlConnection:self finishedWithPath:operation.filePath
                                    url:operation.url andParam:operation.param];
        }
    }
}


#pragma mark - Private

- (void)startNewTaskFromWaitQueue
{
    if (_marrDownloadItem.count >= self.maxNumberOfDLConnection) {
#ifdef DEBUG
        NSLog(@"同时下载数达到最高，有%i个下载任务在等待", _marrWaitItem.count);
#endif
        return;
    }
    if (_marrWaitItem.count == 0) {
#ifdef DEBUG
        NSLog(@"没有等待的下载任务，当前有%i个任务在同时下载", _marrDownloadItem.count);
#endif
        return;
    }
    //将等待队列中的第一项移到下载队列
    NSDictionary *dicTask = [_marrWaitItem objectAtIndex:0];
    [_marrDownloadItem addObject:dicTask];
    [_marrWaitItem removeObjectAtIndex:0];
    
    //
    NSString *filePath = [dicTask objectForKey:@"filepath"];
    NSString *url = [dicTask objectForKey:@"url"];
    [self startTaskWithFilePath:filePath andUrl:url];
}

- (void)startTaskWithFilePath:(NSString *)filePath andUrl:(NSString *)url
{
    NSString *tempFilePath = TempFilePath_File(filePath);
    //如果临时文件不存在则先查看文件大小
    if (![[NSFileManager defaultManager] fileExistsAtPath:tempFilePath]) {
        //
        NSMutableURLRequest *mURLRequest = [[NSMutableURLRequest alloc] init];
        [mURLRequest setHTTPMethod:@"HEAD"];
        [mURLRequest setURL:[NSURL URLWithString:url]];
        NSDictionary *dicParam = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  [NSNumber numberWithInt:NetDownloadType_FileSize], @"type",
                                  filePath, @"filePath", url, @"url", nil];
        [_httpDownload requestWebDataWithRequest:mURLRequest andParam:dicParam
                                           cache:NO priority:YES];
        [mURLRequest release];
        [dicParam release];
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
        NSDictionary *dicParam = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  [NSNumber numberWithInt:NetDownloadType_Download], @"type",
                                  filePath, @"filePath", url, @"url", nil];
        [_httpDownload requestWebDataWithRequest:mURLRequest andParam:dicParam
                                           cache:NO priority:YES];
        [mURLRequest release];
        [dicParam release];
    }
}

// 是否包含任务
- (BOOL)containTaskWithFilePath:(NSString *)filePath andUrl:(NSString *)url
                        inArray:(NSArray *)array
{
    for (NSDictionary *dicItem in array) {
        if ([[dicItem objectForKey:@"filepath"] isEqualToString:filePath] &&
            [[dicItem objectForKey:@"url"] isEqualToString:url]) {
            return YES;
        }
    }
    return NO;
}

// 移除任务 
- (BOOL)removeTaskWithFilePath:(NSString *)filePath andUrl:(NSString *)url
                     fromArray:(NSMutableArray *)marray
{
    for (int i = 0; i < marray.count; i++) {
        NSDictionary *dicItem = [marray objectAtIndex:i];
        if ([[dicItem objectForKey:@"filepath"] isEqualToString:filePath] &&
            [[dicItem objectForKey:@"url"] isEqualToString:url]) {
            [marray removeObjectAtIndex:i];
            return YES;
        }
    }
    return NO;
}

// 获取参数
- (NSDictionary *)getParamWithFilePath:(NSString *)filePath andUrl:(NSString *)url
                             fromArray:(NSArray *)array
{
    for (NSDictionary *dicItem in array) {
        if ([[dicItem objectForKey:@"filepath"] isEqualToString:filePath] &&
            [[dicItem objectForKey:@"url"] isEqualToString:url]) {
            return [dicItem objectForKey:@"param"];
        }
    }
    return nil;
}

@end
