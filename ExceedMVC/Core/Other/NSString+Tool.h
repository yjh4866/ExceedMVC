//
//  NSString+Tool.h
//  
//
//  Created by yjh4866 on 12-3-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Tool)

//验证手机号码
- (BOOL)validateMobilePhone;

//验证固定电话号码
- (BOOL)validateTelePhone;

//非负整数
- (BOOL)validateUnsignedInt;

//普通字符串，字母数字汉字和空格
- (BOOL)validateNormalString;

//空格或汉字字符串
- (BOOL)validateChineseString;

//邮箱
- (BOOL)validateEMail;

//MD5大写字母串
- (NSString *)md5UppercaseStringUsingEncoding:(NSStringEncoding)encoding;

//MD5小写字母串
- (NSString *)md5LowercaseStringUsingEncoding:(NSStringEncoding)encoding;

@end
