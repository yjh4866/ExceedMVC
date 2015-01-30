//
//  UIImageView+CSCache.m
//
//
//  Created by yangjh on 13-3-14.
//  Copyright (c) 2015年 __MyCompanyName__. All rights reserved.
//

#import "UIImageView+Cache.h"
#import "HTTPConnection.h"


// 将url转换为文件名
NSString *transferFileNameFromURL(NSString *url)
{
    //拼接图片文件名
    NSCharacterSet *setChars = [NSCharacterSet characterSetWithCharactersInString:@":/."];
    NSArray *components = [url componentsSeparatedByCharactersInSet:setChars];
    NSMutableString *mstrFileName = [NSMutableString string];
    for (NSString *component in components) {
        [mstrFileName appendString:component];
    }
    //拼接后缀
    [mstrFileName appendFormat:@".%@", [[NSURL URLWithString:url] pathExtension]];
    return mstrFileName;
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
    [_httpDownload release];
    //
    [_mdicURLKey release];
    
    [super dealloc];
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
    // 取出url相应的任务列表
    NSMutableArray *marray = [_mdicURLKey objectForKey:url];
    if (nil == marray) {
        marray = [NSMutableArray array];
        [_mdicURLKey setObject:marray forKey:url];
    }
    // 加入下载任务
    if (downloadResult) {
        UIImageViewDownlaodImageResult result = [downloadResult copy];
        [marray addObject:@{@"view": imageView, @"path": filePath, @"block": result}];
        [result release];
    }
    else {
        [marray addObject:@{@"view": imageView, @"path": filePath}];
    }
    // 该url未下载才会下载
    if (marray.count == 1) {
        [_httpDownload requestWebDataWithURL:url andParam:@{@"url": url} cache:YES priority:YES];
    }
}

- (void)cancelDownload:(UIImageView *)imageView
{
    NSArray *arrKey = [_mdicURLKey allKeys];
    // 遍历所有url
    for (NSString *strKey in arrKey) {
        NSMutableArray *marray = [_mdicURLKey objectForKey:strKey];
        // 找url对应的任务列表
        for (int i = 0; i < marray.count; i++) {
            NSDictionary *dic = marray[i];
            // 找到需要取消的UIImageView
            if (dic[@"view"] == imageView) {
                [marray removeObjectAtIndex:i];
                // 只有这一个下载则要取消下载任务
                if (0 == marray) {
                    [_httpDownload cancelRequest:@{@"url": strKey}];
                    [_mdicURLKey removeObjectForKey:strKey];
                }
                return;
            }
        }
    }
}


#pragma mark HTTPConnectionDelegate

// 网络数据下载失败
- (void)httpConnect:(HTTPConnection *)httpConnect error:(NSError *)error with:(NSDictionary *)dicParam
{
    NSString *url = [dicParam objectForKey:@"url"];
    NSArray *array = [_mdicURLKey objectForKey:url];
    // 该url的图片均下载失败
    for (NSDictionary *dic in array) {
        // 下载失败回调
        UIImageViewDownlaodImageResult downloadResult = dic[@"block"];
        if (downloadResult) {
            downloadResult(dic[@"view"], dic[@"url"], error);
        }
    }
    [_mdicURLKey removeObjectForKey:url];
}

// 网络数据下载完成
- (void)httpConnect:(HTTPConnection *)httpConnect finish:(NSData *)data with:(NSDictionary *)dicParam
{
    NSString *url = [dicParam objectForKey:@"url"];
    NSArray *array = [_mdicURLKey objectForKey:url];
    // 创建图片对象
    UIImage *image = [[UIImage alloc] initWithData:data];
        // 相应的所有下载任务都算完成
    if (image) {
        for (NSDictionary *dic in array) {
            // 保存
            NSString *filePath = dic[@"path"];
            [data writeToFile:filePath atomically:YES];
            // 显示图片
            UIImageView *imageView = dic[@"view"];
            imageView.image = image;
            // 下载成功回调
            UIImageViewDownlaodImageResult downloadResult = dic[@"block"];
            if (downloadResult) {
                downloadResult(imageView, url, nil);
            }
        }
    }
    else {
        NSError *error = [NSError errorWithDomain:@"ImageView" code:0
                                         userInfo:@{NSLocalizedDescriptionKey: @"图片数据错误"}];
        for (NSDictionary *dic in array) {
            // 下载失败回调
            UIImageViewDownlaodImageResult downloadResult = dic[@"block"];
            if (downloadResult) {
                downloadResult(dic[@"view"], url, error);
            }
        }
    }
    [image release];
    // 清空任务
    [_mdicURLKey removeObjectForKey:url];
}

@end


#pragma mark - UIImageView (Cache)

#define CachePath_UIImageView [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/UIImageView"]

@implementation UIImageView (CSCache)

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