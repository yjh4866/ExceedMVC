//
//  FileManager+Picture.h
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "FileManager.h"

@interface FileManager (Picture)

// 图片缓存目录
+ (NSString *)cachePathForPicture;

// 获取指定url的图片保存路径
+ (NSString *)picturePathOfUrl:(NSString *)picUrl;

// 将图片数据保存到指定路径
+ (void)savePictureData:(NSData *)picData to:(NSString *)filePath;

// 获取指定url的图片
+ (UIImage *)pictureOfUrl:(NSString *)picUrl;

@end
