//
//  NetController.m
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "NetController.h"
#import "NBLHTTPManager.h"


#ifdef DEBUG
#define HOST_Interface     @"http://192.168.1.110"
#else
#define HOST_Interface     @"http://www.baidu.com"
#endif

#define UserInfoUrl     HOST_Interface @"?uid=%lld"


typedef NS_ENUM(NSUInteger, NetRequestType) {
    NetRequestType_None,
    NetRequestType_Login,
    NetRequestType_UserInfo,
};

@interface NetController ()

@end


@implementation NetController

+ (instancetype)sharedInstance
{
    static NetController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NetController alloc] init];
    });
    
    return sharedInstance;
}


#pragma mark - Public

// 登录
- (void)loginWithUserName:(NSString *)userName
              andPassword:(NSString *)password
{
    NSString *url = @"http://www.sina.com";
    [[NBLHTTPManager sharedManager] requestObject:NBLResponseObjectType_String fromURL:url withParam:@{@"type": @(NetRequestType_Login)} andResult:^(NSHTTPURLResponse *httpResponse, id responseObject, NSError *error, NSDictionary *dicParam) {
        if (responseObject) {
            if ([self.delegate respondsToSelector:@selector(netController:loginResult:)]) {
                [self.delegate netController:self loginResult:responseObject];
            }
        }
        else {
            if ([self.delegate respondsToSelector:@selector(netController:loginError:)]) {
                [self.delegate netController:self loginError:error];
            }
        }
    }];
}

// 获取指定用户资料
- (void)getUserInfoOf:(UInt64)userID
{
    NSString *url = [NSString stringWithFormat:UserInfoUrl, userID];
    [[NBLHTTPManager sharedManager] requestObject:NBLResponseObjectType_String fromURL:url withParam:@{@"type": @(NetRequestType_UserInfo), @"userid": @(userID)} andResult:^(NSHTTPURLResponse *httpResponse, id responseObject, NSError *error, NSDictionary *dicParam) {
        if (responseObject) {
            if ([self.delegate respondsToSelector:@selector(netController:userInfo:of:)]) {
                UInt64 userID = [dicParam[@"userid"] longLongValue];
                [self.delegate netController:self userInfo:responseObject of:userID];
            }
        }
        else {
            if ([self.delegate respondsToSelector:@selector(netController:userInfoError:of:)]) {
                UInt64 userID = [dicParam[@"userid"] longLongValue];
                [self.delegate netController:self userInfoError:error of:userID];
            }
        }
    }];
}

@end
