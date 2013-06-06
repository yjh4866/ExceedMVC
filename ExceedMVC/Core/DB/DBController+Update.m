//
//  DBController+Update.m
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "DBController+Update.h"
#import "DBController+Version.h"

@implementation DBController (Update)

// 升级
+ (void)update
{
    NSMutableDictionary *mdicDBVersion = [[NSMutableDictionary alloc] initWithCapacity:4];
    //获取数据库版本
    [DBController loadDBVersion:mdicDBVersion];
    [mdicDBVersion release];
}

@end
