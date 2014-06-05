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
 * HproseReader.h                                         *
 *                                                        *
 * hprose reader class header for Objective-C.            *
 *                                                        *
 * LastModified: Apr 12, 2014                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>

@interface HproseRawReader : NSObject {
    @protected
    NSInputStream *stream;
}

@property NSInputStream *stream;

- (id) initWithStream:(NSInputStream *)dataStream;

- (NSData *) readRaw;
- (void) readRaw:(NSOutputStream *)ostream;

@end

@protocol HproseReaderRefer <NSObject>

- (void) set:(id)obj;
- (id) read:(NSUInteger)index;
- (void) reset;

@end

@interface HproseReader : HproseRawReader {
    @private
    NSMutableArray *classref;
    NSMutableDictionary *fieldsref;
    id<HproseReaderRefer> refer;
}

+ (id) readerWithStream:(NSInputStream *)dataStream;
+ (id) readerWithStream:(NSInputStream *)dataStream simple:(BOOL)b;

- (id) initWithStream:(NSInputStream *)dataStream;
- (id) initWithStream:(NSInputStream *)dataStream simple:(BOOL)b;

- (id) unserialize;
- (id) unserialize:(Class)cls;
- (id) unserialize:(Class)cls withType:(char)type;

- (void) checkTag:(int)expectTag;
- (int) checkTags:(char[])expectTags;
- (int8_t) readInt8;
- (int16_t) readInt16;
- (int32_t) readInt32;
- (int64_t) readInt64;
- (uint8_t) readUInt8;
- (uint16_t) readUInt16;
- (uint32_t) readUInt32;
- (uint64_t) readUInt64;
- (float) readFloat;
- (double) readDouble;
- (unichar) readUTF8Char;
- (BOOL) readBoolean;
- (NSNumber *) readNumber;
- (NSNumber *) readNumber:(char)type;
- (NSDate *) readDate;
- (NSData *) readData;
- (NSMutableData *) readMutableData;
- (NSString *) readString;
- (NSMutableString *) readMutableString;
- (NSUUID *) readUUID;
- (NSArray *) readArray;
- (NSSet *) readSet;
- (NSHashTable *) readHashTable;
- (NSDictionary *) readDict;
- (NSMapTable *) readMapTable;
- (id) readObject:(Class)cls;
- (void) reset;
@end