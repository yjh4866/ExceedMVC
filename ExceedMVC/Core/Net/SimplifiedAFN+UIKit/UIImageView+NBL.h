//
//  UIImageView+NBL.h
//  testOurApps
//
//  Created by CocoaChina_yangjh on 16/1/29.
//
//

#import <UIKit/UIKit.h>


// 图片下载结束后的block回调
// error只在图片下载失败时有效，表示下载失败时的错误
typedef void (^UIImageViewDownloadImageResult) (UIImageView *imageView, NSString *picUrl,
                                                float progress, BOOL finished, NSError *error);


@interface UIImageView (NBL)

/**
 *	@brief	清除UIImageView的缓存
 */
+ (void)clearCacheOfUIImageView;

/**
 *	@brief	获取UIImageView的缓存路径
 *
 *	@return	UIImageView默认的缓存路径
 */
+ (NSString *)cachePathOfUIImageView;

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
- (void)loadImageFromCachePath:(NSString *)filePath orPicUrl:(NSString *)picUrl
            withDownloadResult:(UIImageViewDownloadImageResult)downloadResult;

/**
 *	@brief	取消下载图片
 */
- (void)cancelDownload;

@end
