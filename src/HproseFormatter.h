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
 * HproseFormatter.h                                      *
 *                                                        *
 * hprose formatter class header for Objective-C.         *
 *                                                        *
 * LastModified: Apr 12, 2014                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>

@interface HproseFormatter : NSObject;

+ (NSData *) serialize:(id)obj;
+ (NSData *) serialize:(id)obj simple:(BOOL)simple;

+ (id) unserialize:(NSData *)data;
+ (id) unserialize:(NSData *)data withClass:(Class)cls;
+ (id) unserialize:(NSData *)data withType:(char)type;
+ (id) unserialize:(NSData *)data withClass:(Class)cls withType:(char)type;
+ (id) unserialize:(NSData *)data simple:(BOOL)simple;
+ (id) unserialize:(NSData *)data withClass:(Class)cls simple:(BOOL)simple;
+ (id) unserialize:(NSData *)data withType:(char)type simple:(BOOL)simple;
+ (id) unserialize:(NSData *)data withClass:(Class)cls withType:(char)type simple:(BOOL)simple;

@end