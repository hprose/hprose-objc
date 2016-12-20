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
 * LastModified: Dec 20, 2016                             *
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

@class HproseClientContext;

@protocol HproseTransporter <NSObject>

@optional

- (Promise *) sendAndReceive:(NSData *)data context:(HproseClientContext *)context;

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
    NSMutableArray<NSString *> *uriList;
    NSUInteger index;
    NSString *_uri;
    HproseNextInvokeHandler invokeHandler, defaultInvokeHandler;
    HproseNextFilterHandler beforeFilterHandler, defaultBeforeFilterHandler;
    HproseNextFilterHandler afterFilterHandler, defaultAfterFilterHandler;
    Promise * autoId;
    NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, HproseTopic *> *> *allTopics;
}

@property (getter = getUri, setter = setUri:) NSString *uri;
@property (getter = getUriList, setter = setUriList:) NSArray<NSString *> *uriList;
@property (getter = getFilter, setter = setFilter:) id<HproseFilter> filter;
@property id delegate;
@property NSUInteger retry;
@property BOOL idempontent;
@property BOOL failswitch;
@property (readonly) NSUInteger failround;
@property BOOL byref;
@property BOOL simple;
@property NSTimeInterval timeout;
@property (assign, nonatomic) SEL onError;
@property (assign, nonatomic) SEL onFailswitch;
@property (assign, nonatomic) HproseErrorCallback errorCallback;
@property (copy, nonatomic) HproseErrorBlock errorHandler;
@property (readonly) HproseFilterHandlerManager *beforeFilter;
@property (readonly) HproseFilterHandlerManager *afterFilter;
@property (readonly) NSString *clientId;

+ (id) client;
+ (id) client:(id)uri;

- (id) init:(id)uri;

- (void) close:(BOOL)cancelPendingTasks;
- (void) close;

- (id) useService:(Protocol *)protocol;
- (id) useService:(Protocol *)protocol withNameSpace:(NSString *)ns;

- (NSString *) getUri;
- (void) setUri:(NSString *)value;
- (NSArray<NSString *> *) getUriList;
- (void) setUriList:(NSArray<NSString *> *)value;
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

- (void) subscribe:(NSString *)name id:(NSString *)clientId callback:(void (^)(id))callback;
- (void) subscribe:(NSString *)name id:(NSString *)clientId callback:(void (^)(id))callback timeout:(NSTimeInterval)timeout;

- (void) subscribe:(NSString *)name id:(NSString *)clientId callback:(void (^)(id))callback resultType:(char)resultType;
- (void) subscribe:(NSString *)name id:(NSString *)clientId callback:(void (^)(id))callback resultType:(char)resultType timeout:(NSTimeInterval)timeout;

- (void) subscribe:(NSString *)name id:(NSString *)clientId callback:(void (^)(id))callback resultClass:(Class)resultClass;
- (void) subscribe:(NSString *)name id:(NSString *)clientId callback:(void (^)(id))callback resultClass:(Class)resultClass timeout:(NSTimeInterval)timeout;

- (void) unsubscribe:(NSString *)name;
- (void) unsubscribe:(NSString *)name callback:(void (^)(id))callback;
- (void) unsubscribe:(NSString *)name id:(NSString *)clientId;
- (void) unsubscribe:(NSString *)name id:(NSString *)clientId callback:(void (^)(id))callback;

- (BOOL) isSubscribed:(NSString *)name;
- (NSArray<NSString *> *) subscribedList;

@end

@interface HproseClientContext : HproseContext;

@property (readonly) HproseClient* client;
@property (readonly) HproseInvokeSettings *settings;
@property NSInteger retried;

- (id) init:(HproseClient *)client settings:(HproseInvokeSettings *)settings;

@end
