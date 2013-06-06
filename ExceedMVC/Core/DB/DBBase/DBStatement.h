//
//  DBStatement.h
//  
//
//  Created by yjh4866 on 11-9-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <sqlite3.h>


@interface DBStatement : NSObject {
	
    sqlite3_stmt *_stmt;
}

- (id)initWithSQL:(const char*)sql;

// method
- (int)step;
- (void)reset;

// Getter
- (NSString*)getString:(int)index;
- (int)getInt32:(int)index;
- (double)getDouble:(int)index;
- (long long int)getInt64:(int)index;
- (BOOL)getBool:(int)index;
- (NSData*)getData:(int)index;

// Binder
- (void)bindString:(NSString*)value forIndex:(int)index;
- (void)bindInt32:(int)value forIndex:(int)index;
- (void)bindDouble:(double)value forIndex:(int)index;
- (void)bindInt64:(long long int)value forIndex:(int)index;
- (void)bindBool:(BOOL)value forIndex:(int)index;
- (void)bindData:(NSData*)data forIndex:(int)index;

@end
