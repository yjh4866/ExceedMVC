//
//  XMLParser.h
//
//
//  Created by yangjianhong-MAC on 11-12-31.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//  QQ:18222469
//

#import <Foundation/Foundation.h>


#pragma mark - XMLNode

@interface XMLNode : NSObject

@property (nonatomic, copy) NSString *nodeName;//结点名称
@property (nonatomic, retain) NSDictionary *nodeAttributesDict;//结点属性
@property (nonatomic, readonly) NSArray *children;//子结点
@property (nonatomic, copy) NSString *nodeValue;//结点值
@property (nonatomic, readonly) NSUInteger nodeDepth;
@property (nonatomic, readonly) XMLNode *nodeParent;//父结点

// 查询指定名称的结点
- (NSArray *)findNodesWithNodeName:(NSString *)nodeName;

// 清空结点
- (void)clear;

@end


#pragma mark - NSData(XMLParser)

@interface NSData (XMLParser)

- (XMLNode *)xmlNode;

- (NSArray *)findXMLNodesWithNodeName:(NSString *)nodeName;

@end


#pragma mark - NSString(XMLParser)

@interface NSString (XMLParser)

- (XMLNode *)xmlNodeWithEncoding:(NSStringEncoding)encoding;

- (NSArray *)findXMLNodesWithNodeName:(NSString *)nodeName encoding:(NSStringEncoding)encoding;

@end
