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
 * HproseWriter.h                                         *
 *                                                        *
 * hprose writer class header for Objective-C.            *
 *                                                        *
 * LastModified: Apr 12, 2014                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>

@protocol HproseWriterRefer <NSObject>
- (void) set:(id)obj;
- (BOOL) write:(id)obj;
- (void) reset;
@end

@interface HproseWriter : NSObject {
    @protected
    NSOutputStream *stream;
    @private
    NSMutableArray *classref;
    id<HproseWriterRefer> refer;
    uint8_t buf[20];
}

@property NSOutputStream *stream;

+ (id) writerWithStream:(NSOutputStream *)dataStream simple:(BOOL)b;
+ (id) writerWithStream:(NSOutputStream *)dataStream;

- (id) initWithStream:(NSOutputStream *)dataStream simple:(BOOL)b;
- (id) initWithStream:(NSOutputStream *)dataStream;

- (void) serialize:(id)obj;
- (void) writeInt8:(int8_t)i;
- (void) writeInt16:(int16_t)i;
- (void) writeInt32:(int32_t)i;
- (void) writeInt64:(int64_t)i;
- (void) writeUInt8:(uint8_t)i;
- (void) writeUInt16:(uint16_t)i;
- (void) writeUInt32:(uint32_t)i;
- (void) writeUInt64:(uint64_t)i;
- (void) writeBigInteger:(NSString *)bi;
- (void) writeFloat:(float)f;
- (void) writeDouble:(double)d;
- (void) writeNumber:(NSNumber *)n;
- (void) writeNull;
- (void) writeNaN;
- (void) writeInf;
- (void) writeNInf;
- (void) writeEmpty;
- (void) writeBoolean:(BOOL)b;
- (void) writeDate:(NSDate *)date;
- (void) writeDateWithRef:(NSDate *)date;
- (void) writeUTCDate:(NSDate *)date;
- (void) writeUTCDateWithRef:(NSDate *)date;
- (void) writeBytes:(const uint8_t *)bytes length:(int)l;
- (void) writeBytesWithRef:(const uint8_t *)bytes length:(int)l;;
- (void) writeData:(NSData *)data;
- (void) writeDataWithRef:(NSData *)data;
- (void) writeUTF8Char:(unichar)c;
- (void) writeString:(NSString *)str;
- (void) writeStringWithRef:(NSString *)str;
- (void) writeUUID:(NSUUID *)uuid;
- (void) writeUUIDWithRef:(NSUUID *)uuid;
- (void) writeArray:(NSArray *)array;
- (void) writeArrayWithRef:(NSArray *)array;
- (void) writeSet:(NSSet *)set;
- (void) writeSetWithRef:(NSSet *)set;
- (void) writeHashTable:(NSHashTable *)hashtable;
- (void) writeHashTableWithRef:(NSHashTable *)hashtable;
- (void) writeDict:(NSDictionary *)dict;
- (void) writeDictWithRef:(NSDictionary *)dict;
- (void) writeMapTable:(NSMapTable *)map;
- (void) writeMapTableWithRef:(NSMapTable *)map;
- (void) writeObject:(id)obj;
- (void) writeObjectWithRef:(id)obj;
- (void) reset;
@end