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
 * LastModified: Dec 3, 2016                              *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>
#import "HproseResultMode.h"

@protocol HproseInvoker

- (id _Null_unspecified) invoke:(NSString * _Nonnull)name;
- (id _Null_unspecified) invoke:(NSString * _Nonnull)name settings:(id _Nullable)settings;

- (id _Null_unspecified) invoke:(NSString * _Nonnull)name withArgs:(NSArray * _Nullable)args;
- (id _Null_unspecified) invoke:(NSString * _Nonnull)name withArgs:(NSArray * _Nullable)args settings:(id _Nullable)settings;

- (Promise * _Nonnull) asyncInvoke:(NSString * _Nonnull)name;
- (Promise * _Nonnull) asyncInvoke:(NSString * _Nonnull)name settings:(id _Nullable)settings;

- (Promise * _Nonnull) asyncInvoke:(NSString * _Nonnull)name withArgs:(NSArray * _Nullable)args;
- (Promise * _Nonnull) asyncInvoke:(NSString * _Nonnull)name withArgs:(NSArray * _Nullable)args settings:(id _Nullable)settings;

@end
