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
 * LastModified: Dec 20, 2016                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>
#import "HproseContext.h"

typedef Promise *(^HproseNextInvokeHandler)(NSString *name, NSArray *args, HproseContext *context);
typedef Promise *(^HproseInvokeHandler)(NSString *name, NSArray *args, HproseContext *context, HproseNextInvokeHandler next);
typedef Promise *(^HproseNextFilterHandler)(NSData *request, HproseContext *context);
typedef Promise *(^HproseFilterHandler)(NSData *request, HproseContext *context, HproseNextFilterHandler next);
