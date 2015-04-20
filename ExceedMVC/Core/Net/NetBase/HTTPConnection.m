//
//  HTTPConnection.m
//  
//
//  Created by Jianhong Yang on 12-1-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HTTPConnection.h"


#define MaxNumber_URLConnection         10

#define TaskStatus_Run       @"Run"
#define TaskStatus_Wait      @"Wait"


@interface HTTPConnection () {
    NSMutableArray *_marrayTaskDic;
}
@property (nonatomic, assign) int numberOfURLConnection;
@end


@implementation HTTPConnection

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization.
        self.numberOfURLConnection = 0;
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
    for (NSDictionary *dicTask in _marrayTaskDic) {
        //
        if ([dicParam isEqualToDictionary:dicTask[@"param"]]) {
            return YES;
        }
    }
    return NO;
}

// 指定url是否在请求中
- (BOOL)urlIsRequesting:(NSString *)url
{
    for (NSDictionary *dicTask in _marrayTaskDic) {
        //
        NSURLConnection *connect = dicTask[@"connect"];
        if ([[[connect originalRequest].URL description] isEqualToString:url]) {
            return YES;
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
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *dataAD = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:&response
                                                           error:&error];
        [self.delegate httpConnect:self finish:dataAD with:dicParam];
        return YES;
    }
    if (nil == dicParam) {
        return NO;
    }
    // 正在处理或等待处理的任务不再接收
    for (NSDictionary *dicTask in _marrayTaskDic) {
        //
        if ([dicParam isEqualToDictionary:dicTask[@"param"]]) {
            HTTPLog(@"任务重复:%@", dicParam);
            return NO;
        }
    }
    
    HTTPLog(@"添加新任务，参数:%@", dicParam);
    NSMutableDictionary *mdicTask = [NSMutableDictionary dictionary];
    // 设置数据缓存
    NSMutableData *mdataCache = [NSMutableData data];
    [mdicTask setObject:mdataCache forKey:@"cache"];
    // 参数
    [mdicTask setObject:dicParam forKey:@"param"];
    // 状态
    [mdicTask setObject:TaskStatus_Wait forKey:@"status"];
    // 创建HTTP网络连接
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [mdicTask setObject:urlConnection forKey:@"connect"];
#if __has_feature(objc_arc)
#else
    [urlConnection release];
#endif
    // 将下载任务保存到数组
    [_marrayTaskDic addObject:mdicTask];
    
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
        // 查看任务是否相同
        NSDictionary *dicTask = _marrayTaskDic[i];
        if ([dicParam isEqualToDictionary:dicTask[@"param"]]) {
            // 取消网络请求
            NSURLConnection *connect = dicTask[@"connect"];
            // 未启动的须先启动再取消，不然有内存泄露
            if ([TaskStatus_Wait isEqualToString:dicTask[@"status"]]) {
                [connect start];
            }
            else {
                self.numberOfURLConnection -= 1;
            }
            [connect cancel];
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
    for (NSDictionary *dicTask in _marrayTaskDic) {
        NSURLConnection *connect = dicTask[@"connect"];
        // 未启动的须先启动再取消，不然有内存泄露
        if ([TaskStatus_Wait isEqualToString:dicTask[@"status"]]) {
            [connect start];
        }
        else {
            self.numberOfURLConnection -= 1;
        }
        [connect cancel];
    }
    // 从任务队列中删除
    [_marrayTaskDic removeAllObjects];
}


#pragma mark -
#pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    HTTPLog(@"网络请求错误:%@", error);
    // 找到当前失败的任务
    int indexTask = 0;
    NSDictionary *dicTask = nil;
    for (int i = 0; i < _marrayTaskDic.count; i++) {
        NSDictionary *dic = _marrayTaskDic[i];
        // 找到网络连接相应的数据字典
        if (dic[@"connect"] == connection) {
            indexTask = i;
            dicTask = dic;
            break;
        }
    }
    // 删除失败的任务
    if (dicTask) {
        // 删除
        NSDictionary *dicTempTask = [NSDictionary dictionaryWithDictionary:dicTask];
        self.numberOfURLConnection -= 1;
        [_marrayTaskDic removeObjectAtIndex:indexTask];
        // 启动新任务
        [self startURLConnection];
        // 通知上层任务失败
        if ([self.delegate respondsToSelector:@selector(httpConnect:error:with:)]) {
            [self.delegate httpConnect:self error:error with:dicTempTask[@"param"]];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    HTTPLog(@"网络请求收到响应");
    // 找到相应的任务
    NSDictionary *dicTask = nil;
    for (int i = 0; i < _marrayTaskDic.count; i++) {
        NSDictionary *dic = _marrayTaskDic[i];
        // 找到网络连接相应的数据字典
        if (dic[@"connect"] == connection) {
            dicTask = dic;
            break;
        }
    }
    //
    if ([response isMemberOfClass:NSHTTPURLResponse.class]) {
        NSHTTPURLResponse *responseHTTP = (NSHTTPURLResponse *)response;
        NSUInteger statusCode = responseHTTP.statusCode;
        NSDictionary *dicAllHeaderFields = responseHTTP.allHeaderFields;
        NSDictionary *dicParam = dicTask[@"param"];
        // 收到服务器返回的HTTP信息头
        if ([self.delegate respondsToSelector:@selector(httpConnect:receiveResponseWithStatusCode:andAllHeaderFields:with:)]) {
            [self.delegate httpConnect:self receiveResponseWithStatusCode:statusCode 
                    andAllHeaderFields:dicAllHeaderFields with:dicParam];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    HTTPLog(@"网络请求收到数据");
    // 找到相应的任务
    NSDictionary *dicTask = nil;
    for (int i = 0; i < _marrayTaskDic.count; i++) {
        NSDictionary *dic = _marrayTaskDic[i];
        // 找到网络连接相应的数据字典
        if (dic[@"connect"] == connection) {
            dicTask = dic;
            break;
        }
    }
    //
    if (dicTask) {
        // 向缓存中添加数据
        NSMutableData *mdataCache = dicTask[@"cache"];
        [mdataCache appendData:data];
        NSDictionary *dicParam = dicTask[@"param"];
        HTTPLog(@"该数据的参数：%@", dicParam);
        // 收到部分数据
        if ([self.delegate respondsToSelector:@selector(httpConnect:receivePartData:with:)]) {
            [self.delegate httpConnect:self receivePartData:data with:dicParam];
        }
    }
    HTTPLog(@"网络请求收到数据并处理完成");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    HTTPLog(@"网络请求完成");
    // 找到当前完成的任务
    int indexTask = 0;
    NSDictionary *dicTask = nil;
    for (int i = 0; i < _marrayTaskDic.count; i++) {
        NSDictionary *dic = _marrayTaskDic[i];
        // 找到网络连接相应的数据字典
        if (dic[@"connect"] == connection) {
            indexTask = i;
            dicTask = dic;
            break;
        }
    }
    // 删除已经完成的任务
    if (dicTask) {
        // 删除
        NSDictionary *dicTempTask = [NSDictionary dictionaryWithDictionary:dicTask];
        self.numberOfURLConnection -= 1;
        [_marrayTaskDic removeObjectAtIndex:indexTask];
        // 启动新任务
        [self startURLConnection];
        // 通知上层完成任务
        if ([self.delegate respondsToSelector:@selector(httpConnect:finish:with:)]) {
            NSData *dataCache = dicTempTask[@"cache"];
            NSDictionary *dicParam = dicTempTask[@"param"];
            [self.delegate httpConnect:self finish:dataCache with:dicParam];
        }
    }
}


#pragma mark - ()

- (void)startURLConnection
{
    if (self.numberOfURLConnection < self.maxNumberOfURLConnection) {
        if (self.numberOfURLConnection < _marrayTaskDic.count) {
            // 找到等待状态的任务
            for (NSMutableDictionary *mdicTask in _marrayTaskDic) {
                if ([TaskStatus_Wait isEqualToString:mdicTask[@"status"]]) {
                    // 修改状态
                    [mdicTask setObject:TaskStatus_Run forKey:@"status"];
                    // 启动
                    NSURLConnection *urlConnection = mdicTask[@"connect"];
                    [urlConnection start];
                    break;
                }
            }
            self.numberOfURLConnection += 1;
        }
    }
    HTTPLog(@"正在处理的网络请求数：%@，等待处理的网络请求：%@",
            @(self.numberOfURLConnection), @(_marrayTaskDic.count-self.numberOfURLConnection));
}

@end
