//
//  DBConnection.m
//  
//
//  Created by yjh4866 on 11-9-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DBConnection.h"

//
static sqlite3*             gTheDatabase = nil;


@implementation DBConnection

// Creates a writable copy of the bundled default database in the application Documents directory.
+ (BOOL)createCopyOfDatabaseIfNeeded {
	
	//获取数据库路径
	NSString *pathDB = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), NAME_DB];
	//查看数据库是否存在，存在则直接返回
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:pathDB]) {
		return YES;
	}
	//不存在则从资源中复制
	NSString *dbpathResource = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:NAME_DB];
	NSError *error;
	BOOL success = [fileManager copyItemAtPath:dbpathResource toPath:pathDB error:&error];
	if (!success) {
        NSAssert1(0, @"创建数据库失败(%@)", [error localizedDescription]);
	}
	return success;
}

+ (sqlite3*)openDatabase:(NSString*)dbfilename {
	
	if (gTheDatabase) {
		return gTheDatabase;
	}
	
	//获取数据库路径
	NSString* strHomePath = NSHomeDirectory();
	NSString *pathDB = [NSString stringWithFormat:@"%@/Documents/%@", strHomePath, dbfilename];
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([pathDB UTF8String], &gTheDatabase) != SQLITE_OK) {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(gTheDatabase);
		gTheDatabase = nil;
        NSLog(@"数据库打开失败(%s)", sqlite3_errmsg(gTheDatabase));
    }
	return gTheDatabase;
}

+ (void)closeDatabase {
	
    if (gTheDatabase) {
		sqlite3_close(gTheDatabase);
		gTheDatabase = nil;
    }
}

+ (void)beginTransaction {
    char *errmsg;     
    sqlite3_exec(gTheDatabase, "BEGIN", NULL, NULL, &errmsg);     
}
+ (void)commitTransaction {
    char *errmsg;     
    sqlite3_exec(gTheDatabase, "COMMIT", NULL, NULL, &errmsg);     
}
+ (void)runSQLMore:(const char*)strsql {
	char *errmsg;
	if (sqlite3_exec(gTheDatabase, strsql, NULL, NULL, &errmsg) != SQLITE_OK) {
		// ignore error
		NSLog(@"数据库执行错误(%s)", errmsg);
	}
}

@end
