//
//  PinyinQuery.h
//  
//
//  Created by yjh4866 on 13-1-8.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ALPHA	@"abcdefghijklmnopqrstuvwxyz#"

@interface PinyinQuery : NSObject

+ (char)firstLetterOfName:(NSString *)name;

@end
