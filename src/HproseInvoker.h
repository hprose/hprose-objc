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
 * LastModified: Apr 10, 2014                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>
#import "HproseResultMode.h"

typedef void (*HproseCallback)(id, NSArray *);
typedef void (^HproseBlock)(id, NSArray *);

@protocol HproseInvoker

- (id) invoke:(NSString *)name;
- (id) invoke:(NSString *)name resultType:(char)type;
- (id) invoke:(NSString *)name resultClass:(Class)cls;
- (id) invoke:(NSString *)name resultMode:(HproseResultMode)mode;

- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args;
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultType:(char)type;
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultClass:(Class)cls;
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultMode:(HproseResultMode)mode;

- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args simpleMode:(BOOL)simple;
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultType:(char)type simpleMode:(BOOL)simple;
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultClass:(Class)cls simpleMode:(BOOL)simple;
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple;

- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef;
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultType:(char)type;
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultClass:(Class)cls;
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode;

- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple;
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultType:(char)type simpleMode:(BOOL)simple;
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultClass:(Class)cls simpleMode:(BOOL)simple;
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple;

- (oneway void) invoke:(NSString *)name callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name resultType:(char)type callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name resultClass:(Class)cls callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name resultMode:(HproseResultMode)mode callback:(HproseCallback)callback;

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultType:(char)type callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultClass:(Class)cls callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultMode:(HproseResultMode)mode callback:(HproseCallback)callback;

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args simpleMode:(BOOL)simple callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultType:(char)type simpleMode:(BOOL)simple callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultClass:(Class)cls simpleMode:(BOOL)simple callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple callback:(HproseCallback)callback;

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultType:(char)type callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultClass:(Class)cls callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode callback:(HproseCallback)callback;

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultType:(char)type simpleMode:(BOOL)simple callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultClass:(Class)cls simpleMode:(BOOL)simple callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple callback:(HproseCallback)callback;

- (oneway void) invoke:(NSString *)name selector:(SEL)selector;
- (oneway void) invoke:(NSString *)name delegate:(id)delegate;
- (oneway void) invoke:(NSString *)name selector:(SEL)selector delegate:(id)delegate;

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args selector:(SEL)selector;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args delegate:(id)delegate;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args selector:(SEL)selector delegate:(id)delegate;

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args simpleMode:(BOOL)simple selector:(SEL)selector;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args simpleMode:(BOOL)simple delegate:(id)delegate;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args simpleMode:(BOOL)simple selector:(SEL)selector delegate:(id)delegate;

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef selector:(SEL)selector;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef delegate:(id)delegate;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef selector:(SEL)selector delegate:(id)delegate;

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple selector:(SEL)selector;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple delegate:(id)delegate;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple selector:(SEL)selector delegate:(id)delegate;

- (oneway void) invoke:(NSString *)name block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name resultType:(char)type block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name resultClass:(Class)cls block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name resultMode:(HproseResultMode)mode block:(HproseBlock)block;

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultType:(char)type block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultClass:(Class)cls block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultMode:(HproseResultMode)mode block:(HproseBlock)block;

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args simpleMode:(BOOL)simple block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultType:(char)type simpleMode:(BOOL)simple block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultClass:(Class)cls simpleMode:(BOOL)simple block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple block:(HproseBlock)block;

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultType:(char)type block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultClass:(Class)cls block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode block:(HproseBlock)block;

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultType:(char)type simpleMode:(BOOL)simple block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultClass:(Class)cls simpleMode:(BOOL)simple block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple block:(HproseBlock)block;
@end