//
//  NetController.m
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "NetController.h"
#import "HTTPConnection.h"
#import "HTTPFile.h"
#import "JSONKit.h"


#define LOCALNET
//#undef LOCALNET

#define HOST_Interface     @"http://192.168.1.110"

#define UserInfoUrl     @"http://www.baidu.com?uid=%lld"


typedef NS_ENUM(NSUInteger, NetRequestType) {
    NetRequestType_None,
    NetRequestType_Login,
    NetRequestType_UserInfo,
};

@interface NetController () <HTTPConnectionDelegate, HTTPFileDelegate> {
    
    HTTPConnection *_httpConnection;
    HTTPFile *_httpFile;
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
        _httpFile = [[HTTPFile alloc] init];
        _httpFile.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    [_httpConnection release];
    [_httpFile release];
    
    [super dealloc];
}


#pragma mark - Public

// 登录
- (void)loginWithUserName:(NSString *)userName
              andPassword:(NSString *)password
{
    NSString *url = @"http://www.sina.com";
    NSDictionary *dicParam = @{@"type": [NSNumber numberWithInt:NetRequestType_Login]};
    [_httpConnection requestWebDataWithURL:url andParam:dicParam];
}

// 下载指定url的文件
- (void)downloadFile:(NSString *)filePath withUrl:(NSString *)url
{
    [_httpFile downloadFile:filePath from:url withParam:nil];
}

// 获取指定用户资料
- (void)getUserInfoOf:(UInt64)userID
{
    NSString *url = [NSString stringWithFormat:UserInfoUrl, userID];
    NSDictionary *dicParam = @{@"type": [NSNumber numberWithInt:NetRequestType_UserInfo],
                               @"userid": [NSNumber numberWithLongLong:userID]};
    [_httpConnection requestWebDataWithURL:url andParam:dicParam];
}


#pragma mark - HTTPConnectionDelegate

// 网络数据下载失败
- (void)httpConnect:(HTTPConnection *)httpConnect error:(NSError *)error with:(NSDictionary *)dicParam
{
    //网络请求类型
    NetRequestType requestType = [[dicParam objectForKey:@"type"] intValue];
    //
    switch (requestType) {
            //登录
        case NetRequestType_Login:
        {
            if ([self.delegate respondsToSelector:@selector(netController:loginError:)]) {
                [self.delegate netController:self loginError:error];
            }
        }
            break;
            //用户资料
        case NetRequestType_UserInfo:
        {
            if ([self.delegate respondsToSelector:@selector(netController:userInfoError:of:)]) {
                UInt64 userID = [[dicParam objectForKey:@"userid"] longLongValue];
                [self.delegate netController:self userInfoError:error of:userID];
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
            //登录
        case NetRequestType_Login:
        {
            if ([self.delegate respondsToSelector:@selector(netController:loginResult:)]) {
                NSString *strWebData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                [self.delegate netController:self loginResult:strWebData];
                [strWebData release];
            }
        }
            break;
            //用户资料
        case NetRequestType_UserInfo:
        {
            if ([self.delegate respondsToSelector:@selector(netController:userInfoResult:of:)]) {
                NSString *strWebData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                UInt64 userID = [[dicParam objectForKey:@"userid"] longLongValue];
                [self.delegate netController:self userInfoResult:strWebData of:userID];
                [strWebData release];
            }
        }
            break;
        default:
            break;
    }
}


#pragma mark - HTTPFileDelegate

// 下载失败
- (void)httpFile:(HTTPFile *)httpFile downloadFailure:(NSError *)error
            from:(NSString *)url withPath:(NSString *)filePath
        andParam:(NSDictionary *)param
{
    if ([self.delegate respondsToSelector:@selector(netController:downloadFileError:with:andUrl:)]) {
        [self.delegate netController:self downloadFileError:error with:filePath andUrl:url];
    }
}

// 得到文件实际大小
- (void)httpFile:(HTTPFile *)httpFile fileSize:(unsigned long)fileSize
            from:(NSString *)url withPath:(NSString *)filePath
        andParam:(NSDictionary *)param
{
}

// 下载进度发生变化
- (void)httpFile:(HTTPFile *)httpFile progressChanged:(float)progress
            from:(NSString *)url withPath:(NSString *)filePath
        andParam:(NSDictionary *)param
{
}

// 下载完成，下载到的文件不一定完整
- (void)httpFile:(HTTPFile *)httpFile downloadSuccess:(BOOL)success
            from:(NSString *)url withPath:(NSString *)filePath
        andParam:(NSDictionary *)param
{
    if ([self.delegate respondsToSelector:@selector(netController:downloadFileSuccessWith:andUrl:)]) {
        [self.delegate netController:self downloadFileSuccessWith:filePath andUrl:url];
    }
}

@end
