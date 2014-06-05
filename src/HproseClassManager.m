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
 * HproseClassManager.h                                   *
 *                                                        *
 * hprose class manager for Objective-C.                  *
 *                                                        *
 * LastModified: Apr 10, 2014                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import "HproseClassManager.h"

@implementation HproseClassManager

static NSMutableDictionary *gClassCache1;
static NSMutableDictionary *gClassCache2;

+ (void) initialize {
    if (self == [HproseClassManager class]) {
        gClassCache1 = [[NSMutableDictionary alloc] init];
        gClassCache2 = [[NSMutableDictionary alloc] init];
    }
}

+ (void) registerClass:(Class)cls withAlias:(NSString *)alias {
    @synchronized (gClassCache1) {
        if (cls == Nil) {
            gClassCache1[[NSNull null]] = alias;
        }
        else {
            gClassCache1[(id)cls] = alias;
        }
    }
    @synchronized (gClassCache2) {
        if (cls == Nil) {
            gClassCache2[alias] = [NSNull null];
        }
        else {
            gClassCache2[alias] = cls;
        }
    }
}

+ (NSString *) getClassAlias:(Class)cls {
    NSString *alias = nil;
    @synchronized (gClassCache1) {
        alias = gClassCache1[cls];
    }
    return alias;
}

+ (Class) getClass:(NSString *)alias {
    id cls = Nil;
    @synchronized (gClassCache2) {
        cls = gClassCache2[alias];
    }
    if (cls == [NSNull null]) cls = Nil;
    return cls;
}

+ (BOOL) containsClass:(NSString *)alias {
    BOOL contains = NO;
    @synchronized (gClassCache2) {
        contains = (gClassCache2[alias] != nil);
    }
    return contains;
}

@end
