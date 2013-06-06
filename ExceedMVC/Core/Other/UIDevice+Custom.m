//
//  UIDevice+Custom.m
//  
//
//  Created by Jianhong Yang on 12-1-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIDevice+Custom.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#include <arpa/inet.h>
#include <ifaddrs.h>


@implementation UIDevice (Custom)

// 系统版本号
+ (NSUInteger)systemVersionID
{
    NSString *systemVersion = [UIDevice currentDevice].systemVersion;
    NSUInteger versionMajor = 0, versionMinor = 0, versionBugFix = 0;
    //
    if (systemVersion.length == 0) {
        return 0;
    }
    //
    NSArray *arrayVersion = [systemVersion componentsSeparatedByString:@"."];
    //versionMajor
    if (arrayVersion.count > 0) {
        versionMajor = [[arrayVersion objectAtIndex:0] intValue];
    }
    //versionMinor
    if (arrayVersion.count > 1) {
        versionMinor = [[arrayVersion objectAtIndex:1] intValue];
    }
    //versionBugFix
    if (arrayVersion.count > 2) {
        versionBugFix = [[arrayVersion objectAtIndex:2] intValue];
    }
    //
    return 10000*versionMajor + 100*versionMinor + versionBugFix;
}

// 取MAC地址
+ (NSString *)macAddress
{
	int                    mib[6];
	size_t                len;
	char                *buf;
	unsigned char        *ptr;
	struct if_msghdr    *ifm;
	struct sockaddr_dl    *sdl;
	
	mib[0] = CTL_NET;
	mib[1] = AF_ROUTE;
	mib[2] = 0;
	mib[3] = AF_LINK;
	mib[4] = NET_RT_IFLIST;
	
	if ((mib[5] = if_nametoindex("en0")) == 0) {
		//printf("Error: if_nametoindex error/n");
		return nil;
	}
	
	if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
		//printf("Error: sysctl, take 1/n");
		return nil;
	}
	
	if ((buf = malloc(len)) == NULL) {
		//printf("Could not allocate memory. error!/n");
		return nil;
	}
	
	if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
		//printf("Error: sysctl, take 2");
		return nil;
	}
	
	ifm = (struct if_msghdr *)buf;
	sdl = (struct sockaddr_dl *)(ifm + 1);
	ptr = (unsigned char *)LLADDR(sdl);
	NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", 
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
	//NSString *outstring = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", 
    //                       *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
	free(buf);
	return [outstring uppercaseString];
}

// 局域网IP
+ (NSString *)localIPAddress
{
    NSString *localIP = nil;
    struct ifaddrs *addrs;
    if (getifaddrs(&addrs)==0) {
        const struct ifaddrs *cursor = addrs;
        while (cursor != NULL) {
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
            {
                //NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                //if ([name isEqualToString:@"en0"]) // Wi-Fi adapter
                {
                    localIP = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
                    break;
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return localIP;
}

@end
