//
//  CoreEngine+Update.m
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "CoreEngine+Update.h"
#import "DBController+Update.h"
#import "AppSetting.h"
#import "AppSetting+Server.h"

@implementation CoreEngine (Update)

// 升级
- (void)update
{
    //获取当前用户信息版本号
    NSString *strOldVersion = [AppSetting userInfoVersion];
    NSUInteger oldVersion = [self versionID:strOldVersion];
    //获取当前软件版本号
    NSDictionary *dicSoftInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *strNewVersion = [dicSoftInfo objectForKey:@"CFBundleShortVersionString"];
    NSUInteger newVersion = [self versionID:strNewVersion];
    if (oldVersion == newVersion) {
        return;
    }
    [AppSetting oldVersion:strOldVersion];
    [AppSetting newVersion:strNewVersion];
    
    //保存当前用户信息版本号
    [AppSetting userInfoVersion:strNewVersion];
}


#pragma mark - Private

- (NSUInteger)versionID:(NSString *)strVersion
{
    if (nil == strVersion) {
        return 0;
    }
    NSUInteger versionMajor = 0, versionMinor = 0, versionBugFix = 0;
    //
    if (strVersion.length == 0) {
        return 0;
    }
    //
    NSArray *arrayVersion = [strVersion componentsSeparatedByString:@"."];
    //versionMajor
    if (arrayVersion.count > 0) {
        versionMajor = [[arrayVersion objectAtIndex:0] intValue];
    }
    //versionMinor
    if (arrayVersion.count > 1) {
        versionMinor = [[arrayVersion objectAtIndex:1] intValue];
    }
    //versionBugFix
    if (arrayVersion.count > 2) {
        versionBugFix = [[arrayVersion objectAtIndex:2] intValue];
    }
    //
    return 10000*versionMajor + 100*versionMinor + versionBugFix;
}

@end
