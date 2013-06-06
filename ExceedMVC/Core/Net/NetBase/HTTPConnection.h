//
//  HTTPConnection.h
//  
//
//  Created by Jianhong Yang on 12-1-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol HTTPConnectionDelegate;

@interface HTTPConnection : NSObject {
@private
    
    id <HTTPConnectionDelegate> _delegate;
}

@property (nonatomic, assign) int maxNumberOfURLConnection;
@property (nonatomic, assign) id <HTTPConnectionDelegate> delegate;

/**
 *	@brief	判断指定参数的网络请求是否存在
 *
 *	@param 	dicParam 	网络请求查询依据
 *
 *	@return	指定网络请求是否已经存在
 */
- (BOOL)requestIsExist:(NSDictionary *)dicParam;

/**
 *	@brief	根据URL获取Web数据
 *
 *	@param 	strURL 	url
 *	@param 	dicParam 	网络请求所需参数
 *	@param 	cache 	是否缓存，如果是请求网页数据为YES，DLConnection中直接保存到文件才会使用NO
 *	@param 	priority 	是否优先处理
 *
 *	@return	请求是否成功，请求重复返回NO
 */
- (BOOL)requestWebDataWithURL:(NSString *)url andParam:(NSDictionary *)dicParam
                        cache:(BOOL)cache priority:(BOOL)priority;

/**
 *	@brief	根据URLRequest获取Web数据
 *
 *	@param 	request 	request
 *	@param 	dicParam 	网络请求所需参数
 *	@param 	cache 	是否缓存，如果是请求网页数据为YES，DLConnection中直接保存到文件才会使用NO
 *	@param 	priority 	是否优先处理
 *
 *	@return	请求是否成功，请求重复返回NO
 */
- (BOOL)requestWebDataWithRequest:(NSURLRequest *)request andParam:(NSDictionary *)dicParam
                            cache:(BOOL)cache priority:(BOOL)priority;

/**
 *	@brief	取消网络请求
 *
 *	@param 	dicParam 	网络请求所需参数
 *
 *	@return	dicParam为nil，或未查询到该请求，返回NO
 */
- (BOOL)cancelRequest:(NSDictionary *)dicParam;

/**
 *	@brief	清空网络请求
 */
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

#define HTTPLog(fmt,...)     NSLog((@"HTTP->%s(%d):"fmt),__PRETTY_FUNCTION__,__LINE__,##__VA_ARGS__)

#else

#define HTTPLog(fmt,...)     NSLog(fmt,##__VA_ARGS__)

#endif
