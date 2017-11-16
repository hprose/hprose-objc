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
 * Promise.h                                              *
 *                                                        *
 * Promise header for Objective-C.                        *
 *                                                        *
 * LastModified: Nov 16, 2017                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>

#ifdef UIKIT_EXTERN
#define PROMISE_QUEUE dispatch_get_main_queue()
#else
#define PROMISE_QUEUE dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#endif

extern NSString *const PromiseErrorDomain;

typedef NS_ENUM(NSInteger, PromiseError) {
    PromiseNoError = 0,                  // Never used
    PromiseIllegalArgumentError,         // Illegal argument was passed
    PromiseTimeoutError,                 // Timeout Error
    PromiseRuntimeError,                 // Runtime Error
    PromiseTypeError,                    // Type Error
    PromiseExceptionError,               // Error converted from NSException
};

@interface NSArray<ObjectType> (NSArrayFunctional)

- (void) each:(id (^)(ObjectType element, NSUInteger index))handler;
- (BOOL) every:(BOOL (^)(ObjectType element, NSUInteger index))handler;
- (BOOL) some:(BOOL (^)(ObjectType element, NSUInteger index))handler;
- (NSArray<ObjectType> *) filter:(BOOL (^)(ObjectType element, NSUInteger index))handler;
- (NSArray *) map:(id (^)(ObjectType element, NSUInteger index))handler;
- (id) reduce:(id (^)(id prev, ObjectType element, NSUInteger index))handler;
- (id) reduce:(id (^)(id prev, ObjectType element, NSUInteger index))handler init:(id)value;
- (id) reduceRight:(id (^)(id prev, ObjectType element, NSUInteger index))handler;
- (id) reduceRight:(id (^)(id prev, ObjectType element, NSUInteger index))handler init:(id)value;

@end

typedef enum {
    PENDING = 0,
    FULFILLED = 1,
    REJECTED = 2
} PromiseState;

@interface Promise : NSObject {
@private
    NSMutableArray *_subscribers;
    int32_t _state;
}

@property (readonly, getter=getState) PromiseState state;
@property (readonly) id result;
@property (readonly) NSError * reason;

- (id) init:(id (^)(void)) computation;

+ (void) setDispatchQueue:(dispatch_queue_t)queue;
+ (dispatch_queue_t) dispatchQueue;
+ (Promise *) promise;
+ (Promise *) promise:(id (^)(void))computation;
+ (Promise *) value:(id)result;
+ (Promise *) error:(id)reason;
+ (Promise *) delayed:(NSTimeInterval)duration with:(id)value;
+ (Promise *) delayed:(NSTimeInterval)duration block:(id (^)(void))computation;
+ (Promise *) sync:(id (^)(void))computation;
+ (BOOL) isPromise:(id)value;
+ (Promise *) toPromise:(id)value;
+ (Promise *) all:(NSArray *)array;
+ (Promise *) race:(NSArray *)array;
+ (Promise *) any:(NSArray *)array;
+ (Promise *) each:(id (^)(id element, NSUInteger index))handler with:(NSArray *)array;
+ (Promise *) every:(BOOL (^)(id element, NSUInteger index))handler with:(NSArray *)array;
+ (Promise *) some:(BOOL (^)(id element, NSUInteger index))handler with:(NSArray *)array;
+ (Promise *) filter:(BOOL (^)(id element, NSUInteger index))handler with:(NSArray *)array;
+ (Promise *) map:(id (^)(id element, NSUInteger index))handler with:(NSArray *)array;
+ (Promise *) reduce:(id (^)(id prev, id element, NSUInteger index))handler with:(NSArray *)array;
+ (Promise *) reduce:(id (^)(id prev, id element, NSUInteger index))handler with:(NSArray *)array init:(id)value;
+ (Promise *) reduceRight:(id (^)(id prev, id element, NSUInteger index))handler with:(NSArray *)array;
+ (Promise *) reduceRight:(id (^)(id prev, id element, NSUInteger index))handler with:(NSArray *)array init:(id)value;

- (PromiseState) getState;
- (void) resolve:(id)result;
- (void) reject:(id)reason;
- (Promise *) then:(id (^)(id))onfulfill catch:(id (^)(NSError *))onreject;
- (Promise *) then:(id (^)(id))onfulfill;
- (Promise *) done:(void (^)(id))onfulfill fail:(void (^)(NSError *))onreject;
- (Promise *) done:(void (^)(id))onfulfill;
- (Promise *) catch:(id (^)(NSError *))onreject with:(BOOL (^)(NSError *))test;
- (Promise *) catch:(id (^)(NSError *))onreject;
- (Promise *) fail:(void (^)(NSError *))onreject;
- (Promise *) whenComplete:(void (^)(void))action;
- (Promise *) complete:(id (^)(id))oncomplete;
- (Promise *) always:(void (^)(id))oncomplete;
- (void) fill:(Promise *)promise;
- (Promise *) timeout:(NSTimeInterval)duration with:(id)reason;
- (Promise *) timeout:(NSTimeInterval)duration;
- (Promise *) delay:(NSTimeInterval)duration;
- (Promise *) tap:(void (^)(id))onfulfilledSideEffect;

- (Promise *) all;
- (Promise *) race;
- (Promise *) any;
- (Promise *) each:(id (^)(id element, NSUInteger index))handler;
- (Promise *) every:(BOOL (^)(id element, NSUInteger index))handler;
- (Promise *) some:(BOOL (^)(id element, NSUInteger index))handler;
- (Promise *) filter:(BOOL (^)(id element, NSUInteger index))handler;
- (Promise *) map:(id (^)(id element, NSUInteger index))handler;
- (Promise *) reduce:(id (^)(id prev, id element, NSUInteger index))handler;
- (Promise *) reduce:(id (^)(id prev, id element, NSUInteger index))handler init:(id)value;
- (Promise *) reduceRight:(id (^)(id prev, id element, NSUInteger index))handler;
- (Promise *) reduceRight:(id (^)(id prev, id element, NSUInteger index))handler init:(id)value;
- (Promise *) wait;
@end

