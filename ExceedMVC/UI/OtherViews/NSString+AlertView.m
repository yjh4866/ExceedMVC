//
//  NSString+AlertView.m
//  
//
//  Created by yjh4866 on 12-3-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSString+AlertView.h"


@interface NSString (AlertView_Private)
- (void)showAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message;
@end

@implementation NSString (AlertView)

- (void)showAlertViewWithMessage:(NSString*)message
{
    [self showAlertViewWithTitle:self andMessage:message];
}

- (void)showAlertViewWithTitle:(NSString*)title
{
    [self showAlertViewWithTitle:title andMessage:self];
}


#pragma mark - AlertView_Private

- (void)showAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title 
                                                        message:message 
                                                       delegate:nil 
                                              cancelButtonTitle:nil 
                                              otherButtonTitles:@"确定", nil];
    [alertView show];
    [alertView release];
}

@end
