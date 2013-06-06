//
//  DBController+Version.m
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "DBController+Version.h"

@implementation DBController (Version)

//从数据库中获取数据库版
+ (NSString*)getDBVersion {
	
	NSString *strDBVersion = @"";
	
	const char* sql = "SELECT version0,version1,version2,version3 FROM version"; 
	DBStatement *stmt = [[DBStatement alloc] initWithSQL:sql];
	//
	if ([stmt step] == SQLITE_ROW) {
		int v0 = [stmt getInt32:0];
		int v1 = [stmt getInt32:1];
		int v2 = [stmt getInt32:2];
		int v3 = [stmt getInt32:3];
		//
		strDBVersion = [NSString stringWithFormat:@"%i.%i.%i.%i", v0, v1, v2, v3];
	}
	[stmt release];
	return strDBVersion;
}

//从数据库中获取数据库版本号放入可变字典中
+ (void)loadDBVersion:(NSMutableDictionary*)dicDBVersion {
	
	const char* sql = "SELECT version0,version1,version2,version3 FROM version"; 
	DBStatement *stmt = [[DBStatement alloc] initWithSQL:sql];
	//
	if ([stmt step] == SQLITE_ROW) {
		int v0 = [stmt getInt32:0];
		int v1 = [stmt getInt32:1];
		int v2 = [stmt getInt32:2];
		int v3 = [stmt getInt32:3];
		//
		[dicDBVersion setObject:[NSNumber numberWithInt:v0] forKey:@"version0"];
		[dicDBVersion setObject:[NSNumber numberWithInt:v1] forKey:@"version1"];
		[dicDBVersion setObject:[NSNumber numberWithInt:v2] forKey:@"version2"];
		[dicDBVersion setObject:[NSNumber numberWithInt:v3] forKey:@"version3"];
	}
	[stmt release];
}

//修改数据库版本
+ (void)modifyDBVersionWithString:(NSString *)strDBVersion
{
    NSArray *arrayVersion = [strDBVersion componentsSeparatedByString:@"."];
    
	const char* sql = "UPDATE version SET version0=?,version1=?,version2=?,version3=? WHERE id=1"; 
	DBStatement *stmt = [[DBStatement alloc] initWithSQL:sql];
    //绑定各版本值
    for (int i = 0; i < 4; i++) {
        if (arrayVersion.count > i) {
            int v = [[arrayVersion objectAtIndex:i] intValue];
            [stmt bindInt32:v forIndex:i+1];
        }
        else {
            break;
        }
    }
	//
	if ([stmt step] == SQLITE_DONE) {
	}
	[stmt release];
}

//修改数据库版本
+ (void)modifyDBVersionWithDictionary:(NSDictionary *)dicDBVersion
{
	const char* sql = "UPDATE version SET version0=?,version1=?,version2=?,version3=? WHERE id=1"; 
	DBStatement *stmt = [[DBStatement alloc] initWithSQL:sql];
    //绑定各版本值
    for (int i = 0; i < 4; i++) {
        NSString *str = [NSString stringWithFormat:@"version%i", i];
        if ([dicDBVersion objectForKey:str]) {
            int v = [[dicDBVersion objectForKey:str] intValue];
            [stmt bindInt32:v forIndex:i+1];
        }
        else {
            break;
        }
    }
	//
	if ([stmt step] == SQLITE_DONE) {
	}
	[stmt release];
}

@end
