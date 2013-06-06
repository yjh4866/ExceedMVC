//
//  NetController.m
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "NetController.h"
#import "HTTPConnection.h"
#import "DLConnection.h"
#import "JSONKit.h"


#define LOCALNET
//#undef LOCALNET

#define HOST_Interface     @"http://dp.sina.cn/interface/f/blog/"


typedef NS_ENUM(NSUInteger, NetRequestType) {
    NetRequestType_None, 
};

@interface NetController () <HTTPConnectionDelegate, DLConnectionDelegate> {
    
    HTTPConnection *_httpConnection;
    DLConnection *_downloadConnection;
}

@end


@implementation NetController

- (id)init
{
    self = [super init];
    if (self) {
        //
        _httpConnection = [[HTTPConnection alloc] init];
        _httpConnection.delegate = self;
        _downloadConnection = [[DLConnection alloc] init];
        _downloadConnection.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    [_httpConnection release];
    [_downloadConnection release];
    
    [super dealloc];
}


#pragma mark - Public


#pragma mark - HTTPConnectionDelegate

// 网络数据下载失败
- (void)httpConnect:(HTTPConnection *)httpConnect error:(NSError *)error with:(NSDictionary *)dicParam
{
    //网络请求类型
    NetRequestType requestType = [[dicParam objectForKey:@"type"] intValue];
    //
    switch (requestType) {
        default:
            break;
    }
}

// 服务器返回的HTTP信息头
- (void)httpConnect:(HTTPConnection *)httpConnect receiveResponseWithStatusCode:(NSInteger)statusCode
 andAllHeaderFields:(NSDictionary *)dicAllHeaderFields with:(NSDictionary *)dicParam
{
    //网络请求类型
    NetRequestType requestType = [[dicParam objectForKey:@"type"] intValue];
    //
    switch (requestType) {
        default:
            break;
    }
}

// 接收到部分数据
- (void)httpConnect:(HTTPConnection *)httpConnect receivePartData:(NSData *)partData with:(NSDictionary *)dicParam
{
    //网络请求类型
    NetRequestType requestType = [[dicParam objectForKey:@"type"] intValue];
    //
    switch (requestType) {
        default:
            break;
    }
}

// 网络数据下载完成
- (void)httpConnect:(HTTPConnection *)httpConnect finish:(NSData *)data with:(NSDictionary *)dicParam
{
    //网络请求类型
    NetRequestType requestType = [[dicParam objectForKey:@"type"] intValue];
    //
    switch (requestType) {
        default:
            break;
    }
}


#pragma mark - DLConnectionDelegate

// 下载失败
- (void)dlConnection:(DLConnection *)dlConnection downloadFailure:(NSError *)error
            withPath:(NSString *)filePath andUrl:(NSString *)url
{
}

// 得到文件实际大小
- (void)dlConnection:(DLConnection *)dlConnection fileSize:(NSUInteger)fileSize
            withPath:(NSString *)filePath andUrl:(NSString *)url
{
}

// 收到的数据发生变化
- (void)dlConnection:(DLConnection *)dlConnection receivedSize:(NSUInteger)receivedSize
            withPath:(NSString *)filePath andUrl:(NSString *)url
{
}

// 下载完成
- (void)dlConnection:(DLConnection *)dlConnection finishedWithPath:(NSString *)filePath
              andUrl:(NSString *)url
{
}

@end
