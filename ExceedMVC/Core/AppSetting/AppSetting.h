//
//  AppSetting.h
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppSetting : NSObject

//当前版本号（用于升级）
+ (NSString *)userInfoVersion;
+ (void)userInfoVersion:(NSString *)strVersion;

@end
