//
//  PictureEditor.h
//  
//
//  Created by yjh4866 on 11-6-25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PictureEditor : NSObject

// 缩放
+ (UIImage *)zoomImage:(UIImage*)imageOriginal toSize:(CGSize)sizeMax;

// 旋转
+ (UIImage *)rotateImage:(UIImage *)aImage;

// 画框
+ (UIImage *)drawFrame:(UIImage*)image withColor:(UIColor*)color andThick:(CGFloat)fThick;

// 从UIView上截屏
+ (UIImage *)screenshotFromView:(UIView *)view;

@end
