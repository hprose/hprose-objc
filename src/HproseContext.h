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
 * HproseContext.h                                        *
 *                                                        *
 * hprose context header for Objective-C.                 *
 *                                                        *
 * LastModified: May 17, 2015                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>

@interface HproseContext : NSObject

@property (readonly) NSMutableDictionary *userData;

@end