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
 * hprose class manager header for Objective-C.           *
 *                                                        *
 * LastModified: Apr 10, 2014                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>

@interface HproseClassManager : NSObject

+ (void) registerClass:(Class)cls withAlias:(NSString *)alias;
+ (NSString *) getClassAlias:(Class)cls;
+ (Class) getClass:(NSString *)alias;
+ (BOOL) containsClass:(NSString *)alias;

@end
