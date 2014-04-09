/**********************************************************\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: http://www.hprose.com/                 |
|                   http://www.hprose.net/                 |
|                   http://www.hprose.org/                 |
|                                                          |
\**********************************************************/
/**********************************************************\
 *                                                        *
 * HproseProperty.h                                       *
 *                                                        *
 * hprose property class header for Objective-C.          *
 *                                                        *
 * LastModified: Jul 2, 2011                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

#import <objc/runtime.h>
#import <Foundation/Foundation.h>

@interface HproseProperty : NSObject

@property (copy) NSString *name;
@property char type;
@property (assign) Class class;
@property SEL getter;
@property IMP getterImp;
@property SEL setter;
@property IMP setterImp;

@end
