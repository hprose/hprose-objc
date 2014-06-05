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
 * HproseException.m                                      *
 *                                                        *
 * hprose exception class for Objective-C.                *
 *                                                        *
 * LastModified: Apr 10, 2014                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import "HproseException.h"

@implementation HproseException

+ (HproseException *)exceptionWithReason:(NSString *)reason {
    return (HproseException *)[HproseException
        exceptionWithName:@"HproseException"
        reason:reason
        userInfo:nil];
}

@end
