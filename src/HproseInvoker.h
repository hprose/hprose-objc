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
 * HproseInvoker.h                                        *
 *                                                        *
 * hprose invoker protocol for Objective-C.               *
 *                                                        *
 * LastModified: May 26, 2016                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>
#import "HproseResultMode.h"

@protocol HproseInvoker

- (id) invoke:(NSString *)name;
- (id) invoke:(NSString *)name settings:(id)settings;

- (id) invoke:(NSString *)name withArgs:(NSArray *)args;
- (id) invoke:(NSString *)name withArgs:(NSArray *)args settings:(id)settings;

@end