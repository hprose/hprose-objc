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
 * HproseException.h                                      *
 *                                                        *
 * hprose exception class header for Objective-C.         *
 *                                                        *
 * LastModified: Dec 23, 2016                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>


extern NSString *const HproseErrorDomain;

typedef NS_ENUM(NSInteger, HproseError) {
    HproseNoError = 0,                  // Never used
    HproseSerializeError,               // Serialize Error
    HproseUnserializeError,             // Unserialize Error
    HproseInvokeError,                  // Invoke Error
};
