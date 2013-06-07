//
//  CoreEngine+Send.h
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "CoreEngine.h"

@interface CoreEngine (Send)

// 登录
- (void)loginWithUserName:(NSString *)userName
              andPassword:(NSString *)password;

// 下载指定url的图片
- (void)downloadPictureWithUrl:(NSString *)picUrl;

// 获取指定用户资料
- (void)getUserInfoOf:(UInt64)userID;

@end
