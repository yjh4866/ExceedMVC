//
//  UIImageView+Cache.h
//
//
//  Created by Jianhong Yang on 13-12-17.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


// 将url转换为文件名
NSString *transferFileNameFromURL(NSString *url);

// 图片下载结束后的block回调
// error只在图片下载失败时有效，表示下载失败时的错误
typedef void (^UIImageViewDownlaodImageResult) (UIImageView *imageView, NSString *picUrl, float progress, BOOL finished, NSError *error);

@interface UIImageView (Cache)

/**
 *	@brief	清除UIImageView的缓存
 */
+ (void)clearCacheOfUIImageView;

/**
 *	@brief	设置图片路径和网址（不全为空）
 *
 *	@param 	filePath 	缓存图片保存路径
 *	@param 	picUrl 	图片下载地址
 */
- (void)loadImageFromCachePath:(NSString *)filePath orPicUrl:(NSString *)picUrl;

/**
 *	@brief	设置图片路径和网址（不全为空）
 *
 *	@param 	filePath 	缓存图片保存路径
 *	@param 	picUrl 	图片下载地址
 *	@param 	result 	图片下载结束后的block回调
 */
- (void)loadImageFromCachePath:(NSString *)filePath orPicUrl:(NSString *)picUrl withDownloadResult:(UIImageViewDownlaodImageResult)downloadResult;

/**
 *	@brief	取消下载图片
 */
- (void)cancelDownload;

@end