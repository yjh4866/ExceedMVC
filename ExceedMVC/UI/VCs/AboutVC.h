//
//  AboutVC.h
//  ExceedMVC
//
//  Created by yangjh on 13-6-7.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AboutVCDelegate;

@interface AboutVC : UIViewController

@property (nonatomic, assign) id <AboutVCDelegate> delegate;

@end


@protocol AboutVCDelegate <NSObject>

@optional

- (void)aboutVCClose:(AboutVC *)aboutVC;

@end
