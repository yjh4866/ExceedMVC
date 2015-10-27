//
//  HTTPConnection.m
//  
//
//  Created by Jianhong Yang on 12-1-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HTTPConnection.h"
#import <UIKit/UIKit.h>


#define MaxNumber_URLConnection         10

#pragma mark -
#pragma mark - HTTPTaskItem
typedef NS_ENUM(unsigned int, HTTPTaskStatus) {
    HTTPTaskStatus_Running,
    HTTPTaskStatus_Waiting,
};
@interface HTTPTaskItem : NSObject {
    NSMutableData *_mdataCache;
}
@property (nonatomic, retain) NSURLConnection *urlConnection;
@property (nonatomic, retain) NSURLSessionDataTask *urlDataTask;
@property (nonatomic, assign) HTTPTaskStatus taskStatus;
@property (nonatomic, readonly) NSMutableData *mdataCache;
@property (nonatomic, retain) NSDictionary *param;
@end
#pragma mark - Implementation HTTPTaskItem
@implementation HTTPTaskItem
- (instancetype)init
{
    self = [super init];
    if (self) {
        _mdataCache = [[NSMutableData alloc] init];
    }
    return self;
}
- (void)dealloc
{
    self.urlConnection = nil;
    self.urlDataTask = nil;
    self.param = nil;
    //
#if __has_feature(objc_arc)
#else
    [_mdataCache release];
    [super dealloc];
#endif
}
@end


#pragma mark -
#pragma mark - Implementation HTTPConnection

@interface HTTPConnection () <NSURLSessionDataDelegate> {
    NSMutableArray *_marrayTaskDic;
}
@property (nonatomic, assign) int numberOfRequesting;
@end


@implementation HTTPConnection

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization.
        self.numberOfRequesting = 0;
        self.maxNumberOfURLConnection = MaxNumber_URLConnection;
        _marrayTaskDic = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return self;
}

- (void)dealloc
{
    // 清空任务
    self.delegate = nil;
    [self clearRequest];
    //
#if __has_feature(objc_arc)
#else
    [_marrayTaskDic release];
    
    [super dealloc];
#endif
}


#pragma mark - Public

// 判断指定参数的网络请求是否存在
- (BOOL)requestIsExist:(NSDictionary *)dicParam
{
    for (HTTPTaskItem *taskItem in _marrayTaskDic) {
        //
        if ([dicParam isEqualToDictionary:taskItem.param]) {
            return YES;
        }
    }
    return NO;
}

// 指定url是否在请求中
- (BOOL)urlIsRequesting:(NSString *)url
{
    for (HTTPTaskItem *taskItem in _marrayTaskDic) {
        // 先查看NSURLSessionDataTask
        if (taskItem.urlDataTask) {
            if ([[taskItem.urlDataTask.originalRequest.URL description] isEqualToString:url]) {
                return YES;
            }
        }
        else {
            if ([[taskItem.urlConnection.originalRequest.URL description] isEqualToString:url]) {
                return YES;
            }
        }
    }
    return NO;
}

// 根据URL获取Web数据
// dicParam 可用于回传数据。不得为空
- (BOOL)requestWebDataWithURL:(NSString *)strURL andParam:(NSDictionary *)dicParam
{
    if (nil == dicParam) {
        return NO;
    }

    // 实例化NSMutableURLRequest
    NSURL *url = [NSURL URLWithString:strURL];
    NSMutableURLRequest *mURLRequest = [NSMutableURLRequest requestWithURL:url];
    [mURLRequest setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    [mURLRequest setTimeoutInterval:10.0f];
    // 开始请求数据
    return [self requestWebDataWithRequest:mURLRequest andParam:dicParam];
}

// 根据URLRequest获取Web数据
// dicParam 可用于回传数据。不得为空
- (BOOL)requestWebDataWithRequest:(NSURLRequest *)request andParam:(NSDictionary *)dicParam
{
    // 非主线程取数据，直接同步获取，然后通过协议回调
    if ([NSThread currentThread] != [NSThread mainThread]) {
        if ([[UIDevice currentDevice].systemVersion floatValue] < 9.0) {
            NSURLResponse *response = nil;
            NSError *error = nil;
            NSData *dataAD = [NSURLConnection sendSynchronousRequest:request
                                                   returningResponse:&response
                                                               error:&error];
            [self.delegate httpConnect:self finish:dataAD with:dicParam];
        }
        else {
            [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error) {
                [self.delegate httpConnect:self finish:data with:dicParam];
            }];
        }
        return YES;
    }
    if (nil == dicParam) {
        return NO;
    }
    // 正在处理或等待处理的任务不再接收
    for (HTTPTaskItem *taskItem in _marrayTaskDic) {
        if ([dicParam isEqualToDictionary:taskItem.param]) {
            HTTPLog(@"任务重复:%@", dicParam);
            return NO;
        }
    }
    
    HTTPLog(@"添加新任务，参数:%@", dicParam);
    HTTPTaskItem *taskItem = [[HTTPTaskItem alloc] init];
    // 参数
    taskItem.param = dicParam;
    // 状态
    taskItem.taskStatus = HTTPTaskStatus_Waiting;
    // 创建HTTP网络连接
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0) {
        // 用NSURLConnection创建网络连接
        NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        taskItem.urlConnection = urlConnection;
#if __has_feature(objc_arc)
#else
        [urlConnection release];
#endif
    }
    else {
        // 用NSURLSessionDataTask创建网络连接
        taskItem.urlDataTask = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]] dataTaskWithRequest:request];
    }
    // 将下载任务保存到数组
    [_marrayTaskDic addObject:taskItem];
#if __has_feature(objc_arc)
#else
    [taskItem release];
#endif
    
    [self startURLConnection];
    return YES;
}

// 取消网络请求
- (BOOL)cancelRequest:(NSDictionary *)dicParam
{
    if (nil == dicParam) {
        return NO;
    }
    // 遍历所有任务
    for (int i = 0; i < _marrayTaskDic.count; i++) {
        HTTPTaskItem *taskItem = _marrayTaskDic[i];
        // 查看任务是否相同
        if ([dicParam isEqualToDictionary:taskItem.param]) {
            // 取消网络请求
            if (taskItem.urlDataTask) {
                // 直接取消即可
                [taskItem.urlDataTask cancel];
                self.numberOfRequesting -= 1;
            }
            else {
                // 未启动的须先启动再取消，不然有内存泄露
                if (HTTPTaskStatus_Waiting == taskItem.taskStatus) {
                    [taskItem.urlConnection start];
                }
                else {
                    self.numberOfRequesting -= 1;
                }
                [taskItem.urlConnection cancel];
            }
            // 从任务队列中删除
            [_marrayTaskDic removeObjectAtIndex:i];
            return YES;
        }
    }
    return NO;
}

// 清空网络请求
- (void)clearRequest
{
    // 遍历所有任务
    for (HTTPTaskItem *taskItem in _marrayTaskDic) {
        // 取消网络请求
        if (taskItem.urlDataTask) {
            // 直接取消即可
            [taskItem.urlDataTask cancel];
            self.numberOfRequesting -= 1;
        }
        else {
            // 未启动的须先启动再取消，不然有内存泄露
            if (HTTPTaskStatus_Waiting == taskItem.taskStatus) {
                [taskItem.urlConnection start];
            }
            else {
                self.numberOfRequesting -= 1;
            }
            [taskItem.urlConnection cancel];
        }
    }
    // 从任务队列中删除
    [_marrayTaskDic removeAllObjects];
}


#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    HTTPLog(@"网络请求错误:%@", error);
    // 找到当前失败的任务
    HTTPTaskItem *taskItem = nil;
    for (HTTPTaskItem *item in _marrayTaskDic) {
        // 根据网络连接查找
        if (item.urlConnection == connection) {
            taskItem = item;
            break;
        }
    }
    // 删除失败的任务
    if (taskItem) {
        // 删除
        NSDictionary *dicTempParam = [NSDictionary dictionaryWithDictionary:taskItem.param];
        self.numberOfRequesting -= 1;
        [_marrayTaskDic removeObjectIdenticalTo:taskItem];
        // 启动新任务
        [self startURLConnection];
        // 通知上层任务失败
        if ([self.delegate respondsToSelector:@selector(httpConnect:error:with:)]) {
            [self.delegate httpConnect:self error:error with:dicTempParam];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    HTTPLog(@"网络请求收到响应");
    // 找到相应的任务
    HTTPTaskItem *taskItem = nil;
    for (HTTPTaskItem *item in _marrayTaskDic) {
        // 根据网络连接查找
        if (item.urlConnection == connection) {
            taskItem = item;
            break;
        }
    }
    //
    if ([response isMemberOfClass:NSHTTPURLResponse.class]) {
        NSHTTPURLResponse *responseHTTP = (NSHTTPURLResponse *)response;
        // 收到服务器返回的HTTP信息头
        if ([self.delegate respondsToSelector:@selector(httpConnect:receiveResponseWithStatusCode:andAllHeaderFields:with:)]) {
            [self.delegate httpConnect:self receiveResponseWithStatusCode:responseHTTP.statusCode
                    andAllHeaderFields:responseHTTP.allHeaderFields with:taskItem.param];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    HTTPLog(@"网络请求收到数据");
    // 找到相应的任务
    HTTPTaskItem *taskItem = nil;
    for (HTTPTaskItem *item in _marrayTaskDic) {
        // 根据网络连接查找
        if (item.urlConnection == connection) {
            taskItem = item;
            break;
        }
    }
    //
    if (taskItem) {
        // 向缓存中添加数据
        [taskItem.mdataCache appendData:data];
        // 收到部分数据
        if ([self.delegate respondsToSelector:@selector(httpConnect:receivePartData:with:)]) {
            [self.delegate httpConnect:self receivePartData:data with:taskItem.param];
        }
    }
    HTTPLog(@"网络请求收到数据并处理完成");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    HTTPLog(@"网络请求完成");
    // 找到当前完成的任务
    HTTPTaskItem *taskItem = nil;
    for (HTTPTaskItem *item in _marrayTaskDic) {
        // 根据网络连接查找
        if (item.urlConnection == connection) {
            taskItem = item;
            break;
        }
    }
    // 删除已经完成的任务
    if (taskItem) {
        // 删除
        NSData *dataTempCache = [NSData dataWithData:taskItem.mdataCache];
        NSDictionary *dicTempParam = [NSDictionary dictionaryWithDictionary:taskItem.param];
        self.numberOfRequesting -= 1;
        [_marrayTaskDic removeObjectIdenticalTo:taskItem];
        // 启动新任务
        [self startURLConnection];
        // 通知上层完成任务
        if ([self.delegate respondsToSelector:@selector(httpConnect:finish:with:)]) {
            [self.delegate httpConnect:self finish:dataTempCache with:dicTempParam];
        }
    }
}


#pragma mark - NSURLSessionTaskDelegate

/* Sent as the last message related to a specific task.  Error may be
 * nil, which implies that no error occurred and this task is complete.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    // error为nil即表示任务完成
    if (nil == error) {
        HTTPLog(@"网络请求完成");
        // 找到当前完成的任务
        HTTPTaskItem *taskItem = nil;
        for (HTTPTaskItem *item in _marrayTaskDic) {
            // 根据网络连接查找
            if (item.urlDataTask == task) {
                taskItem = item;
                break;
            }
        }
        // 删除已经完成的任务
        if (taskItem) {
            // 删除
            NSData *dataTempCache = [NSData dataWithData:taskItem.mdataCache];
            NSDictionary *dicTempParam = [NSDictionary dictionaryWithDictionary:taskItem.param];
            self.numberOfRequesting -= 1;
            [_marrayTaskDic removeObjectIdenticalTo:taskItem];
            // 启动新任务
            [self startURLConnection];
            // 通知上层完成任务
            if ([self.delegate respondsToSelector:@selector(httpConnect:finish:with:)]) {
                [self.delegate httpConnect:self finish:dataTempCache with:dicTempParam];
            }
        }
        return;
    }
    // 取消请求不算错误
    if ([NSURLErrorDomain isEqualToString:error.domain] && NSURLErrorCancelled == error.code) {
        return;
    }
    HTTPLog(@"网络请求错误:%@", error);
    // 找到当前失败的任务
    HTTPTaskItem *taskItem = nil;
    for (HTTPTaskItem *item in _marrayTaskDic) {
        // 根据网络连接查找
        if (item.urlDataTask == task) {
            taskItem = item;
            break;
        }
    }
    // 删除失败的任务
    if (taskItem) {
        // 删除
        NSDictionary *dicTempParam = [NSDictionary dictionaryWithDictionary:taskItem.param];
        self.numberOfRequesting -= 1;
        [_marrayTaskDic removeObjectIdenticalTo:taskItem];
        // 启动新任务
        [self startURLConnection];
        // 通知上层任务失败
        if ([self.delegate respondsToSelector:@selector(httpConnect:error:with:)]) {
            [self.delegate httpConnect:self error:error with:dicTempParam];
        }
    }
}


#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    HTTPLog(@"网络请求收到响应");
    // 找到相应的任务
    HTTPTaskItem *taskItem = nil;
    for (HTTPTaskItem *item in _marrayTaskDic) {
        // 根据网络连接查找
        if (item.urlDataTask == dataTask) {
            taskItem = item;
            break;
        }
    }
    //
    if (taskItem && [response isMemberOfClass:NSHTTPURLResponse.class]) {
        NSHTTPURLResponse *responseHTTP = (NSHTTPURLResponse *)response;
        // 收到服务器返回的HTTP信息头
        if ([self.delegate respondsToSelector:@selector(httpConnect:receiveResponseWithStatusCode:andAllHeaderFields:with:)]) {
            [self.delegate httpConnect:self receiveResponseWithStatusCode:responseHTTP.statusCode
                    andAllHeaderFields:responseHTTP.allHeaderFields with:taskItem.param];
        }
    }
    if (completionHandler) {
        completionHandler(NSURLSessionResponseAllow);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    HTTPLog(@"网络请求收到数据");
    // 找到相应的任务
    HTTPTaskItem *taskItem = nil;
    for (HTTPTaskItem *item in _marrayTaskDic) {
        // 根据网络连接查找
        if (item.urlDataTask == dataTask) {
            taskItem = item;
            break;
        }
    }
    //
    if (taskItem) {
        // 向缓存中添加数据
        [taskItem.mdataCache appendData:data];
        // 收到部分数据
        if ([self.delegate respondsToSelector:@selector(httpConnect:receivePartData:with:)]) {
            [self.delegate httpConnect:self receivePartData:data with:taskItem.param];
        }
    }
    HTTPLog(@"网络请求收到数据并处理完成");
}


#pragma mark - Private

- (void)startURLConnection
{
    if (self.numberOfRequesting < self.maxNumberOfURLConnection) {
        if (self.numberOfRequesting < _marrayTaskDic.count) {
            // 找到等待状态的任务
            for (HTTPTaskItem *taskItem in _marrayTaskDic) {
                if (HTTPTaskStatus_Waiting == taskItem.taskStatus) {
                    // 修改状态
                    taskItem.taskStatus = HTTPTaskStatus_Running;
                    // 启动
                    if (taskItem.urlDataTask) {
                        [taskItem.urlDataTask resume];
                    }
                    else {
                        [taskItem.urlConnection start];
                    }
                    break;
                }
            }
            self.numberOfRequesting += 1;
        }
    }
    HTTPLog(@"正在处理的网络请求数：%@，等待处理的网络请求：%@",
            @(self.numberOfRequesting), @(_marrayTaskDic.count-self.numberOfRequesting));
}

@end
