//
//  XMLParser.m
//
//
//  Created by yangjianhong-MAC on 11-12-31.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//  QQ:18222469
//

#import "XMLParser.h"


#pragma mark - Implementation XMLNode

@implementation XMLNode

@synthesize nodeName = _strNodeName, nodeValue = _strNodeValue;
@synthesize nodeAttributesDict = _dicAttributes, nodeDepth = _nodeDepth;

#pragma mark Override

- (void)dealloc
{
    [_strNodeName release];
    [_dicAttributes release];
    [_strNodeValue release];
    _nodeParent = nil;
    
    [super dealloc];
}

- (NSArray *)children
{
    if (_arrayChild.count > 0) {
        return [NSArray arrayWithArray:_arrayChild];
    }
    else {
        return nil;
    }
}

- (void)setNodeParent:(XMLNode *)nodeParent
{
    _nodeParent = nodeParent;
    //计算本结点的深度
    if (nil == nodeParent) {
        //父结点为nil，当前结点深度为0
        _nodeDepth = 0;
    }
    else {
        //当前结点深度为父结点深度+1
        _nodeDepth = nodeParent.nodeDepth + 1;
    }
    //更新子结点的深度
    if (_arrayChild.count > 0) {
        //遍历子结点
        for (XMLNode *nodeChild in _arrayChild) {
            //通过设置父结点的方式更新子结点深度
            nodeChild.nodeParent = self;
        }
    }
}

- (XMLNode *)nodeParent
{
    return _nodeParent;
}

- (NSString *)description
{
    if (_strNodeName.length == 0) {
        return @"";
    }
    
    NSMutableString *mstrDescription = [NSMutableString string];
    //表示深度的空格字符
    NSMutableString *mstrSpace = [[NSMutableString alloc] init];
    for (int i = 0; i < _nodeDepth; i++) {
        [mstrSpace appendString:@" "];
    }
    [mstrDescription appendString:mstrSpace];
    //结点的名称
    [mstrDescription appendFormat:@"\r\n%@<%@", mstrSpace, _strNodeName];
    //结点的属性
    NSArray *arrayKeys = [_dicAttributes allKeys];
    for (NSString *strKey in arrayKeys) {
        [mstrDescription appendFormat:@" \"%@\"=\"%@\"", strKey, [_dicAttributes objectForKey:strKey]];
    }
    [mstrDescription appendString:@">"];
    //结点的值
    if (_strNodeValue.length > 0) {
        [mstrDescription appendFormat:@"%@", _strNodeValue];
    }
    //子结点部分
    if (_arrayChild.count > 0) {
        //遍历所有子结点
        for (XMLNode *nodeChild in _arrayChild) {
            //子结点描述串
            [mstrDescription appendFormat:@"%@", nodeChild];
        }
        [mstrDescription appendFormat:@"\r\n%@", mstrSpace];
    }
    //结点的结束
    [mstrDescription appendFormat:@"</%@>", _strNodeName];
    [mstrSpace release];
    //
    return mstrDescription;
}

#pragma mark Public

- (void)addChildNode:(XMLNode *)childNode
{
    if (nil == _arrayChild) {
        _arrayChild = [NSMutableArray arrayWithCapacity:5];
    }
    //
    [_arrayChild addObject:childNode];
}

- (void)clear
{
    NSArray *arrayChild = [self children];
    //遍历所有子结点
    for (XMLNode *node in arrayChild) {
        //清空子结点的数据
        [node clear];
    }
    //清空当前结点数据
    _nodeDepth = 0;
    self.nodeName = nil;
    self.nodeValue = nil;
    self.nodeAttributesDict = nil;
    self.nodeParent = nil;
    //清空子结点表
    [_arrayChild removeAllObjects];
}

@end


#pragma mark - Interface XMLParser

@interface XMLParser : NSObject <NSXMLParserDelegate> {
@private
    
    XMLNode *_rootNode;
    XMLNode *_currentNode;
}

- (XMLNode *)parse:(NSData *)dataXML;

@end



#pragma mark - Implementation XMLParser

@implementation XMLParser

- (XMLNode *)parse:(NSData *)dataXML
{
    _rootNode = nil;
    _currentNode = nil;
    //
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:dataXML]; //设置XML数据
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
    [parser setDelegate:self];
    [parser parse];
    [parser release];
    
    return _rootNode;
}

#pragma mark NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
#ifdef DEBUG
    NSLog(@"element start:%@",elementName);
#endif
    //
    if (nil == _rootNode) {
        //创建根结点
        _rootNode = [[[XMLNode alloc] init] autorelease];
        _rootNode.nodeName = elementName;
        _rootNode.nodeAttributesDict = attributeDict;
        _rootNode.nodeParent = nil;
        //
        _currentNode = _rootNode;
    }
    else {
        //
        XMLNode *nodeChild = [[XMLNode alloc] init];
        nodeChild.nodeName = elementName;
        nodeChild.nodeAttributesDict = attributeDict;
        nodeChild.nodeParent = _currentNode;
        //
        [_currentNode addChildNode:nodeChild];
        _currentNode = nodeChild;
        [nodeChild release];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    //去掉字符串首尾的空字符
    NSString *strValidValue = [string stringByTrimmingCharactersInSet:
                               [NSCharacterSet controlCharacterSet]];
#ifdef DEBUG
    NSLog(@"element value:%@",strValidValue);
#endif
    if (nil == _currentNode.nodeValue) {
        _currentNode.nodeValue = strValidValue;
    }
    else {
        _currentNode.nodeValue = [NSString stringWithFormat:@"%@%@",
                                  _currentNode.nodeValue, strValidValue];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
#ifdef DEBUG
    NSLog(@"element end.");
#endif
    //
    _currentNode = _currentNode.nodeParent;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
#ifdef DEBUG
    NSLog(@"parse error:%@", parseError);
#endif
}

@end


#pragma mark - NSData(XMLParser)

@implementation NSData (XMLParser)

- (XMLNode *)xmlNode
{
    XMLParser *parser = [[XMLParser alloc] init];
    XMLNode *node = [parser parse:self];
    [parser release];
    return node;
}

@end


#pragma mark - NSString(XMLParser)

@implementation NSString (XMLParser)

- (XMLNode *)xmlNodeWithEncoding:(NSStringEncoding)encoding
{
    XMLParser *parser = [[XMLParser alloc] init];
    XMLNode *node = [parser parse:[self dataUsingEncoding:encoding]];
    [parser release];
    return node;
}

@end
