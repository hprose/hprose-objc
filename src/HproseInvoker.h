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
 * LastModified: Jun 15, 2015                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>
#import "HproseResultMode.h"

typedef void (*HproseCallback)(id, NSArray *);
typedef void (^HproseBlock)(id, NSArray *);

typedef void (*HproseErrorCallback)(NSString *, NSException *);
typedef void (^HproseErrorBlock)(NSString *, NSException *);

@protocol HproseInvoker

- (id) invoke:(NSString *)name;
- (id) invoke:(NSString *)name resultType:(char)type;
- (id) invoke:(NSString *)name resultClass:(Class)cls;
- (id) invoke:(NSString *)name resultMode:(HproseResultMode)mode;

- (id) invoke:(NSString *)name withArgs:(NSArray *)args;
- (id) invoke:(NSString *)name withArgs:(NSArray *)args resultType:(char)type;
- (id) invoke:(NSString *)name withArgs:(NSArray *)args resultClass:(Class)cls;
- (id) invoke:(NSString *)name withArgs:(NSArray *)args resultMode:(HproseResultMode)mode;

- (id) invoke:(NSString *)name withArgs:(NSArray *)args simpleMode:(BOOL)simple;
- (id) invoke:(NSString *)name withArgs:(NSArray *)args resultType:(char)type simpleMode:(BOOL)simple;
- (id) invoke:(NSString *)name withArgs:(NSArray *)args resultClass:(Class)cls simpleMode:(BOOL)simple;
- (id) invoke:(NSString *)name withArgs:(NSArray *)args resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple;

- (id) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef;
- (id) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultType:(char)type;
- (id) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultClass:(Class)cls;
- (id) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode;

- (id) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple;
- (id) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultType:(char)type simpleMode:(BOOL)simple;
- (id) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultClass:(Class)cls simpleMode:(BOOL)simple;
- (id) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple;

- (oneway void) invoke:(NSString *)name callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback;
- (oneway void) invoke:(NSString *)name resultType:(char)type callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name resultType:(char)type callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback;
- (oneway void) invoke:(NSString *)name resultClass:(Class)cls callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name resultClass:(Class)cls callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback;
- (oneway void) invoke:(NSString *)name resultMode:(HproseResultMode)mode callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name resultMode:(HproseResultMode)mode callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback;

- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultType:(char)type callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultType:(char)type callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultClass:(Class)cls callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultClass:(Class)cls callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultMode:(HproseResultMode)mode callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultMode:(HproseResultMode)mode callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback;

- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args simpleMode:(BOOL)simple callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args simpleMode:(BOOL)simple callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultType:(char)type simpleMode:(BOOL)simple callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultType:(char)type simpleMode:(BOOL)simple callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultClass:(Class)cls simpleMode:(BOOL)simple callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultClass:(Class)cls simpleMode:(BOOL)simple callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback;

- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultType:(char)type callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultType:(char)type callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultClass:(Class)cls callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultClass:(Class)cls callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback;

- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultType:(char)type simpleMode:(BOOL)simple callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultType:(char)type simpleMode:(BOOL)simple callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultClass:(Class)cls simpleMode:(BOOL)simple callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultClass:(Class)cls simpleMode:(BOOL)simple callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback;

- (oneway void) invoke:(NSString *)name selector:(SEL)selector;
- (oneway void) invoke:(NSString *)name selector:(SEL)selector error:(SEL)errorSelector;
- (oneway void) invoke:(NSString *)name delegate:(id)delegate;
- (oneway void) invoke:(NSString *)name error:(SEL)errorSelector delegate:(id)delegate;
- (oneway void) invoke:(NSString *)name selector:(SEL)selector delegate:(id)delegate;
- (oneway void) invoke:(NSString *)name selector:(SEL)selector error:(SEL)errorSelector delegate:(id)delegate;

- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args selector:(SEL)selector;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args selector:(SEL)selector error:(SEL)errorSelector;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args delegate:(id)delegate;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args error:(SEL)errorSelector delegate:(id)delegate;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args selector:(SEL)selector delegate:(id)delegate;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args selector:(SEL)selector error:(SEL)errorSelector delegate:(id)delegate;

- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args simpleMode:(BOOL)simple selector:(SEL)selector;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args simpleMode:(BOOL)simple selector:(SEL)selector error:(SEL)errorSelector;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args simpleMode:(BOOL)simple delegate:(id)delegate;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args simpleMode:(BOOL)simple error:(SEL)errorSelector delegate:(id)delegate;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args simpleMode:(BOOL)simple selector:(SEL)selector delegate:(id)delegate;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args simpleMode:(BOOL)simple selector:(SEL)selector error:(SEL)errorSelector delegate:(id)delegate;

- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef selector:(SEL)selector;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef selector:(SEL)selector error:(SEL)errorSelector;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef delegate:(id)delegate;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef error:(SEL)errorSelector delegate:(id)delegate;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef selector:(SEL)selector delegate:(id)delegate;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef selector:(SEL)selector error:(SEL)errorSelector delegate:(id)delegate;

- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple selector:(SEL)selector;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple selector:(SEL)selector error:(SEL)errorSelector;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple delegate:(id)delegate;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple error:(SEL)errorSelector delegate:(id)delegate;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple selector:(SEL)selector delegate:(id)delegate;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple selector:(SEL)selector error:(SEL)errorSelector delegate:(id)delegate;

- (oneway void) invoke:(NSString *)name block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name block:(HproseBlock)block error:(HproseErrorBlock)errorBlock;
- (oneway void) invoke:(NSString *)name resultType:(char)type block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name resultType:(char)type block:(HproseBlock)block error:(HproseErrorBlock)errorBlock;
- (oneway void) invoke:(NSString *)name resultClass:(Class)cls block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name resultClass:(Class)cls block:(HproseBlock)block error:(HproseErrorBlock)errorBlock;
- (oneway void) invoke:(NSString *)name resultMode:(HproseResultMode)mode block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name resultMode:(HproseResultMode)mode block:(HproseBlock)block error:(HproseErrorBlock)errorBlock;

- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args block:(HproseBlock)block error:(HproseErrorBlock)errorBlock;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultType:(char)type block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultType:(char)type block:(HproseBlock)block error:(HproseErrorBlock)errorBlock;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultClass:(Class)cls block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultClass:(Class)cls block:(HproseBlock)block error:(HproseErrorBlock)errorBlock;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultMode:(HproseResultMode)mode block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultMode:(HproseResultMode)mode block:(HproseBlock)block error:(HproseErrorBlock)errorBlock;

- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args simpleMode:(BOOL)simple block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args simpleMode:(BOOL)simple block:(HproseBlock)block error:(HproseErrorBlock)errorBlock;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultType:(char)type simpleMode:(BOOL)simple block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultType:(char)type simpleMode:(BOOL)simple block:(HproseBlock)block error:(HproseErrorBlock)errorBlock;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultClass:(Class)cls simpleMode:(BOOL)simple block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultClass:(Class)cls simpleMode:(BOOL)simple block:(HproseBlock)block error:(HproseErrorBlock)errorBlock;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple block:(HproseBlock)block error:(HproseErrorBlock)errorBlock;

- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef block:(HproseBlock)block error:(HproseErrorBlock)errorBlock;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultType:(char)type block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultType:(char)type block:(HproseBlock)block error:(HproseErrorBlock)errorBlock;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultClass:(Class)cls block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultClass:(Class)cls block:(HproseBlock)block error:(HproseErrorBlock)errorBlock;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode block:(HproseBlock)block error:(HproseErrorBlock)errorBlock;

- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple block:(HproseBlock)block error:(HproseErrorBlock)errorBlock;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultType:(char)type simpleMode:(BOOL)simple block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultType:(char)type simpleMode:(BOOL)simple block:(HproseBlock)block error:(HproseErrorBlock)errorBlock;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultClass:(Class)cls simpleMode:(BOOL)simple block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultClass:(Class)cls simpleMode:(BOOL)simple block:(HproseBlock)block error:(HproseErrorBlock)errorBlock;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple block:(HproseBlock)block error:(HproseErrorBlock)errorBlock;

- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultClass:(Class)cls resultType:(char)type resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple callback:(HproseCallback)callback block:(HproseBlock)block selector:(SEL)selector errorCallback:(HproseErrorCallback)errorCallback errorBlock:(HproseErrorBlock)errorBlock errorSelector:(SEL)errorSelector delegate:(id)delegate;
@end