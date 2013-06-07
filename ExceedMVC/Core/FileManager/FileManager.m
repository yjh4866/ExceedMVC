//
//  FileManager.m
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "FileManager.h"
#import "FileManager+Picture.h"

@implementation FileManager

// 获取缓存文件目录
+ (NSString *)cachePathForFile
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    if (cachesDirectory.length > 0) {
        return cachesDirectory;
    }
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
}

// 查看缓存占用空间（MB）
+ (CGFloat)cacheUsed
{
    NSUInteger capacity = 0;
    //图片缓存目录
    capacity += [FileManager allCapacityInPath:[FileManager cachePathForPicture]];
    //
    return capacity/(1024.0f*1024.0f);
}

// 清理缓存
+ (void)clearAllCache
{
    //清理图片缓存
    [FileManager removeAllFilesInPath:[FileManager cachePathForPicture]];
}


#pragma mark - Private

// 统计指定目录下文件总大小
+ (NSUInteger)allCapacityInPath:(NSString *)path
{
    NSUInteger capacity = 0.0f;
    //
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *arrFileName = [fileManager contentsOfDirectoryAtPath:path error:nil];
    for (NSString *fileName in arrFileName) {
        NSString *filePath = [path stringByAppendingPathComponent:fileName];
        NSDictionary *dicAttributes = [fileManager attributesOfItemAtPath:filePath error:nil];
        capacity += [[dicAttributes objectForKey:NSFileSize] intValue];
    }
    return capacity;
}

// 删除指定目录下的所有文件
+ (void)removeAllFilesInPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *arrFileName = [fileManager contentsOfDirectoryAtPath:path error:nil];
    for (NSString *fileName in arrFileName) {
        NSString *filePath = [path stringByAppendingPathComponent:fileName];
        [fileManager removeItemAtPath:filePath error:nil];
    }
}

@end
