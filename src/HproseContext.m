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
 * HproseContext.m                                        *
 *                                                        *
 * hprose context for Objective-C.                        *
 *                                                        *
 * LastModified: May 17, 2015                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import "HproseContext.h"

@implementation HproseContext

- (id) init {
    if (self = [super init]) {
        _userData = [NSMutableDictionary dictionary];
    }
    return self;
}

@end
