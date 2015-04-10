//
//  HTTPFile.m
//
//
//  Created by Jianhong Yang on 15/1/26.
//  Copyright (c) 2015年 __MyCompanyName__. All rights reserved.
//

#import "HTTPFile.h"
#import "HTTPConnection.h"


#define FilePath_Temp(filePath)      [filePath stringByAppendingPathExtension:@"DownloadTemp"]
#define RetryCount_DownloadPartFile  1


#pragma mark - HTTPFile

typedef NS_ENUM(unsigned int, NetDownloadType) {
    NetDownloadType_FileSize = 1,
    NetDownloadType_Download,
};

@interface HTTPFile () <HTTPConnectionDelegate> {
    HTTPConnection *_httpDownload;
    
    NSMutableArray *_marrDownloadTask;
}
@end

@implementation HTTPFile

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.sizePartFile = 256*1024;
        _httpDownload = [[HTTPConnection alloc] init];
        _httpDownload.delegate = self;
        //
        _marrDownloadTask = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
#if __has_feature(objc_arc)
#else
    [_httpDownload release];
    [_marrDownloadTask release];
    
    [super dealloc];
#endif
}


#pragma mark - Public

// 文件下载状态
- (DownloadStatus)downloadStatusWith:(NSString *)filePath andUrl:(NSString *)url
{
    int taskIndex = [self taskIndexWithFilePath:filePath andUrl:url inArray:_marrDownloadTask];
    if (taskIndex >= 0) {
        return taskIndex>0?DownloadStatus_Waiting:DownloadStatus_Downloading;
    }
    return DownloadStatus_NotExist;
}

// 下载文件到指定路径
- (void)downloadFile:(NSString *)filePath from:(NSString *)url
           withParam:(NSDictionary *)param
{
    // 已经在任务队列中则不做处理
    if ([self taskIndexWithFilePath:filePath andUrl:url inArray:_marrDownloadTask] >= 0) {
        return;
    }
    
    // 添加到任务队列
    NSMutableDictionary *mdicTask = [NSMutableDictionary dictionaryWithObjectsAndKeys:filePath, @"filepath",
                                     url, @"url", param, @"param", nil];
    [_marrDownloadTask addObject:mdicTask];
    // 如果临时文件存在，则从中提取任务信息并添加到下载队列
    BOOL needHeadRequest = YES;
    NSString *filePathTemp = FilePath_Temp(filePath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePathTemp]) {
        // 先获取实际文件大小（实际文件大小+配置数据+4字节的实际文件大小）
        unsigned long fileSize = 0;
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePathTemp];
        unsigned long tempFileSize = (unsigned long)[fileHandle seekToEndOfFile];
        [fileHandle seekToFileOffset:tempFileSize-4];
        NSData *dataFileSize = [fileHandle readDataOfLength:4];
        [dataFileSize getBytes:&fileSize length:4];
        // 再获取任务信息数据
        [fileHandle seekToFileOffset:fileSize];
        NSData *dataTaskInfo = [fileHandle readDataOfLength:tempFileSize-fileSize-4];
        [fileHandle closeFile];
        // 转成任务信息字典
        NSMutableDictionary *mdicTaskInfo = [NSJSONSerialization JSONObjectWithData:dataTaskInfo options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        // 任务信息错误
        needHeadRequest = nil==mdicTaskInfo;
        if (mdicTaskInfo) {
            // 将任务信息保存到任务中
            [mdicTask setObject:mdicTaskInfo forKey:@"TaskInfo"];
            // 遍历任务项队列并添加到下载队列
            NSMutableArray *marrTaskItem = mdicTaskInfo[@"List"];
            [self addURLRequestFromTaskItemList:marrTaskItem withUrl:url];
        }
    }
    // 否则先获取文件大小
    if (needHeadRequest) {
        [[NSFileManager defaultManager] removeItemAtPath:filePathTemp error:nil];
        // 创建URLRequest
        NSMutableURLRequest *mURLRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        [mURLRequest setHTTPMethod:@"HEAD"];
        [mURLRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [mURLRequest setValue:@"" forHTTPHeaderField:@"Accept-Encoding"];
        [mURLRequest setTimeoutInterval:30.0f];
        // 开始下载
        NSDictionary *dicParam = [NSDictionary dictionaryWithObjectsAndKeys:filePath, @"filepath", url, @"url", @(NetDownloadType_FileSize), @"type", param, @"param", nil];
        [_httpDownload requestWebDataWithRequest:mURLRequest andParam:dicParam];
    }
}

// 取消下载
- (void)cancelDownloadFile:(NSString *)filePath from:(NSString *)url
                 withParam:(NSDictionary *)param
{
    // 任务队列中不存在则不作处理
    int taskIndex = [self taskIndexWithFilePath:filePath andUrl:url inArray:_marrDownloadTask];
    if (taskIndex < 0) {
        return;
    }
    // 取消可能存在的HEAD请求
    NSDictionary *dicParam = [NSDictionary dictionaryWithObjectsAndKeys:filePath, @"filepath", url, @"url", @(NetDownloadType_FileSize), @"type", param, @"param", nil];
    [_httpDownload cancelRequest:dicParam];
    // 取消可能存在的部分文件下载请求
    NSDictionary *dicTask = _marrDownloadTask[taskIndex];
    NSDictionary *dicTaskInfo = dicTask[@"TaskInfo"];
    NSArray *arrTaskItem = dicTaskInfo[@"List"];
    for (NSDictionary *dicItem in arrTaskItem) {
        unsigned int start = [dicItem[@"Start"] intValue];
        unsigned int length = [dicItem[@"Len"] intValue];
        for (int i = 0; i <= RetryCount_DownloadPartFile; i++) {
            NSDictionary *dicParam = @{@"type": @(NetDownloadType_Download), @"url": url,
                                       @"start": @(start), @"len": @(length), @"errcount": @(i)};
            [_httpDownload cancelRequest:dicParam];
        }
    }
    // 移除任务
    [_marrDownloadTask removeObjectAtIndex:taskIndex];
}

// 查看指定路径的文件大小
+ (unsigned long)fileSizeOf:(NSString *)filePath
{
    unsigned long fileSize = 0;
    // 该路径下的文件存在，则该文件大小即为文件大小
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    if ([defaultManager fileExistsAtPath:filePath]) {
        NSDictionary *dicAttributes = [defaultManager attributesOfItemAtPath:filePath error:nil];
        fileSize = [dicAttributes[NSFileSize] intValue];
    }
    else {
        // 如果该路径对应的临时文件存在
        NSString *filePathTemp = FilePath_Temp(filePath);
        if ([defaultManager fileExistsAtPath:filePathTemp]) {
            // 临时文件最后四个字节，为文件大小
            NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePathTemp];
            unsigned long long tempFileSize = [fileHandle seekToEndOfFile];
            [fileHandle seekToFileOffset:tempFileSize-4];
            NSData *dataFileSize = [fileHandle readDataOfLength:4];
            [dataFileSize getBytes:&fileSize length:4];
            [fileHandle closeFile];
        }
    }
    return fileSize;
}

// 查看指定路径的文件已经下载到的大小
+ (unsigned long)receivedSizeOf:(NSString *)filePath
{
    unsigned long receivedSize = 0;
    // 该路径下的文件存在，则该文件大小即为下载到的文件大小
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    if ([defaultManager fileExistsAtPath:filePath]) {
        NSDictionary *dicAttributes = [defaultManager attributesOfItemAtPath:filePath error:nil];
        receivedSize = [dicAttributes[NSFileSize] intValue];
    }
    else {
        // 如果该路径对应的临时文件存在
        NSString *filePathTemp = FilePath_Temp(filePath);
        if ([defaultManager fileExistsAtPath:filePathTemp]) {
            // 先获取实际文件大小（实际文件大小+配置数据+4字节的实际文件大小）
            unsigned long fileSize = 0;
            NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePathTemp];
            unsigned long tempFileSize = (unsigned long)[fileHandle seekToEndOfFile];
            [fileHandle seekToFileOffset:tempFileSize-4];
            NSData *dataFileSize = [fileHandle readDataOfLength:4];
            [dataFileSize getBytes:&fileSize length:4];
            // 再获取任务信息
            [fileHandle seekToFileOffset:fileSize];
            NSData *dataTaskInfo = [fileHandle readDataOfLength:tempFileSize-fileSize-4];
            // 转成任务信息字典
            NSDictionary *dicTaskInfo = [NSJSONSerialization JSONObjectWithData:dataTaskInfo options:NSJSONReadingAllowFragments error:nil];
            for (NSDictionary *dicItem in dicTaskInfo[@"List"]) {
                if ([dicItem[@"Success"] boolValue]) {
                    receivedSize += [dicItem[@"Len"] intValue];
                }
            }
            [fileHandle closeFile];
        }
    }
    return receivedSize;
}


#pragma mark - HTTPConnectionDelegate

// 网络数据下载失败
- (void)httpConnect:(HTTPConnection *)httpConnect error:(NSError *)error with:(NSDictionary *)dicParam
{
    switch ([dicParam[@"type"] intValue]) {
            // 查看文件大小
        case NetDownloadType_FileSize:
        {
            NSString *filePath = dicParam[@"filepath"];
            NSString *url = dicParam[@"url"];
            // 文件大小获取失败，则表示文件下载直接失败
            for (long i = _marrDownloadTask.count-1; i >= 0; i--) {
                NSDictionary *dicItem = _marrDownloadTask[i];
                if ([dicItem[@"filepath"] isEqualToString:filePath] &&
                    [dicItem[@"url"] isEqualToString:url]) {
                    // 移除任务
                    NSDictionary *dicTempParam = nil;
                    if (dicItem[@"param"] && [dicItem[@"param"] isKindOfClass:NSDictionary.class]) {
                        dicTempParam = [NSDictionary dictionaryWithDictionary:dicItem[@"param"]];
                    }
                    [_marrDownloadTask removeObjectAtIndex:i];
                    // 回调下载错误
                    [self.delegate httpFile:self downloadFailure:error from:url
                                   withPath:filePath andParam:dicTempParam];
                }
            }
        }
            break;
            // 保存文件数据
        case NetDownloadType_Download:
        {
            // errcount表示失败次数
            int errCount = [dicParam[@"errcount"] intValue];
            // 失败次数达到指定数，则不再下载
            if (errCount >= RetryCount_DownloadPartFile) {
                // 下载完成
                [self downloadFileFinishedWithPartData:nil orError:error andParam:dicParam];
            }
            // 否则再下载一次
            else {
                unsigned int start = [dicParam[@"start"] intValue];
                unsigned int len = [dicParam[@"len"] intValue];
                NSString *url = dicParam[@"url"];
                // 再次下载文件的这部分
                [self downloadPartFile:url withStart:start length:len andErrorCount:errCount+1];
            }
        }
            break;
        default:
            break;
    }
}

// 服务器返回的HTTP信息头
- (void)httpConnect:(HTTPConnection *)httpConnect receiveResponseWithStatusCode:(NSInteger)statusCode
 andAllHeaderFields:(NSDictionary *)dicAllHeaderFields with:(NSDictionary *)dicParam
{
    switch ([dicParam[@"type"] intValue]) {
            // 查看文件大小
        case NetDownloadType_FileSize:
        {
            NSString *filePath = dicParam[@"filepath"];
            NSString *url = dicParam[@"url"];
            unsigned int fileSize = [dicAllHeaderFields[@"Content-Length"] intValue];
            // 文件大小太小，只有一个字节，按文件错误处理
            if (fileSize < 1) {
                // 文件下载直接失败
                for (long i = _marrDownloadTask.count-1; i >= 0; i--) {
                    NSDictionary *dicItem = _marrDownloadTask[i];
                    if ([dicItem[@"filepath"] isEqualToString:filePath] &&
                        [dicItem[@"url"] isEqualToString:url]) {
                        // 移除任务
                        NSDictionary *dicTempParam = nil;
                        if (dicItem[@"param"] && [dicItem[@"param"] isKindOfClass:NSDictionary.class]) {
                            dicTempParam = [NSDictionary dictionaryWithDictionary:dicItem[@"param"]];
                        }
                        [_marrDownloadTask removeObjectAtIndex:i];
                        // 回调下载错误
                        NSError *error = [NSError errorWithDomain:@"HTTPFile" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"文件错误"}];
                        [self.delegate httpFile:self downloadFailure:error from:url
                                       withPath:filePath andParam:dicTempParam];
                    }
                }
                return;
            }
            // 文件大小回调
            [self.delegate httpFile:self fileSize:fileSize from:url
                           withPath:filePath andParam:dicParam[@"param"]];
            // 生成任务项列表
            NSMutableArray *marrTaskItem = [NSMutableArray array];
            if (self.sizePartFile < 4*1024) {
                self.sizePartFile = 4*1024;
            }
            unsigned int taskItemCount = ceilf(1.0f*fileSize/self.sizePartFile); // 每一个任务项大小
            unsigned int taskItemLen = fileSize/taskItemCount;
            for (int i = 0; i < taskItemCount-1; i++) {
                [marrTaskItem addObject:@{@"Start": @(i*taskItemLen), @"Len": @(taskItemLen)}];
            }
            unsigned int startLast = (taskItemCount-1)*taskItemLen;
            [marrTaskItem addObject:@{@"Start": @(startLast), @"Len": @(fileSize-startLast)}];
            // 生成任务信息保存到任务列表
            NSMutableDictionary *mdicTaskInfo = [NSMutableDictionary dictionaryWithDictionary:@{@"FileSize": @(fileSize), @"List": marrTaskItem, @"Count": @(marrTaskItem.count)}];
            for (int i = 0; i < _marrDownloadTask.count; i++) {
                NSMutableDictionary *mdicTask = _marrDownloadTask[i];
                if ([filePath isEqualToString:mdicTask[@"filepath"]] &&
                    [url isEqualToString:mdicTask[@"url"]]) {
                    [mdicTask setObject:mdicTaskInfo forKey:@"TaskInfo"];
                }
            }
            {
                // 生成临时文件
                NSString *filePathTemp = FilePath_Temp(filePath);
                [[NSFileManager defaultManager] createFileAtPath:filePathTemp contents:nil attributes:nil];
                // 保存临时文件数据
                NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePathTemp];
                // 跳过实际文件数据区，保存任务信息
                [fileHandle seekToFileOffset:fileSize];
                NSData *dataTaskInfo = [NSJSONSerialization dataWithJSONObject:mdicTaskInfo options:NSJSONWritingPrettyPrinted error:nil];
                [fileHandle writeData:dataTaskInfo];
                // 保存文件大小
                [fileHandle seekToFileOffset:fileSize+dataTaskInfo.length];
                [fileHandle writeData:[NSData dataWithBytes:&fileSize length:4]];
                // 掐掉可能多余的数据
                [fileHandle truncateFileAtOffset:fileSize+dataTaskInfo.length+4];
                [fileHandle closeFile];
            }
            // 遍历任务项队列并添加到下载队列
            [self addURLRequestFromTaskItemList:marrTaskItem withUrl:url];
            
        }
            break;
        default:
            break;
    }
}

// 网络数据下载完成
- (void)httpConnect:(HTTPConnection *)httpConnect finish:(NSData *)data with:(NSDictionary *)dicParam
{
    switch ([dicParam[@"type"] intValue]) {
            // 保存文件数据
        case NetDownloadType_Download:
        {
            // 下载完成
            [self downloadFileFinishedWithPartData:data orError:nil andParam:dicParam];
        }
            break;
        default:
            break;
    }
}


#pragma mark - Private

// 遍历任务项队列并添加到下载队列
- (void)addURLRequestFromTaskItemList:(NSMutableArray *)marrTaskItem withUrl:(NSString *)url
{
    // 遍历任务项队列
    for (int i = 0; i < marrTaskItem.count; i++) {
        NSDictionary *dicItem = marrTaskItem[i];
        BOOL success = [dicItem[@"Success"] boolValue];
        // 只下载不成功的数据段
        if (!success) {
            unsigned int start = [dicItem[@"Start"] intValue];
            unsigned int len = [dicItem[@"Len"] intValue];
            // 标记为加载中
            NSMutableDictionary *mdicItem = [NSMutableDictionary dictionaryWithDictionary:dicItem];
            [mdicItem setObject:@(YES) forKey:@"Loading"];
            [marrTaskItem replaceObjectAtIndex:i withObject:mdicItem];
            // 下载文件的一部分
            [self downloadPartFile:url withStart:start length:len andErrorCount:0];
        }
    }
}

// 下载文件的一部分
- (void)downloadPartFile:(NSString *)url withStart:(unsigned int)start length:(unsigned int)length
           andErrorCount:(unsigned int)errorCount
{
    // 创建URLRequest
    NSMutableURLRequest *mURLRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [mURLRequest setValue:[NSString stringWithFormat:@"bytes=%@-%@", @(start), @(start+length-1)]
       forHTTPHeaderField:@"RANGE"];
    [mURLRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [mURLRequest setValue:@"" forHTTPHeaderField:@"Accept-Encoding"];
    [mURLRequest setTimeoutInterval:30.0f];
    // 开始下载
    NSDictionary *dicParam = @{@"type": @(NetDownloadType_Download), @"url": url,
                               @"start": @(start), @"len": @(length), @"errcount": @(errorCount)};
    [_httpDownload requestWebDataWithRequest:mURLRequest andParam:dicParam];
}

// 下载部分文件结束
- (void)downloadFileFinishedWithPartData:(NSData *)data orError:(NSError *)error
                                andParam:(NSDictionary *)dicParam
{
    NSString *url = dicParam[@"url"];
    for (long i = _marrDownloadTask.count-1; i >= 0; i--) {
        NSMutableDictionary *mdicTask = _marrDownloadTask[i];
        if ([url isEqualToString:mdicTask[@"url"]]) {
            NSString *filePath = mdicTask[@"filepath"];
            unsigned int start = [dicParam[@"start"] intValue];
            // 有下载到数据，则保存到临时文件
            NSString *filePathTemp = FilePath_Temp(filePath);
            if (data.length > 0) {
                NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePathTemp];
                [fileHandle seekToFileOffset:start];
                [fileHandle writeData:data];
                [fileHandle closeFile];
            }
            // 如果下载失败则记一次失败次数
            if (error) {
                unsigned int errCount = [mdicTask[@"ErrorCount"] intValue];
                [mdicTask setObject:@(errCount+1) forKey:@"ErrorCount"];
            }
            // 找到相应的任务项，修改成功标记
            NSMutableDictionary *mdicTaskInfo = mdicTask[@"TaskInfo"];
            NSMutableArray *marrTaskItem = mdicTaskInfo[@"List"];
            for (int i = 0; i < marrTaskItem.count; i++) {
                NSDictionary *dicItem = marrTaskItem[i];
                if ([dicItem[@"Start"] intValue] == start) {
                    NSMutableDictionary *mdicItem = [NSMutableDictionary dictionaryWithDictionary:dicItem];
                    [mdicItem setObject:@(nil==error) forKey:@"Success"];
                    [mdicItem removeObjectForKey:@"Loading"];
                    [marrTaskItem replaceObjectAtIndex:i withObject:mdicItem];
                    break;
                }
            }
            // 计算下载进度并回调
            BOOL downloadFinished = YES;
            unsigned int fileSize = [mdicTaskInfo[@"FileSize"] intValue];
            unsigned int receivedSize = 0;
            for (NSDictionary *dicItem in marrTaskItem) {
                if ([dicItem[@"Success"] boolValue]) {
                    receivedSize += [dicItem[@"Len"] intValue];
                }
                if (downloadFinished && [dicItem[@"Loading"] boolValue]) {
                    downloadFinished = NO;
                }
            }
            [self.delegate httpFile:self progressChanged:fileSize>0?(1.0f*receivedSize/fileSize):0.0f
                               from:url withPath:filePath andParam:mdicTask[@"param"]];
            // 所有的文件下载任务均完成，则结束任务
            if (downloadFinished) {
                // 从任务队列中删除
                NSDictionary *dicTempTask = [NSDictionary dictionaryWithDictionary:mdicTask];
                [_marrDownloadTask removeObjectAtIndex:i];
                // 不是所有请求都失败，则可以认为下载成功
                unsigned int totalCount = [mdicTaskInfo[@"Count"] intValue];
                unsigned int errCount = [dicTempTask[@"ErrorCount"] intValue];
                if (totalCount != errCount) {
                    // 错误数为0表示文件下载完整，不存在数据错误
                    if (0 == errCount) {
                        // 将临时文件修改为正式文件
                        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePathTemp];
                        [fileHandle truncateFileAtOffset:fileSize];
                        [fileHandle closeFile];
                        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                        [[NSFileManager defaultManager] moveItemAtPath:filePathTemp toPath:filePath error:nil];
                        // 回调下载成功
                        [self.delegate httpFile:self downloadSuccess:YES
                                           from:url withPath:filePath andParam:dicTempTask[@"param"]];
                    }
                    else {
                        [self.delegate httpFile:self downloadSuccess:NO
                                           from:url withPath:filePath andParam:dicTempTask[@"param"]];
                    }
                }
                // 所有请求都失败则表示下载失败
                else {
                    [self.delegate httpFile:self downloadFailure:error from:url
                                   withPath:filePath andParam:dicTempTask[@"param"]];
                }
            }
            // 否则将任务信息更新到临时文件
            else {
                // 保存临时文件数据
                NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePathTemp];
                // 跳过实际文件数据区，保存任务信息
                [fileHandle seekToFileOffset:fileSize];
                NSData *dataTaskInfo = [NSJSONSerialization dataWithJSONObject:mdicTaskInfo options:NSJSONWritingPrettyPrinted error:nil];
                [fileHandle writeData:dataTaskInfo];
                // 保存文件大小
                [fileHandle seekToFileOffset:fileSize+dataTaskInfo.length];
                [fileHandle writeData:[NSData dataWithBytes:&fileSize length:4]];
                // 掐掉可能多余的数据
                [fileHandle truncateFileAtOffset:fileSize+dataTaskInfo.length+4];
                [fileHandle closeFile];
            }
        }
    }
}

// 是否包含任务
- (int)taskIndexWithFilePath:(NSString *)filePath andUrl:(NSString *)url
                     inArray:(NSArray *)array
{
    for (int i = 0; i < array.count; i++) {
        NSDictionary *dicItem = array[i];
        if ([dicItem[@"filepath"] isEqualToString:filePath] &&
            [dicItem[@"url"] isEqualToString:url]) {
            return i;
        }
    }
    return -1;
}

@end
