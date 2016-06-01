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
 * LastModified: Jun 2, 2016                              *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>
#import "HproseInvoker.h"
#import "HproseInvokeSettings.h"
#import "HproseFilter.h"
#import "HproseContext.h"
#import "HproseHandlers.h"

@protocol HproseTransporter <NSObject>

@optional

- (NSData *) sendAndReceive:(NSData *)data;

- (oneway void) sendAsync:(NSData *)data
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


@end

@interface HproseClientContext : HproseContext;

@property HproseClient* client;
@property HproseInvokeSettings *settings;

- (id) init:(HproseClient *)client settings:(HproseInvokeSettings *)settings;

@end