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
 * HproseFilter.h                                         *
 *                                                        *
 * hprose filter protocol for Objective-C.                *
 *                                                        *
 * LastModified: Apr 10, 2014                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>

@protocol HproseFilter

- (NSData *) inputFilter:(NSData *) data withContext:(id) context;
- (NSData *) outputFilter:(NSData *) data withContext:(id) context;

@end
