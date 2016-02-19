//
//  CoreEngine+Receive.m
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "CoreEngine+Receive.h"

@implementation CoreEngine (Receive)

// 网络原因登录失败
- (void)netController:(NetController *)netController loginError:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NetLoginFailure
                                                        object:nil];
}

// 登录返回数据
- (void)netController:(NetController *)netController loginResult:(NSDictionary *)userInfo
{
    //假设成功 
    [[NSNotificationCenter defaultCenter] postNotificationName:NetLoginSuccess object:nil userInfo:@{@"userInfo": userInfo}];
}

// 网络原因用户资料获取失败
- (void)netController:(NetController *)netController userInfoError:(NSError *)error of:(UInt64)userID
{
    NSDictionary *dicUserInfo = @{@"userid": @(userID), @"error": error};
    [[NSNotificationCenter defaultCenter] postNotificationName:NetUserInfoFailure object:nil userInfo:dicUserInfo];
}

// 获取用户资料返回数据
- (void)netController:(NetController *)netController userInfo:(NSDictionary *)userInfo of:(UInt64)userID
{
    //数据错误的话也是失败噢，这里以正确处理
    
    //是个网页数据，服务器端不通的情况下可以在这里加测试数据
    //需要先将数据保存到数据库噢
    //消息中心多发
    NSString *newUserName = [NSString stringWithFormat:@"好友%lld新名字", userID];
    NSDictionary *dicUserInfo = @{@"userid": @(userID),
                                  @"username": newUserName,
                                  @"avatar": @"http://avatar.csdn.net/0/E/4/1_yorhomwang.jpg"};
    [[NSNotificationCenter defaultCenter] postNotificationName:NetUserInfoSuccess object:nil userInfo:dicUserInfo];
}

@end
