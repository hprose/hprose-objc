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
 * HproseResultMode.h                                     *
 *                                                        *
 * hprose tags header for Objective-C.                    *
 *                                                        *
 * LastModified: Apr 10, 2014                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

typedef enum {
    HproseResultMode_Normal,
    HproseResultMode_Serialized,
    HproseResultMode_Raw,
    HproseResultMode_RawWithEndTag,
} HproseResultMode;