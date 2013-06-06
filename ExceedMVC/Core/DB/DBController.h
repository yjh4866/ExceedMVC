//
//  DBController.h
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBStatement.h"

@interface DBController : NSObject

//清空数据
+ (void)clearDB;

@end


#ifdef DEBUG

#define DBLOG(fmt,...)     NSLog((@"DB->%s(%d):"fmt),__PRETTY_FUNCTION__,__LINE__,##__VA_ARGS__)

#else

#define DBLOG(fmt,...)     NSLog(fmt,##__VA_ARGS__)

#endif
