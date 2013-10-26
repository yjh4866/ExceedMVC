//
//  PictureEditor.m
//  
//
//  Created by yjh4866 on 11-6-25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PictureEditor.h"
#import <QuartzCore/QuartzCore.h>


@implementation PictureEditor

// 缩放
+ (UIImage *)zoomImage:(UIImage*)imageOriginal toSize:(CGSize)sizeMax
{
	if (nil == imageOriginal) {
		return nil;
	}
	if (imageOriginal.size.width <= sizeMax.width ||
		imageOriginal.size.height <= sizeMax.height) {
		return imageOriginal;
	}
	
	size_t image_width, image_height;
	//计算拉伸度
	CGFloat fh = sizeMax.width / imageOriginal.size.width;
	CGFloat fv = sizeMax.height / imageOriginal.size.height;
	if (fh > fv) {
		image_width = imageOriginal.size.width * fv;
		image_height = sizeMax.height;
	}
	else {
		image_width = sizeMax.width;
		image_height = imageOriginal.size.height * fh;
	}
	
	UIGraphicsBeginImageContext(CGSizeMake(image_width, image_height));
	[imageOriginal drawInRect:CGRectMake(0, 0, image_width, image_height)];
	UIImage *imageZoom = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    return imageZoom;
}

// 旋转
+ (UIImage *)rotateImage:(UIImage *)aImage
{
	CGImageRef imgRef = aImage.CGImage;
	
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	
	CGRect bounds = CGRectMake(0, 0, width, height);
	
	CGFloat scaleRatio = 1;
	
	CGFloat boundHeight;
	
	UIImageOrientation orient = aImage.imageOrientation;
	switch(orient)
	{
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(width, height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(height, width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationRightMirrored: //EXIF = 7
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
	}
	
	UIGraphicsBeginImageContext(bounds.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -height, 0);
	}
	else {
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -height);
	}
	CGContextConcatCTM(context, transform);
	CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    return imageCopy;
}

// 画框
+ (UIImage *)drawFrame:(UIImage*)image withColor:(UIColor*)color andThick:(CGFloat)fThick
{
	CGFloat width = image.size.width;
	CGFloat height = image.size.height;
	UIGraphicsBeginImageContext(CGSizeMake(width, height));
	[image drawInRect:CGRectMake(0, 0, width, height)];
	//按指定颜色在图片外围画框
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(context, fThick);
	CGContextSetStrokeColorWithColor(context, color.CGColor);
	CGContextBeginPath(context);
	CGContextAddRect(context, CGRectMake(0, 0, width, height));
	CGContextStrokePath(context);
	//取图片
	UIImage *imageNew = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    return imageNew;
}

// 从UIView上截屏
+ (UIImage *)screenshotFromView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    //取图片
    UIImage *imageNew = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //
    return imageNew;
}

@end
