//
//  UIImageView+Cache.m
//
//
//  Created by Jianhong Yang on 13-12-17.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "UIImageView+Cache.h"
#import <CommonCrypto/CommonDigest.h>
#import "HTTPConnection.h"


// 将url转换为文件名
NSString *transferFileNameFromURL(NSString *url)
{
    const char *cStr = [url UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    NSString *fileName = [NSString stringWithFormat:
                          @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          result[0], result[1], result[2], result[3],
                          result[4], result[5], result[6], result[7],
                          result[8], result[9], result[10], result[11],
                          result[12], result[13], result[14], result[15]];
    NSString *pathExtension = [[NSURL URLWithString:url] pathExtension];
    return pathExtension.length>0?[fileName stringByAppendingPathExtension:pathExtension]:fileName;
}

#pragma mark - UIImageViewManager

@interface UIImageViewManager : NSObject <HTTPConnectionDelegate> {
    
    HTTPConnection *_httpDownload;
    
    NSMutableDictionary *_mdicURLKey;
}
@end

@implementation UIImageViewManager

- (id)init
{
    self = [super init];
    if (self) {
        _httpDownload = [[HTTPConnection alloc] init];
        _httpDownload.delegate = self;
        //
        _mdicURLKey = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
#if __has_feature(objc_arc)
#else
    [_httpDownload release];
    [_mdicURLKey release];
    
    [super dealloc];
#endif
}

+ (UIImageViewManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    static UIImageViewManager *sSharedInstance;
    
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[UIImageViewManager alloc] init];
    });
    
    return sSharedInstance;
}

- (void)downloadFile:(NSString *)filePath from:(NSString *)url showOn:(UIImageView *)imageView
          withResult:(UIImageViewDownlaodImageResult)downloadResult
{
    // 取出url相应的任务项
    NSMutableDictionary *mdicURLItem = _mdicURLKey[url];
    if (nil == mdicURLItem) {
        mdicURLItem = [NSMutableDictionary dictionary];
        [_mdicURLKey setObject:mdicURLItem forKey:url];
    }
    // 从任务项中取出任务列表
    NSMutableArray *marrItem = mdicURLItem[@"list"];
    if (nil == marrItem) {
        marrItem = [NSMutableArray array];
        [mdicURLItem setObject:marrItem forKey:@"list"];
    }
    // 加入下载任务
    if (downloadResult) {
        UIImageViewDownlaodImageResult result = [downloadResult copy];
        [marrItem addObject:@{@"view": imageView, @"path": filePath, @"block": result}];
#if __has_feature(objc_arc)
#else
        [result release];
#endif
    }
    else {
        [marrItem addObject:@{@"view": imageView, @"path": filePath}];
    }
    // 第一次请求该url时才会下载
    if (marrItem.count == 1) {
        [_httpDownload requestWebDataWithURL:url andParam:@{@"url": url}];
    }
}

- (void)cancelDownload:(UIImageView *)imageView
{
    NSArray *arrKey = [_mdicURLKey allKeys];
    // 遍历所有url
    for (NSString *strKey in arrKey) {
        NSMutableDictionary *mdicURLItem = _mdicURLKey[strKey];
        NSMutableArray *marrItem = mdicURLItem[@"list"];
        // 遍历任务列表
        for (int i = 0; i < marrItem.count; i++) {
            NSDictionary *dicItem = marrItem[i];
            // 找到需要取消的UIImageView
            if (dicItem[@"view"] == imageView) {
                [marrItem removeObjectAtIndex:i];
                // 只有这一个下载则要取消下载任务
                if (0 == marrItem.count) {
                    [_httpDownload cancelRequest:@{@"url": strKey}];
                    [_mdicURLKey removeObjectForKey:strKey];
                }
                break;
            }
        }
    }
}


#pragma mark HTTPConnectionDelegate

// 网络数据下载失败
- (void)httpConnect:(HTTPConnection *)httpConnect error:(NSError *)error with:(NSDictionary *)dicParam
{
    NSString *url = dicParam[@"url"];
    NSMutableDictionary *mdicURLItem = _mdicURLKey[url];
    NSArray *arrItem = mdicURLItem[@"list"];
    // 遍历该url对应的任务项，触发下载失败的回调
    for (NSDictionary *dicItem in arrItem) {
        // 下载失败回调
        UIImageViewDownlaodImageResult downloadResult = dicItem[@"block"];
        if (downloadResult) {
            downloadResult(dicItem[@"view"], url, 1.0f, YES, error);
        }
    }
    [_mdicURLKey removeObjectForKey:url];
}

// 服务器返回的HTTP信息头
- (void)httpConnect:(HTTPConnection *)httpConnect receiveResponseWithStatusCode:(NSInteger)statusCode
 andAllHeaderFields:(NSDictionary *)dicAllHeaderFields with:(NSDictionary *)dicParam
{
    // 找到当前url对应的URL项
    NSString *url = dicParam[@"url"];
    NSMutableDictionary *mdicURLItem = _mdicURLKey[url];
    // 保存图片文件大小
    unsigned long fileSize = [dicAllHeaderFields[@"Content-Length"] intValue];
    [mdicURLItem setObject:@(fileSize) forKey:@"fileSize"];
    // 遍历该url对应的任务项，触发回调
    NSArray *arrItem = mdicURLItem[@"list"];
    for (int i = 0; i < arrItem.count; i++) {
        NSDictionary *dicItem = arrItem[i];
        // 开始下载的回调
        UIImageViewDownlaodImageResult downloadResult = dicItem[@"block"];
        if (downloadResult) {
            downloadResult(dicItem[@"view"], url, 0.0f, NO, nil);
        }
    }
}

// 接收到部分数据
- (void)httpConnect:(HTTPConnection *)httpConnect receivePartData:(NSData *)partData with:(NSDictionary *)dicParam
{
    // 找到当前url对应的URL项
    NSString *url = dicParam[@"url"];
    NSMutableDictionary *mdicURLItem = _mdicURLKey[url];
    // 图片文件大小大于0，才回调下载进度
    unsigned long fileSize = [mdicURLItem[@"fileSize"] intValue];
    if (fileSize > 0) {
        // 保存图片下载进度
        unsigned long receivedSize = [mdicURLItem[@"receivedSize"] intValue]+partData.length;
        [mdicURLItem setObject:@(receivedSize) forKey:@"receivedSize"];
        // 遍历该url对应的任务项，触发回调
        NSArray *arrItem = mdicURLItem[@"list"];
        for (int i = 0; i < arrItem.count; i++) {
            NSDictionary *dicItem = arrItem[i];
            // 开始下载的回调
            UIImageViewDownlaodImageResult downloadResult = dicItem[@"block"];
            if (downloadResult) {
                downloadResult(dicItem[@"view"], url, 1.0f*receivedSize/fileSize, NO, nil);
            }
        }
    }
}

// 网络数据下载完成
- (void)httpConnect:(HTTPConnection *)httpConnect finish:(NSData *)data with:(NSDictionary *)dicParam
{
    NSString *url = dicParam[@"url"];
    NSMutableDictionary *mdicURLItem = _mdicURLKey[url];
    NSArray *arrItem = mdicURLItem[@"list"];
    // 创建图片对象（为保证UIImage对象及时释放，故用alloc方式实例化）
    UIImage *image = [[UIImage alloc] initWithData:data];
    // 相应的所有下载任务都算完成
    if (image) {
        // 遍历该url对应的任务项，触发下载成功的回调
        for (NSDictionary *dicItem in arrItem) {
            // 保存
            NSString *filePath = dicItem[@"path"];
            [data writeToFile:filePath atomically:YES];
            // 显示图片
            UIImageView *imageView = dicItem[@"view"];
            imageView.image = image;
            // 下载成功回调
            UIImageViewDownlaodImageResult downloadResult = dicItem[@"block"];
            if (downloadResult) {
                downloadResult(imageView, url, 1.0f, YES, nil);
            }
        }
    }
    else {
        NSError *error = [NSError errorWithDomain:@"ImageView" code:0
                                         userInfo:@{NSLocalizedDescriptionKey: @"图片数据错误"}];
        // 遍历该url对应的任务项，触发下载失败的回调
        for (NSDictionary *dicItem in arrItem) {
            // 下载失败回调
            UIImageViewDownlaodImageResult downloadResult = dicItem[@"block"];
            if (downloadResult) {
                downloadResult(dicItem[@"view"], url, 1.0f, YES, error);
            }
        }
    }
#if __has_feature(objc_arc)
#else
    [image release];
#endif
    // 清空任务
    [_mdicURLKey removeObjectForKey:url];
}

@end


#pragma mark - UIImageView (Cache)

#define CachePath_UIImageView [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/UIImageView"]

@implementation UIImageView (Cache)

/**
 *	@brief	清除UIImageView的缓存
 */
+ (void)clearCacheOfUIImageView
{
    NSString *cachePath = CachePath_UIImageView;
    // 删除缓存目录下的所有文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *array = [fileManager subpathsAtPath:cachePath];
    for (NSString *fileName in array) {
        [fileManager removeItemAtPath:[cachePath stringByAppendingPathComponent:fileName] error:nil];
    }
}

/**
 *	@brief	设置图片路径和网址（不全为空）
 *
 *	@param 	filePath 	缓存图片保存路径
 *	@param 	picUrl 	图片下载地址
 */
- (void)loadImageFromCachePath:(NSString *)filePath orPicUrl:(NSString *)picUrl
{
    [self loadImageFromCachePath:filePath orPicUrl:picUrl withDownloadResult:nil];
}

/**
 *	@brief	设置图片路径和网址（不全为空）
 *
 *	@param 	filePath 	缓存图片保存路径
 *	@param 	picUrl 	图片下载地址
 *	@param 	result 	图片下载结束后的block回调
 */
- (void)loadImageFromCachePath:(NSString *)filePath orPicUrl:(NSString *)picUrl withDownloadResult:(UIImageViewDownlaodImageResult)downloadResult
{
    // 无路径则使用默认路径
    if (filePath.length == 0) {
        NSString *cachePath = CachePath_UIImageView;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:cachePath]) {
            [fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES
                                    attributes:nil error:nil];
        }
        NSString *fileName = transferFileNameFromURL(picUrl);
        filePath = [cachePath stringByAppendingPathComponent:fileName];
    }
    // 读缓存图片
    UIImage *imageCache = [UIImage imageWithContentsOfFile:filePath];
    // 读取缓存成功
    if (imageCache) {
        self.image = imageCache;
    }
    // 缓存图片没读取到，且url存在，则下载
    else if (picUrl) {
        [[UIImageViewManager sharedInstance] downloadFile:filePath from:picUrl showOn:self
                                               withResult:downloadResult];
    }
}

/**
 *	@brief	取消下载图片
 */
- (void)cancelDownload
{
    [[UIImageViewManager sharedInstance] cancelDownload:self];
}

@end