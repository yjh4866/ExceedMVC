//
//  DBStatement.m
//  
//
//  Created by yjh4866 on 11-9-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DBStatement.h"
#import "DBConnection.h"


@implementation DBStatement

- (id)initWithSQL:(const char*)sql {
    self = [super init];
	if (self) {
        // Custom initialization
		sqlite3 *db = [DBConnection openDatabase:NAME_DB];
		if (sqlite3_prepare_v2(db, sql, -1, &_stmt, NULL) != SQLITE_OK) {
            NSLog(@"Failed to prepare statement '%s' (%s)", sql, sqlite3_errmsg(db));
			//NSAssert2(0, @"Failed to prepare statement '%s' (%s)", sql, sqlite3_errmsg(db));
		}
	}
    return self;
}

- (void)dealloc {
	
    sqlite3_finalize(_stmt);
    [DBConnection closeDatabase];
	
    [super dealloc];
}

- (int)step {
    return sqlite3_step(_stmt);
}

- (void)reset {
    sqlite3_reset(_stmt);
}


#pragma mark Get

- (NSString*)getString:(int)index {
    char *value = (char*)sqlite3_column_text(_stmt, index);
    if (value) {
        return [NSString stringWithUTF8String:value];
    }
    return @"";
}
- (int)getInt32:(int)index {
    return sqlite3_column_int(_stmt, index);
}
- (double)getDouble:(int)index {
	return sqlite3_column_double(_stmt, index);
}
- (long long)getInt64:(int)index {
    return sqlite3_column_int64(_stmt, index);
}
- (BOOL)getBool:(int)index {
	return sqlite3_column_int(_stmt, index) != 0;
}
- (NSData*)getData:(int)index {
    int length = sqlite3_column_bytes(_stmt, index);
    return [NSData dataWithBytes:sqlite3_column_blob(_stmt, index) length:length];    
}


#pragma mark Bind

- (void)bindString:(NSString*)value forIndex:(int)index {
    sqlite3_bind_text(_stmt, index, [value UTF8String], -1, SQLITE_TRANSIENT);
}
- (void)bindInt32:(int)value forIndex:(int)index {
    sqlite3_bind_int(_stmt, index, value);
}
- (void)bindDouble:(double)value forIndex:(int)index {
	sqlite3_bind_double(_stmt, index, value);
}
- (void)bindInt64:(long long)value forIndex:(int)index {
    sqlite3_bind_int64(_stmt, index, value);
}
- (void)bindData:(NSData*)value forIndex:(int)index {
    sqlite3_bind_blob(_stmt, index, value.bytes, value.length, SQLITE_TRANSIENT);
}
- (void)bindBool:(BOOL)value forIndex:(int)index {
	sqlite3_bind_int(_stmt, index, value?1:0);
}

@end
