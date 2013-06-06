//
//  UIView+MBProgressHUD.h
//  
//
//  Created by yjh4866 on 12-12-21.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface UIView (MBProgressHUD)

// 只显示活动指示
- (MBProgressHUD *)showActivity;

// 显示活动指示及文本
- (MBProgressHUD *)showActivityWithText:(NSString *)text;

// 隐藏活动指示
- (void)hideActivity;

// 不显示活动指示，只显示文本，指定显示时长
- (MBProgressHUD *)showTextNoActivity:(NSString *)text timeLength:(CGFloat)time;

// 显示文本及指定图片，指定显示时长
- (MBProgressHUD *)showText:(NSString *)text image:(UIImage *)image timeLength:(CGFloat)time;

// 显示文本及指定图片，指定显示时长
- (MBProgressHUD *)showText:(NSString *)text imageName:(NSString *)imageName timeLength:(CGFloat)time;

@end
