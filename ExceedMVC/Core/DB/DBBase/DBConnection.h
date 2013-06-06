//
//  DBConnection.h
//  
//
//  Created by yjh4866 on 11-9-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <sqlite3.h>


#define     NAME_DB             @"ExceedMVC.sqlite"

@interface DBConnection : NSObject

+ (BOOL)createCopyOfDatabaseIfNeeded;
+ (sqlite3*)openDatabase:(NSString*)dbfilename;
+ (void)closeDatabase;

//
+ (void)beginTransaction;
+ (void)commitTransaction;
+ (void)runSQLMore:(const char*)strsql;

@end
