//
//  UIMacro.h
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//


#import "UIDevice+Custom.h"

#define IsIphone5()  (568.0f==[UIScreen mainScreen].bounds.size.height)
#define IsPad()      (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
#define PathOfResource(name, type)  [[NSBundle mainBundle] pathForResource:name ofType:type]



#ifdef DEBUG
#define UILog(fmt,...)   NSLog((@"UI->%s(%d):" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define UILog(fmt,...)   NSLog(fmt, ##__VA_ARGS__)
#endif
