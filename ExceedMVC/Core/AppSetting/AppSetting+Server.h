//
//  AppSetting+Server.h
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "AppSetting.h"

@interface AppSetting (Server)

//原版本
+ (void)oldVersion:(NSString *)oldVersion;
+ (NSString *)oldVersion;

//新版本
+ (void)newVersion:(NSString *)newVersion;
+ (NSString *)newVersion;

@end
