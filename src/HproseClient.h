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
 * HproseClient.h                                         *
 *                                                        *
 * hprose client header for Objective-C.                  *
 *                                                        *
 * LastModified: Jun 5, 2016                              *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>
#import "Promise.h"
#import "HproseInvoker.h"
#import "HproseInvokeSettings.h"
#import "HproseFilter.h"
#import "HproseContext.h"
#import "HproseHandlers.h"

@protocol HproseTransporter <NSObject>

@optional

- (id) sendAndReceive:(NSData *)data timeout:(NSTimeInterval)timeout;

- (oneway void) sendAsync:(NSData *)data timeout:(NSTimeInterval)timeout
                receiveAsync:(void (^)(NSData *))receiveCallback
                error:(void (^)(NSException *))errorCallback;
@end

@interface HproseFilterHandlerManager : NSObject {
@private
    id _delegate;
    SEL _selector;
}

- (id) init:(SEL)selector with:(id)delegate;
- (HproseFilterHandlerManager *) use:(HproseFilterHandler)handler;

@end

@interface HproseTopic : NSObject{}

@property NSMutableArray<void(^)(id)> *callbacks;
@property (copy, nonatomic) void(^handler)(id);

@end

@interface HproseClient : NSObject<HproseInvoker, HproseTransporter> {
@private
    NSMutableArray<id<HproseFilter>> *filters;
    NSMutableArray<HproseInvokeHandler> *invokeHandlers;
    NSMutableArray<HproseFilterHandler> *beforeFilterHandlers;
    NSMutableArray<HproseFilterHandler> *afterFilterHandlers;
    NSMutableArray<NSString *> *uris;
    int64_t index;
    HproseNextInvokeHandler invokeHandler, defaultInvokeHandler;
    HproseNextFilterHandler beforeFilterHandler, defaultBeforeFilterHandler;
    HproseNextFilterHandler afterFilterHandler, defaultAfterFilterHandler;
    Promise * autoId;
    NSMutableDictionary<NSString *, NSMutableDictionary<NSNumber *, HproseTopic *> *> *allTopics;
}

@property (copy) NSString *uri;
@property (getter = getFilter, setter = setFilter:)id<HproseFilter> filter;
@property id delegate;
@property NSUInteger retry;
@property BOOL idempontent;
@property BOOL failswitch;
@property BOOL byref;
@property BOOL simple;
@property NSTimeInterval timeout;
@property (assign, nonatomic) SEL onError;
@property (assign, nonatomic) HproseErrorCallback errorCallback;
@property (copy, nonatomic) HproseErrorBlock errorHandler;
@property (readonly) HproseFilterHandlerManager *beforeFilter;
@property (readonly) HproseFilterHandlerManager *afterFilter;
@property (readonly) NSNumber *clientId;

+ (id) client;
+ (id) client:(NSString *)uri;

- (id) init:(NSString *)uri;

- (void) close:(BOOL)cancelPendingTasks;
- (void) close;

- (id) useService:(Protocol *)protocol;
- (id) useService:(Protocol *)protocol withNameSpace:(NSString *)ns;

- (id<HproseFilter>) getFilter;
- (void) setFilter:(id<HproseFilter>)filter;
- (void) addFilter:(id<HproseFilter>)filter;
- (void) removeFilter:(id<HproseFilter>)filter;
- (void) addInvokeHandler:(HproseInvokeHandler)handler;
- (void) addBeforeFilterHandler:(HproseFilterHandler)handler;
- (void) addAfterFilterHandler:(HproseFilterHandler)handler;
- (HproseClient *) use:(HproseInvokeHandler)handler;

- (void) subscribe:(NSString *)name callback:(void (^)(id))callback;
- (void) subscribe:(NSString *)name callback:(void (^)(id))callback timeout:(NSTimeInterval)timeout;

- (void) subscribe:(NSString *)name callback:(void (^)(id))callback resultType:(char)resultType;
- (void) subscribe:(NSString *)name callback:(void (^)(id))callback resultType:(char)resultType timeout:(NSTimeInterval)timeout;
- (void) subscribe:(NSString *)name callback:(void (^)(id))callback resultClass:(Class)resultClass;
- (void) subscribe:(NSString *)name callback:(void (^)(id))callback resultClass:(Class)resultClass timeout:(NSTimeInterval)timeout;

- (void) subscribe:(NSString *)name id:(int32_t)clientId callback:(void (^)(id))callback;
- (void) subscribe:(NSString *)name id:(int32_t)clientId callback:(void (^)(id))callback timeout:(NSTimeInterval)timeout;

- (void) subscribe:(NSString *)name id:(int32_t)clientId callback:(void (^)(id))callback resultType:(char)resultType;
- (void) subscribe:(NSString *)name id:(int32_t)clientId callback:(void (^)(id))callback resultType:(char)resultType timeout:(NSTimeInterval)timeout;

- (void) subscribe:(NSString *)name id:(int32_t)clientId callback:(void (^)(id))callback resultClass:(Class)resultClass;
- (void) subscribe:(NSString *)name id:(int32_t)clientId callback:(void (^)(id))callback resultClass:(Class)resultClass timeout:(NSTimeInterval)timeout;

- (void) unsubscribe:(NSString *)name;
- (void) unsubscribe:(NSString *)name callback:(void (^)(id))callback;
- (void) unsubscribe:(NSString *)name id:(int32_t)clientId;
- (void) unsubscribe:(NSString *)name id:(int32_t)clientId callback:(void (^)(id))callback;

@end

@interface HproseClientContext : HproseContext;

@property (readonly) HproseClient* client;
@property (readonly) HproseInvokeSettings *settings;

- (id) init:(HproseClient *)client settings:(HproseInvokeSettings *)settings;

@end