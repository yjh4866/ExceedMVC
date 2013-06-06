//
//  AppSetting+Server.m
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "AppSetting+Server.h"

@implementation AppSetting (Server)

//原版本
+ (void)oldVersion:(NSString *)oldVersion
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:oldVersion forKey:@"OldVersion"];
    [userDefaults synchronize];
}
+ (NSString *)oldVersion
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"OldVersion"];
}

//新版本
+ (void)newVersion:(NSString *)newVersion
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:newVersion forKey:@"NewVersion"];
    [userDefaults synchronize];
}
+ (NSString *)newVersion
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"NewVersion"];
}

@end
