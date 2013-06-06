//
//  UIView+Badge.h
//  
//
//  Created by yjh4866 on 12-7-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Badge)

- (UIView *)showBadgeValue:(NSString *)strBadgeValue;

- (void)removeBadgeValue;

@end
