//
//  NSString+Tool.m
//  
//
//  Created by yjh4866 on 12-3-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSString+Tool.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Tool)

//验证手机号码
- (BOOL)validateMobilePhone
{
	NSString *phoneRegex = @"^(13[0-9]|14[5|7]|15[0-9]|18[0-9])\\d{8}$";
	NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
	return [phoneTest evaluateWithObject:self];
}

//验证固定电话号码
- (BOOL)validateTelePhone
{
	NSString *phoneRegex = @"(\\d{3}-|\\d{4}-)?(\\d{8}|\\d{7})?";
	NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
	return [phoneTest evaluateWithObject:self];
}

//非负整数
- (BOOL)validateUnsignedInt
{
	NSString *stringRegex = @"^\\d+$";
	NSPredicate *stringTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stringRegex];
	return [stringTest evaluateWithObject:self];
}

//普通字符串，字母数字汉字和空格
- (BOOL)validateNormalString
{
	NSString *stringRegex = @"^[ |0-9a-zA-Z\u4e00-\u9fa5]*$";
	NSPredicate *stringTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stringRegex];
	return [stringTest evaluateWithObject:self];
}

//空格或汉字字符串
- (BOOL)validateChineseString
{
	NSString *stringRegex = @"^[ |\u4e00-\u9fa5]*$";
	NSPredicate *stringTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stringRegex];
	return [stringTest evaluateWithObject:self];
}

//邮箱
- (BOOL)validateEMail
{
	NSString *emailRegex = @"^[a-zA-Z0-9_\\.]*@[a-zA-Z0-9_\\.]+(\\.[[a-zA-Z0-9_\\.]{2,4}]+)+$";
	NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
	return [emailTest evaluateWithObject:self];
}

//MD5大写字母串
- (NSString *)md5UppercaseStringUsingEncoding:(NSStringEncoding)encoding
{
	unsigned char result[32];
    //
	const char *cString = [self cStringUsingEncoding:encoding];
	CC_MD5(cString, (CC_LONG)strlen(cString), result);
 	NSMutableString *mstrMD5String = [NSMutableString string];
    for (int i = 0; i < 16; i++) {
        [mstrMD5String appendFormat:@"%02X", result[i]];
    }
    return mstrMD5String;
}

//MD5小写字母串
- (NSString *)md5LowercaseStringUsingEncoding:(NSStringEncoding)encoding
{
	unsigned char result[32];
    //
	const char *cString = [self cStringUsingEncoding:encoding];
	CC_MD5(cString, (CC_LONG)strlen(cString), result);
 	NSMutableString *mstrMD5String = [NSMutableString string];
    for (int i = 0; i < 16; i++) {
        [mstrMD5String appendFormat:@"%02x", result[i]];
    }
    return mstrMD5String;
}

@end
