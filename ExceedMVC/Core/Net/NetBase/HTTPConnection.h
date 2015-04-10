//
//  HTTPConnection.h
//  
//
//  Created by Jianhong Yang on 12-1-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol HTTPConnectionDelegate;

@interface HTTPConnection : NSObject

@property (nonatomic, assign) int maxNumberOfURLConnection;
@property (nonatomic, assign) id <HTTPConnectionDelegate> delegate;

// 判断指定参数的网络请求是否存在
- (BOOL)requestIsExist:(NSDictionary *)dicParam;

// 指定url是否在请求中
- (BOOL)urlIsRequesting:(NSString *)url;

// 根据URL获取Web数据
// dicParam 可用于回传数据。不得为空
- (BOOL)requestWebDataWithURL:(NSString *)strURL andParam:(NSDictionary *)dicParam;

// 根据URLRequest获取Web数据
// dicParam 可用于回传数据。不得为空
- (BOOL)requestWebDataWithRequest:(NSURLRequest *)request andParam:(NSDictionary *)dicParam;

// 取消网络请求
- (BOOL)cancelRequest:(NSDictionary *)dicParam;

// 清空网络请求
- (void)clearRequest;

@end


@protocol HTTPConnectionDelegate <NSObject>

@optional

// 网络数据下载失败
- (void)httpConnect:(HTTPConnection *)httpConnect error:(NSError *)error with:(NSDictionary *)dicParam;

// 服务器返回的HTTP信息头
- (void)httpConnect:(HTTPConnection *)httpConnect receiveResponseWithStatusCode:(NSInteger)statusCode
 andAllHeaderFields:(NSDictionary *)dicAllHeaderFields with:(NSDictionary *)dicParam;

// 接收到部分数据
- (void)httpConnect:(HTTPConnection *)httpConnect receivePartData:(NSData *)partData with:(NSDictionary *)dicParam;

// 网络数据下载完成
- (void)httpConnect:(HTTPConnection *)httpConnect finish:(NSData *)data with:(NSDictionary *)dicParam;

@end


#ifdef DEBUG

#define HTTPLog(fmt,...)     NSLog((@"HTTP->%s(%d):" fmt),__PRETTY_FUNCTION__,__LINE__,##__VA_ARGS__)

#else

#define HTTPLog(fmt,...)     

#endif
