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
 * LastModified: Dec 4, 2016                              *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>

// Hprose class manager
@interface HproseClassManager : NSObject

// Register the class with alias.
+ (void) registerClass:(Class)cls withAlias:(NSString *)alias;

// Get alias of class.
+ (NSString *) getClassAlias:(Class)cls;

// Get class by alias.
+ (Class) getClass:(NSString *)alias;

// Whether the class is registered with alias.
+ (BOOL) containsClass:(NSString *)alias;

@end
