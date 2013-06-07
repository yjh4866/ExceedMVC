//
//  CoreEngine.h
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetController.h"


@interface CoreEngine : NSObject <NetControllerDelegate> {
@private
    //
    NetController *_netController;
}

@property (nonatomic, assign) BOOL online;

- (void)applicationWillEnterForeground;

- (void)applicationDidEnterBackground;

- (void)applicationDidBecomeActive;

@end


extern NSString *const NetLoginFailure;
extern NSString *const NetLoginSuccess;
extern NSString *const NetUserInfoFailure;
extern NSString *const NetUserInfoSuccess;

extern NSString *const NetDownloadFileFailure;
extern NSString *const NetDownloadFileSuccess;


#ifdef DEBUG

#define CORELOG(fmt,...)     NSLog((@"CORE->%s(%d):"fmt),__PRETTY_FUNCTION__,__LINE__,##__VA_ARGS__)

#else

#define CORELOG(fmt,...)     NSLog(fmt,##__VA_ARGS__)

#endif

