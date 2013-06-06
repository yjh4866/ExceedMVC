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

@interface XMLNode : NSObject {
@private
    
    NSString *_strNodeName;//结点名称
    NSDictionary *_dicAttributes;//结点属性
    NSMutableArray *_arrayChild;//子结点
    NSString *_strNodeValue;//结点值
    NSUInteger _nodeDepth;
    XMLNode *_nodeParent;//父结点
}

@property (nonatomic, copy) NSString *nodeName;
@property (nonatomic, copy) NSDictionary *nodeAttributesDict;
@property (nonatomic, readonly) NSArray *children;
@property (nonatomic, copy) NSString *nodeValue;
@property (nonatomic, readonly) NSUInteger nodeDepth;
@property (nonatomic, assign) XMLNode *nodeParent;

- (void)clear;

@end


#pragma mark - NSData(XMLParser)

@interface NSData (XMLParser)

- (XMLNode *)xmlNode;

@end


#pragma mark - NSString(XMLParser)

@interface NSString (XMLParser)

- (XMLNode *)xmlNodeWithEncoding:(NSStringEncoding)encoding;

@end
