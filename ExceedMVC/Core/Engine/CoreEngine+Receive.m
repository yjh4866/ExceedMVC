//
//  CoreEngine+Receive.m
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "CoreEngine+Receive.h"
#import "JSONKit.h"

@implementation CoreEngine (Receive)

// 网络原因用户资料获取失败
- (void)netController:(NetController *)netController userInfoError:(NSError *)error of:(UInt64)userID
{
    NSDictionary *dicUserInfo = @{@"userid": [NSNumber numberWithLongLong:userID],
                                  @"error": error};
    [[NSNotificationCenter defaultCenter] postNotificationName:NetUserInfoFailure object:nil userInfo:dicUserInfo];
}

// 网络原因用户资料获取失败
- (void)netController:(NetController *)netController userInfoSuccess:(NSString *)strWebData of:(UInt64)userID
{
    //是个网页数据，服务器端不通的情况下可以在这里加测试数据
    NSString *newUserName = [NSString stringWithFormat:@"好友%lld新名字", userID];
    NSDictionary *dicUserInfo = @{@"userid": [NSNumber numberWithLongLong:userID],
                                  @"username": newUserName,
                                  @"avatar": @"http://avatar.csdn.net/0/E/4/1_yorhomwang.jpg"};
    [[NSNotificationCenter defaultCenter] postNotificationName:NetUserInfoSuccess object:nil userInfo:dicUserInfo];
}

// 网络原因下载失败
- (void)netController:(NetController *)netController downloadFileError:(NSError *)error with:(NSString *)filePath andUrl:(NSString *)url
{
    NSDictionary *dicUserInfo = @{@"url": url,
                                  @"error": error};
    [[NSNotificationCenter defaultCenter] postNotificationName:NetDownloadFileFailure object:nil userInfo:dicUserInfo];
}

// 下载成功
- (void)netController:(NetController *)netController downloadFileSuccessWith:(NSString *)filePath andUrl:(NSString *)url
{
    NSDictionary *dicUserInfo = @{@"url": url};
    [[NSNotificationCenter defaultCenter] postNotificationName:NetDownloadFileSuccess object:nil userInfo:dicUserInfo];
}

@end
