/**********************************************************\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: http://www.hprose.com/                 |
|                   http://www.hprose.org/                 |
|                                                          |
\**********************************************************/
/**********************************************************\
 *                                                        *
 * HproseHandlers.h                                       *
 *                                                        *
 * hprose handlers header for Objective-C.                *
 *                                                        *
 * LastModified: May 30, 2016                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>
#import "HproseContext.h"

typedef id(^HproseNextInvokeHandler)(NSString *name, NSArray *args, HproseContext *context);
typedef id(^HproseInvokeHandler)(NSString *name, NSArray *args, HproseContext *context, HproseNextInvokeHandler next);
typedef id(^HproseNextFilterHandler)(NSData *request, HproseContext *context);
typedef id(^HproseFilterHandler)(NSData *request, HproseContext *context, HproseNextFilterHandler next);