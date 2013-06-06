//
//  UIView+MBProgressHUD.m
//  
//
//  Created by yjh4866 on 12-12-21.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "UIView+MBProgressHUD.h"

@implementation UIView (MBProgressHUD)

// 只显示活动指示
- (MBProgressHUD *)showActivity
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self];
    if (nil == hud) {
        hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    }
    hud.removeFromSuperViewOnHide = YES;
    return hud;
}

// 显示活动指示及文本
- (MBProgressHUD *)showActivityWithText:(NSString *)text
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self];
    if (nil == hud) {
        hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    }
    hud.labelText = text;
    hud.removeFromSuperViewOnHide = YES;
    return hud;
}

// 移除活动指示
- (void)hideActivity
{
    [[MBProgressHUD HUDForView:self] hide:YES];
}

// 不显示活动指示，只显示文本，指定显示时长
- (MBProgressHUD *)showTextNoActivity:(NSString *)text timeLength:(CGFloat)time
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = text;
    [hud hide:YES afterDelay:time];
    return hud;
}

// 显示文本及指定图片，指定显示时长
- (MBProgressHUD *)showText:(NSString *)text image:(UIImage *)image timeLength:(CGFloat)time
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = text;
    [hud hide:YES afterDelay:time];
    //
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    hud.customView = imageView;
    [imageView release];
    return hud;
}

// 显示文本及指定图片，指定显示时长
- (MBProgressHUD *)showText:(NSString *)text imageName:(NSString *)imageName timeLength:(CGFloat)time
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = text;
    [hud hide:YES afterDelay:time];
    //
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    hud.customView = imageView;
    [imageView release];
    return hud;
}

@end
