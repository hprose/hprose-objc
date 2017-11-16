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
 * HproseInvokeSettings.h                                 *
 *                                                        *
 * hprose invoke settings header for Objective-C.         *
 *                                                        *
 * LastModified: Nov 16, 2017                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>
#import "HproseResultMode.h"

typedef void (^HproseBlock)(id, NSArray *);
typedef void (^HproseErrorBlock)(NSString *, NSError *);

typedef void (*HproseCallback)(id, NSArray *);
typedef void (*HproseErrorCallback)(NSString *, NSError *);

@interface HproseInvokeSettings : NSObject {
@private
    NSNumber * _byref;
    NSNumber * _simple;
    NSNumber * _idempotent;
    NSNumber * _failswitch;
    NSNumber * _oneway;
    NSNumber * _retry;
    NSNumber * _timeout;
}

@property HproseResultMode mode;
@property (getter = getByref, setter = setByref:) BOOL byref;
@property (getter = getSimple, setter = setSimple:) BOOL simple;
@property (getter = getIdempotent, setter = setIdempotent:) BOOL idempotent;
@property (getter = getFailswitch, setter = setFailswitch:) BOOL failswitch;
@property (getter = getOneway, setter = setOneway:) BOOL oneway;
@property (getter = getRetry, setter = setRetry:) NSUInteger retry;
@property (getter = getTimeout, setter = setTimeout:) NSTimeInterval timeout;
@property (copy, nonatomic) HproseBlock block;
@property (copy, nonatomic) HproseErrorBlock errorBlock;
@property (assign, nonatomic) HproseCallback callback;
@property (assign, nonatomic) HproseErrorCallback errorCallback;
@property (assign, nonatomic) SEL selector;
@property (assign, nonatomic) SEL errorSelector;
@property id delegate;
@property Class resultClass;
@property char resultType;
@property BOOL async;

- (id) init:(NSDictionary *)settings;

+ (HproseInvokeSettings *) settings:(NSDictionary *)settings;

- (BOOL) getByref;
- (void) setByref:(BOOL)value;
- (BOOL) getSimple;
- (void) setSimple:(BOOL)value;
- (BOOL) getIdempotent;
- (void) setIdempotent:(BOOL)value;
- (BOOL) getFailswitch;
- (void) setFailswitch:(BOOL)value;
- (BOOL) getOneway;
- (void) setOneway:(BOOL)value;
- (NSUInteger) getRetry;
- (void) setRetry:(NSUInteger)value;
- (NSTimeInterval) getTimeout;
- (void) setTimeout:(NSTimeInterval)value;

- (void) copyTo:(HproseInvokeSettings *)settings;

@end
