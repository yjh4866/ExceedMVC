//
//  FileManager.h
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject

// 获取缓存文件目录
+ (NSString *)cachePathForFile;

// 查看缓存占用空间（MB）
+ (CGFloat)cacheUsed;

// 清理缓存
+ (void)clearAllCache;

@end


#ifdef DEBUG

#define FMLOG(fmt,...)     NSLog((@"FM->%s(%d):"fmt),__PRETTY_FUNCTION__,__LINE__,##__VA_ARGS__)

#else

#define FMLOG(fmt,...)     NSLog(fmt,##__VA_ARGS__)

#endif
