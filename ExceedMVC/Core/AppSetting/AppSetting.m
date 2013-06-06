//
//  AppSetting.m
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "AppSetting.h"

@implementation AppSetting

//当前版本号（用于升级）
+ (NSString *)userInfoVersion
{
	NSString *strVersion = @"0.0";
	//从配置文件中获取数据
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	//获取版本
	NSString *version = [userDefaults objectForKey:@"version"];
	//
	if (version.length > 0) {
		strVersion = [NSString stringWithString:version];
	}
	return strVersion;
}
+ (void)userInfoVersion:(NSString *)strVersion
{
	if (strVersion) {
		//配置保存到文件
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		//版本号
		[userDefaults setObject:strVersion forKey:@"version"];
		//同步数据
		[userDefaults synchronize];
	}
}

@end
