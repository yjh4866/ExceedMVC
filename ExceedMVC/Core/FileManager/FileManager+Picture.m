//
//  FileManager+Picture.m
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "FileManager+Picture.h"

#define PicPath(picUrl)  [FileManager picturePathOfUrl:picUrl]

@implementation FileManager (Picture)

// 图片缓存目录
+ (NSString *)cachePathForPicture
{
    NSString *picCachePath = [[FileManager cachePathForFile] stringByAppendingPathComponent:@"Pictures"];
    //
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:picCachePath]) {
        [fileManager createDirectoryAtPath:picCachePath withIntermediateDirectories:YES
                                attributes:nil error:nil];
    }
    //
    return picCachePath;
}

// 获取指定url的图片保存路径
+ (NSString *)picturePathOfUrl:(NSString *)picUrl
{
    //拼接图片文件名
    NSCharacterSet *setChars = [NSCharacterSet characterSetWithCharactersInString:@":/."];
    NSArray *components = [picUrl componentsSeparatedByCharactersInSet:setChars];
    NSMutableString *mstrFileName = [NSMutableString string];
    for (NSString *component in components) {
        [mstrFileName appendString:component];
        [mstrFileName appendString:@"_"];
    }
    //拼接后缀
    [mstrFileName appendFormat:@".%@", [[picUrl pathExtension] lowercaseString]];
    //拼接图片文件路径
    NSString *picPath = [NSString stringWithFormat:@"%@/%@",
                         [FileManager cachePathForPicture], mstrFileName];
    //
    return picPath;
}

// 将图片数据保存到指定路径
+ (void)savePictureData:(NSData *)picData to:(NSString *)filePath
{
    [picData writeToFile:filePath atomically:YES];
}

// 获取指定url的图片
+ (UIImage *)pictureOfUrl:(NSString *)picUrl
{
    return [UIImage imageWithContentsOfFile:PicPath(picUrl)];
}

@end
