//
//  NSObject+ActivityAlertView.h
//  
//
//  Created by yjh4866 on 13-1-1.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ActivityAlertView)

// 根据tag值找UIAlertView
- (UIAlertView *)findAlertViewWithTag:(NSInteger)tag;

// 显示带活动指示和message的UIAlertView
- (void)showActivityAlertViewWithTag:(NSUInteger)tag message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

@end
