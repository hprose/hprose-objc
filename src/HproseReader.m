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
 * HproseReader.m                                         *
 *                                                        *
 * hprose reader class for Objective-C.                   *
 *                                                        *
 * LastModified: Aug 22, 2014                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import <objc/runtime.h>
#import "HproseProperty.h"
#import "HproseException.h"
#import "HproseTags.h"
#import "HproseHelper.h"
#import "HproseReader.h"

HproseException* unexpectedTag(int tag, char expectTags[]) {
    if (tag == -1) {
        return [HproseException exceptionWithReason:@"No byte found in stream"];
    }
    if (expectTags) {
        return [HproseException exceptionWithReason:[NSString stringWithFormat:
                                                     @"Tag '%s' expected, but '%c' found in stream", expectTags, tag]];
    }
    return [HproseException exceptionWithReason:[NSString stringWithFormat:
                                                 @"Unexpected serialize tag '%c' in stream", tag]];

}

@interface HproseRawReader (PrivateMethods)

- (void) readRaw:(NSOutputStream *)ostream withTag:(int)tag;
- (void) readNumberRaw:(NSOutputStream *)ostream;
- (void) readDateTimeRaw:(NSOutputStream *)ostream;
- (void) readUTF8CharRaw:(NSOutputStream *)ostream;
- (void) readBytesRaw:(NSOutputStream *)ostream;
- (void) readStringRaw:(NSOutputStream *)ostream;
- (void) readGuidRaw:(NSOutputStream *)ostream;
- (void) readComplexRaw:(NSOutputStream *)ostream;

@end

@implementation HproseRawReader(PrivateMethods)

- (void) readRaw:(NSOutputStream *)ostream withTag:(int)tag {
    [ostream writeByte:tag];
    switch (tag) {
        case '0':
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9':
        case HproseTagNull:
        case HproseTagEmpty:
        case HproseTagTrue:
        case HproseTagFalse:
        case HproseTagNaN:
            break;
        case HproseTagInfinity:
            [ostream writeByte:[stream readByte]];
            break;
        case HproseTagInteger:
        case HproseTagLong:
        case HproseTagDouble:
        case HproseTagRef:
            [self readNumberRaw:ostream];
            break;
        case HproseTagDate:
        case HproseTagTime:
            [self readDateTimeRaw:ostream];
            break;
        case HproseTagUTF8Char:
            [self readUTF8CharRaw:ostream];
            break;
        case HproseTagBytes:
            [self readBytesRaw:ostream];
            break;
        case HproseTagString:
            [self readStringRaw:ostream];
            break;
        case HproseTagGuid:
            [self readGuidRaw:ostream];
            break;
        case HproseTagList:
        case HproseTagMap:
        case HproseTagObject:
            [self readComplexRaw:ostream];
            break;
        case HproseTagClass:
            [self readComplexRaw:ostream];
            [self readRaw:ostream];
            break;
        case HproseTagError:
            [self readRaw:ostream];
            break;
    }
    @throw unexpectedTag(tag, NULL);
}
- (void) readNumberRaw:(NSOutputStream *)ostream {
    int tag;
    do {
        tag = [stream readByte];
        [ostream writeByte:tag];
    } while (tag != HproseTagSemicolon);
}
- (void) readDateTimeRaw:(NSOutputStream *)ostream {
    int tag;
    do {
        tag = [stream readByte];
        [ostream writeByte:tag];
    } while (tag != HproseTagSemicolon &&
             tag != HproseTagUTC);
}
- (void) readUTF8CharRaw:(NSOutputStream *)ostream {
    int tag = [stream readByte];
    switch (tag >> 4) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7: {
            // 0xxx xxxx
            [ostream writeByte:tag];
            break;
        }
        case 12:
        case 13: {
            // 110x xxxx   10xx xxxx
            [ostream writeByte:tag];
            [ostream writeByte:[stream readByte]];
            break;
        }
        case 14: {
            // 1110 xxxx  10xx xxxx  10xx xxxx
            [ostream writeByte:tag];
            [ostream writeByte:[stream readByte]];
            [ostream writeByte:[stream readByte]];
            break;
        }
        default:
            @throw [HproseException exceptionWithReason:@"Bad utf-8 encoding"];
    }
}
- (void) readBytesRaw:(NSOutputStream *)ostream {
    NSUInteger len = 0;
    int tag = '0';
    do {
        len *= 10;
        len += tag - '0';
        tag = [stream readByte];
        [ostream writeByte:tag];
    } while (tag != HproseTagQuote);
    [ostream copyFrom:stream maxLength:len + 1];
}
- (void) readStringRaw:(NSOutputStream *)ostream {
    NSUInteger count = 0;
    int tag = '0';
    do {
        count *= 10;
        count += tag - '0';
        [ostream writeByte:tag];
    } while (tag != HproseTagQuote);
    for (int i = 0; i < count; ++i) {
        tag = [stream readByte];
        switch (tag >> 4) {
            case 0:
            case 1:
            case 2:
            case 3:
            case 4:
            case 5:
            case 6:
            case 7: {
                // 0xxx xxxx
                [ostream writeByte:tag];
                break;
            }
            case 12:
            case 13: {
                // 110x xxxx   10xx xxxx
                [ostream writeByte:tag];
                [ostream writeByte:[stream readByte]];
                break;
            }
            case 14: {
                // 1110 xxxx  10xx xxxx  10xx xxxx
                [ostream writeByte:tag];
                [ostream writeByte:[stream readByte]];
                [ostream writeByte:[stream readByte]];
                break;
            }
            case 15: {
                // 1111 0xxx  10xx xxxx  10xx xxxx  10xx xxxx
                if ((tag & 0xf) <= 4) {
                    [ostream writeByte:tag];
                    [ostream writeByte:[stream readByte]];
                    [ostream writeByte:[stream readByte]];
                    [ostream writeByte:[stream readByte]];
                    ++i;
                    break;
                }
                // no break here!! here need throw exception.
            }
            default:
                @throw [HproseException exceptionWithReason:
                        [NSString stringWithString:
                         ((tag < 0) ? @"end of stream" : @"bad utf-8 encoding")]];
                break;
        }
    }
    [ostream writeByte:[stream readByte]];
}
- (void) readGuidRaw:(NSOutputStream *)ostream {
    [ostream copyFrom:stream maxLength:38];
}
- (void) readComplexRaw:(NSOutputStream *)ostream {
    int tag;
    do {
        tag = [stream readByte];
        [ostream writeByte:tag];
    } while (tag != HproseTagOpenbrace);
    while ((tag = [stream readByte]) != HproseTagClosebrace) {
        [self readRaw:ostream withTag:tag];
    }
    [ostream writeByte:tag];
}

@end

@implementation HproseRawReader

@synthesize stream;

- (id) initWithStream:(NSInputStream *)dataStream {
    if ((self = [super init])) {
        [self setStream:dataStream];
    }
    return self;
}

- (NSData *) readRaw {
    NSOutputStream *ostream = [NSOutputStream outputStreamToMemory];
    [ostream open];
    NSData *data = nil;
    @try {
        [self readRaw:ostream];
        data = [ostream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    }
    @finally {
        [ostream close];
    }
    return data;
}

- (void) readRaw:(NSOutputStream *)ostream {
    [self readRaw:ostream withTag:[stream readByte]];
}


@end

@interface HproseFakeReaderRefer : NSObject<HproseReaderRefer>;

@end

@implementation HproseFakeReaderRefer

- (void) set:(id)obj {

}

- (id) read:(NSUInteger)index {
    @throw unexpectedTag(HproseTagRef, NULL);
}

- (void) reset {

}

@end

@interface HproseRealReaderRefer : NSObject<HproseReaderRefer> {
    NSMutableArray *ref;
}

@end

@implementation HproseRealReaderRefer

- (id) init {
    if(self = [super init]) {
        ref = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) set:(id)obj {
    [ref addObject:obj];
}

- (id) read:(NSUInteger)index {
    return ref[index];
}

- (void) reset {
    [ref removeAllObjects];
}

@end


@interface HproseReader(PrivateMethods)

- (NSString *) tagToString:(int) tag;
- (HproseException *) castExceptionFrom:(NSString *)from to:(NSString *)to;
- (HproseException *) castExceptionFromClass:(Class)cls to:(NSString *)to;
- (HproseException *) castExceptionFrom:(NSString *)from toClass:(Class)cls;
- (NSString *) readUntil:(int)tag;
- (int8_t) readI8:(int)tag;
- (int16_t) readI16:(int)tag;
- (int32_t) readI32:(int)tag;
- (int64_t) readI64:(int)tag;
- (uint8_t) readUI8:(int)tag;
- (uint16_t) readUI16:(int)tag;
- (uint32_t) readUI32:(int)tag;
- (uint64_t) readUI64:(int)tag;
- (NSNumber *) readIntegerWithoutTag;
- (NSNumber *) readDoubleWithoutTag;
- (NSNumber *) readInfinityWithoutTag;
- (int8_t) readInt8WithTag:(int)tag;
- (int16_t) readInt16WithTag:(int)tag;
- (int32_t) readInt32WithTag:(int)tag;
- (int64_t) readInt64WithTag:(int)tag;
- (uint8_t) readUInt8WithTag:(int)tag;
- (uint16_t) readUInt16WithTag:(int)tag;
- (uint32_t) readUInt32WithTag:(int)tag;
- (uint64_t) readUInt64WithTag:(int)tag;
- (float) readFloatWithTag:(int)tag;
- (double) readDoubleWithTag:(int)tag;
- (BOOL) readBooleanWithTag:(int)tag;
- (unichar) readUTF8CharWithoutTag;
- (unichar) readUTF8CharWithTag:(int)tag;
- (NSString *) readUTF8CharAsString;
- (int) readTime:(NSMutableString *)dateString formatString:(NSMutableString *)formatString;
- (NSDate *) readDateTime:(int)tag dateFormatter:(NSDateFormatter *)dateFormatter formatString:(NSMutableString *)formatString dateString:(NSMutableString *)dateString;
- (NSDate *) readDateWithoutTag;
- (NSDate *) readTimeWithoutTag;
- (NSData *) readStringAsNSData:(Class)cls;
- (NSString *) readStringAsNSString:(Class)cls;
- (NSData *) readDataWithoutTag;
- (NSMutableData *) readMutableDataWithoutTag;
- (NSData *) readStringAsNSData;
- (NSMutableData *) readStringAsNSMutableData;
- (NSString *) readStringWithoutTag;
- (NSMutableString *) readMutableStringWithoutTag;
- (NSString *) readGuidAsString;
- (NSString *) readGuidWithoutTag;
- (NSUUID *) readUUIDWithoutTag;
- (NSArray *) readArrayWithoutTag;
- (NSSet *) readSetWithoutTag;
- (NSHashTable *) readHashTableWithoutTag;
- (NSDictionary *) readArrayAsDict;
- (NSDictionary *) readDictWithoutTag;
- (NSMapTable *) readArrayAsMapTable;
- (NSMapTable *) readMapTableWithoutTag;
- (NSDictionary *) readObjectAsDict;
- (NSMapTable *) readObjectAsMapTable;
- (id) readObjectWithoutTag:(Class)cls;
- (id) readMapAsObject:(Class)cls;
- (void) readProperty:(HproseProperty *)property forObject:(id)obj;
- (void) readClass;
- (id) readRef;

@end

@implementation HproseReader(PrivateMethods)

static double NaN, Infinity, NegInfinity;

+ (void) initialize {
    if (self == [HproseReader class]) {
        NaN = log((double)-1);
        Infinity = -log((double)0);
        NegInfinity = log((double)0);
    }
}

- (NSString *) tagToString:(int)tag {
    switch (tag) {
        case '0':
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9':
        case HproseTagInteger: return @"Integer";
        case HproseTagLong: return @"BigInteger";
        case HproseTagDouble: return @"Double";
        case HproseTagNull: return @"Null";
        case HproseTagEmpty: return @"Empty String";
        case HproseTagTrue: return @"Boolean True";
        case HproseTagFalse: return @"Boolean False";
        case HproseTagNaN: return @"NaN";
        case HproseTagInfinity: return @"Infinity";
        case HproseTagDate: return @"NSDate";
        case HproseTagTime: return @"NSDate";
        case HproseTagBytes: return @"NSData";
        case HproseTagUTF8Char: return @"unichar";
        case HproseTagString: return @"NSString";
        case HproseTagGuid: return @"Guid";
        case HproseTagList: return @"NSArray";
        case HproseTagMap: return @"NSDictionary";
        case HproseTagClass: return @"Class";
        case HproseTagObject: return @"Object";
        case HproseTagRef: return @"Object Reference";
        case HproseTagError: @throw [HproseException exceptionWithReason:[self readString]];
    }
    @throw unexpectedTag(tag, NULL);
}

- (HproseException *) castExceptionFrom:(NSString *)from to:(NSString *)to {
    return [HproseException exceptionWithReason:[NSString stringWithFormat: @"Can't change %@ to %@", from, to]];
}

- (HproseException *) castExceptionFromClass:(Class)cls to:(NSString *)to {
    return [HproseException exceptionWithReason:[NSString stringWithFormat: @"Can't change %s to %@", class_getName(cls), to]];
}

- (HproseException *) castExceptionFrom:(NSString *)from toClass:(Class)cls {
    return [HproseException exceptionWithReason:[NSString stringWithFormat: @"Can't change %@ to %s", from, class_getName(cls)]];
}

- (HproseException *) castExceptionFromClass:(Class)fromClass toClass:(Class)toClass {
    return [HproseException exceptionWithReason:[NSString stringWithFormat: @"Can't change %s to %s", class_getName(fromClass), class_getName(toClass)]];
}

- (NSString *) readUntil:(int)tag {
    NSMutableString *s = [NSMutableString stringWithCapacity:256];
    char buf[256];
    int n = 0;
    int i = [stream readByte];
    while ((i != tag) && (i != -1)) {
        buf[n] = (char)i;
        if (n < 254) {
            ++n;
        }
        else {
            buf[255] = 0;
            [s appendString:@(buf)];
            n = 0;
        }
        i = [stream readByte];
    }
    if (n > 0) {
        buf[n] = 0;
        [s appendString:@(buf)];
    }
    return s;
}

- (int8_t) readI8:(int)tag {
    int8_t result = 0;
    int i = [stream readByte];
    if (i == tag) return result;
    int8_t sign = 1;
    if (i == '+') {
        i = [stream readByte];
    }
    else if (i == '-') {
        sign = -1;
        i = [stream readByte];
    }
    while ((i != tag) && (i != -1)) {
        result *= 10;
        result += (i - '0') * sign;
        i = [stream readByte];
    }
    return result;
}

- (int16_t) readI16:(int)tag {
    int16_t result = 0;
    int i = [stream readByte];
    if (i == tag) return result;
    int16_t sign = 1;
    if (i == '+') {
        i = [stream readByte];
    }
    else if (i == '-') {
        sign = -1;
        i = [stream readByte];
    }
    while ((i != tag) && (i != -1)) {
        result *= 10;
        result += (i - '0') * sign;
        i = [stream readByte];
    }
    return result;
}

- (int32_t) readI32:(int)tag {
    int32_t result = 0;
    int i = [stream readByte];
    if (i == tag) return result;
    int32_t sign = 1;
    if (i == '+') {
        i = [stream readByte];
    }
    else if (i == '-') {
        sign = -1;
        i = [stream readByte];
    }
    while ((i != tag) && (i != -1)) {
        result *= 10;
        result += (i - '0') * sign;
        i = [stream readByte];
    }
    return result;
}

- (int64_t) readI64:(int)tag {
    int64_t result = 0;
    int i = [stream readByte];
    if (i == tag) return result;
    int64_t sign = 1;
    if (i == '+') {
        i = [stream readByte];
    }
    else if (i == '-') {
        sign = -1;
        i = [stream readByte];
    }
    while ((i != tag) && (i != -1)) {
        result *= 10;
        result += (i - '0') * sign;
        i = [stream readByte];
    }
    return result;
}

- (uint8_t) readUI8:(int)tag {
    uint8_t result = 0;
    int i = [stream readByte];
    if (i == tag) return result;
    if (i == '+') {
        i = [stream readByte];
    }
    while ((i != tag) && (i != -1)) {
        result *= 10;
        result += (uint8_t)(i - '0');
        i = [stream readByte];
    }
    return result;
}

- (uint16_t) readUI16:(int)tag {
    uint16_t result = 0;
    int i = [stream readByte];
    if (i == tag) return result;
    if (i == '+') {
        i = [stream readByte];
    }
    while ((i != tag) && (i != -1)) {
        result *= 10;
        result += (uint16_t)(i - '0');
        i = [stream readByte];
    }
    return result;
}

- (uint32_t) readUI32:(int)tag {
    uint32_t result = 0;
    int i = [stream readByte];
    if (i == tag) return result;
    if (i == '+') {
        i = [stream readByte];
    }
    while ((i != tag) && (i != -1)) {
        result *= 10;
        result += (uint32_t)(i - '0');
        i = [stream readByte];
    }
    return result;
}

- (uint64_t) readUI64:(int)tag {
    uint64_t result = 0;
    int i = [stream readByte];
    if (i == tag) return result;
    if (i == '+') {
        i = [stream readByte];
    }
    while ((i != tag) && (i != -1)) {
        result *= 10;
        result += (uint64_t)(i - '0');
        i = [stream readByte];
    }
    return result;
}

- (NSNumber *) readIntegerWithoutTag {
    return @([self readI32:HproseTagSemicolon]);
}

- (NSNumber *) readDoubleWithoutTag {
    return @([[self readUntil:HproseTagSemicolon] doubleValue]);
}

- (NSNumber *) readInfinityWithoutTag {
    return @([stream readByte] == HproseTagPos ? Infinity : NegInfinity);
}

- (int8_t) readInt8WithTag:(int)tag {
    switch (tag) {
        case '0': return 0;
        case '1': return 1;
        case '2': return 2;
        case '3': return 3;
        case '4': return 4;
        case '5': return 5;
        case '6': return 6;
        case '7': return 7;
        case '8': return 8;
        case '9': return 9;
        case HproseTagInteger:
        case HproseTagLong:
            return [self readI8:HproseTagSemicolon];
        case HproseTagDouble:
            return [[self readDoubleWithoutTag] charValue];
        case HproseTagEmpty: return 0;
        case HproseTagTrue: return 1;
        case HproseTagFalse: return 0;
        case HproseTagUTF8Char: return (int8_t)[self readUTF8CharWithoutTag];
        case HproseTagString: return (int8_t)[[self readStringWithoutTag] intValue];
        case HproseTagRef: {
            id ref = [self readRef];
            if ([ref isKindOfClass:[NSString class]]) {
                return (int8_t)[ref intValue];
            }
            @throw [self castExceptionFromClass:[ref class] to:@"int8_t"];
        }
        default: @throw [self castExceptionFrom:[self tagToString:tag] to:@"int8_t"];
    }
}

- (int16_t) readInt16WithTag:(int)tag {
    switch (tag) {
        case '0': return 0;
        case '1': return 1;
        case '2': return 2;
        case '3': return 3;
        case '4': return 4;
        case '5': return 5;
        case '6': return 6;
        case '7': return 7;
        case '8': return 8;
        case '9': return 9;
        case HproseTagInteger:
        case HproseTagLong:
            return [self readI16:HproseTagSemicolon];
        case HproseTagDouble:
            return [[self readDoubleWithoutTag] shortValue];
        case HproseTagEmpty: return 0;
        case HproseTagTrue: return 1;
        case HproseTagFalse: return 0;
        case HproseTagUTF8Char: return (int16_t)[self readUTF8CharWithoutTag];
        case HproseTagString: return (int16_t)[[self readStringWithoutTag] intValue];
        case HproseTagRef: {
            id ref = [self readRef];
            if ([ref isKindOfClass:[NSString class]]) {
                return (int16_t)[ref intValue];
            }
            @throw [self castExceptionFromClass:[ref class] to:@"int16_t"];
        }
        default: @throw [self castExceptionFrom:[self tagToString:tag] to:@"int16_t"];
    }
}

- (int32_t) readInt32WithTag:(int)tag {
    switch (tag) {
        case '0': return 0;
        case '1': return 1;
        case '2': return 2;
        case '3': return 3;
        case '4': return 4;
        case '5': return 5;
        case '6': return 6;
        case '7': return 7;
        case '8': return 8;
        case '9': return 9;
        case HproseTagInteger:
        case HproseTagLong:
            return [self readI32:HproseTagSemicolon];
        case HproseTagDouble:
            return [[self readDoubleWithoutTag] intValue];
        case HproseTagEmpty: return 0;
        case HproseTagTrue: return 1;
        case HproseTagFalse: return 0;
        case HproseTagUTF8Char: return (int32_t)[self readUTF8CharWithoutTag];
        case HproseTagString: return [[self readStringWithoutTag] intValue];
        case HproseTagRef: {
            id ref = [self readRef];
            if ([ref isKindOfClass:[NSString class]]) {
                return [ref intValue];
            }
            @throw [self castExceptionFromClass:[ref class] to:@"int32_t"];
        }
        default: @throw [self castExceptionFrom:[self tagToString:tag] to:@"int32_t"];
    }
}

- (int64_t) readInt64WithTag:(int)tag {
    switch (tag) {
        case '0': return 0LL;
        case '1': return 1LL;
        case '2': return 2LL;
        case '3': return 3LL;
        case '4': return 4LL;
        case '5': return 5LL;
        case '6': return 6LL;
        case '7': return 7LL;
        case '8': return 8LL;
        case '9': return 9LL;
        case HproseTagInteger:
        case HproseTagLong:
            return [self readI64:HproseTagSemicolon];
        case HproseTagDouble:
            return [[self readDoubleWithoutTag] longLongValue];
        case HproseTagEmpty: return 0LL;
        case HproseTagTrue: return 1LL;
        case HproseTagFalse: return 0LL;
        case HproseTagUTF8Char: return (int64_t)[self readUTF8CharWithoutTag];
        case HproseTagString: return [[self readStringWithoutTag] longLongValue];
        case HproseTagRef: {
            id ref = [self readRef];
            if ([ref isKindOfClass:[NSString class]]) {
                return [ref longLongValue];
            }
            @throw [self castExceptionFromClass:[ref class] to:@"int64_t"];
        }
        default: @throw [self castExceptionFrom:[self tagToString:tag] to:@"int64_t"];
    }
}

- (uint8_t) readUInt8WithTag:(int)tag {
    switch (tag) {
        case '0': return 0;
        case '1': return 1;
        case '2': return 2;
        case '3': return 3;
        case '4': return 4;
        case '5': return 5;
        case '6': return 6;
        case '7': return 7;
        case '8': return 8;
        case '9': return 9;
        case HproseTagInteger:
        case HproseTagLong:
            return [self readUI8:HproseTagSemicolon];
        case HproseTagDouble:
            return [[self readDoubleWithoutTag] unsignedCharValue];
        case HproseTagEmpty: return 0;
        case HproseTagTrue: return 1;
        case HproseTagFalse: return 0;
        case HproseTagUTF8Char: return (uint8_t)[self readUTF8CharWithoutTag];
        case HproseTagString: return (uint8_t)[[self readStringWithoutTag] intValue];
        case HproseTagRef: {
            id ref = [self readRef];
            if ([ref isKindOfClass:[NSString class]]) {
                return (uint8_t)[ref intValue];
            }
            @throw [self castExceptionFromClass:[ref class] to:@"uint8_t"];
        }
        default: @throw [self castExceptionFrom:[self tagToString:tag] to:@"uint8_t"];
    }
}

- (uint16_t) readUInt16WithTag:(int)tag {
    switch (tag) {
        case '0': return 0;
        case '1': return 1;
        case '2': return 2;
        case '3': return 3;
        case '4': return 4;
        case '5': return 5;
        case '6': return 6;
        case '7': return 7;
        case '8': return 8;
        case '9': return 9;
        case HproseTagInteger:
        case HproseTagLong:
            return [self readUI16:HproseTagSemicolon];
        case HproseTagDouble:
            return [[self readDoubleWithoutTag] unsignedShortValue];
        case HproseTagEmpty: return 0;
        case HproseTagTrue: return 1;
        case HproseTagFalse: return 0;
        case HproseTagUTF8Char: return (uint16_t)[self readUTF8CharWithoutTag];
        case HproseTagString: return (uint16_t)[[self readStringWithoutTag] intValue];
        case HproseTagRef: {
            id ref = [self readRef];
            if ([ref isKindOfClass:[NSString class]]) {
                return (uint16_t)[ref intValue];
            }
            @throw [self castExceptionFromClass:[ref class] to:@"uint16_t"];
        }
        default: @throw [self castExceptionFrom:[self tagToString:tag] to:@"uint16_t"];
    }
}

- (uint32_t) readUInt32WithTag:(int)tag {
    switch (tag) {
        case '0': return 0;
        case '1': return 1;
        case '2': return 2;
        case '3': return 3;
        case '4': return 4;
        case '5': return 5;
        case '6': return 6;
        case '7': return 7;
        case '8': return 8;
        case '9': return 9;
        case HproseTagInteger:
        case HproseTagLong:
            return [self readUI32:HproseTagSemicolon];
        case HproseTagDouble:
            return [[self readDoubleWithoutTag] unsignedIntValue];
        case HproseTagEmpty: return 0;
        case HproseTagTrue: return 1;
        case HproseTagFalse: return 0;
        case HproseTagUTF8Char: return (uint32_t)[self readUTF8CharWithoutTag];
        case HproseTagString: return (uint32_t)[[self readStringWithoutTag] longLongValue];
        case HproseTagRef: {
            id ref = [self readRef];
            if ([ref isKindOfClass:[NSString class]]) {
                return (uint32_t)[ref longLongValue];
            }
            @throw [self castExceptionFromClass:[ref class] to:@"uint32_t"];
        }
        default: @throw [self castExceptionFrom:[self tagToString:tag] to:@"uint32_t"];
    }
}

- (uint64_t) readUInt64WithTag:(int)tag {
    switch (tag) {
        case '0': return 0ULL;
        case '1': return 1ULL;
        case '2': return 2ULL;
        case '3': return 3ULL;
        case '4': return 4ULL;
        case '5': return 5ULL;
        case '6': return 6ULL;
        case '7': return 7ULL;
        case '8': return 8ULL;
        case '9': return 9ULL;
        case HproseTagInteger:
        case HproseTagLong:
            return [self readI64:HproseTagSemicolon];
        case HproseTagDouble:
            return [[self readDoubleWithoutTag] unsignedLongLongValue];
        case HproseTagEmpty: return 0ULL;
        case HproseTagTrue: return 1ULL;
        case HproseTagFalse: return 0ULL;
        case HproseTagUTF8Char: return (int64_t)[self readUTF8CharWithoutTag];
        case HproseTagString: return [[[NSNumberFormatter new] numberFromString:[self readStringWithoutTag]] unsignedLongLongValue];
        case HproseTagRef: {
            id ref = [self readRef];
            if ([ref isKindOfClass:[NSString class]]) {
                return [[[NSNumberFormatter new] numberFromString:ref] unsignedLongLongValue];
            }
            @throw [self castExceptionFromClass:[ref class] to:@"uint64_t"];
        }
        default: @throw [self castExceptionFrom:[self tagToString:tag] to:@"uint64_t"];
    }
}

- (float) readFloatWithTag:(int)tag {
    switch (tag) {
        case '0': return 0;
        case '1': return 1;
        case '2': return 2;
        case '3': return 3;
        case '4': return 4;
        case '5': return 5;
        case '6': return 6;
        case '7': return 7;
        case '8': return 8;
        case '9': return 9;
        case HproseTagInteger:
        case HproseTagLong:
        case HproseTagDouble:
            return [[self readUntil:HproseTagSemicolon] floatValue];
        case HproseTagNaN: return NaN;
        case HproseTagInfinity: return [[self readInfinityWithoutTag] floatValue];
        case HproseTagEmpty: return 0;
        case HproseTagTrue: return 1;
        case HproseTagFalse: return 0;
        case HproseTagUTF8Char: return (float)[self readUTF8CharWithoutTag];
        case HproseTagString: return [[self readStringWithoutTag] floatValue];
        case HproseTagRef: {
            id ref = [self readRef];
            if ([ref isKindOfClass:[NSString class]]) {
                return [ref floatValue];
            }
            @throw [self castExceptionFromClass:[ref class] to:@"float"];
        }
        default: @throw [self castExceptionFrom:[self tagToString:tag] to:@"float"];
    }
}

- (double) readDoubleWithTag:(int)tag {
    switch (tag) {
        case '0': return 0;
        case '1': return 1;
        case '2': return 2;
        case '3': return 3;
        case '4': return 4;
        case '5': return 5;
        case '6': return 6;
        case '7': return 7;
        case '8': return 8;
        case '9': return 9;
        case HproseTagInteger:
        case HproseTagLong:
        case HproseTagDouble:
            return [[self readUntil:HproseTagSemicolon] doubleValue];
        case HproseTagNaN: return NaN;
        case HproseTagInfinity: return [[self readInfinityWithoutTag] doubleValue];
        case HproseTagEmpty: return 0;
        case HproseTagTrue: return 1;
        case HproseTagFalse: return 0;
        case HproseTagUTF8Char: return (double)[self readUTF8CharWithoutTag];
        case HproseTagString: return [[self readStringWithoutTag] doubleValue];
        case HproseTagDate: return [[self readDateWithoutTag] timeIntervalSince1970];
        case HproseTagTime: return [[self readTimeWithoutTag] timeIntervalSince1970];
        case HproseTagRef: {
            id ref = [self readRef];
            if ([ref isKindOfClass:[NSString class]]) {
                return [ref doubleValue];
            }
            if ([ref isKindOfClass:[NSDate class]]) {
                return [ref timeIntervalSince1970];
            }
            @throw [self castExceptionFromClass:[ref class] to:@"double"];
        }
        default: @throw [self castExceptionFrom:[self tagToString:tag] to:@"double"];
    }
}

- (BOOL) readBooleanWithTag:(int)tag {
    switch (tag) {
        case '0': return NO;
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9': return YES;
        case HproseTagInteger:
            return [self readI32:HproseTagSemicolon] != 0;
        case HproseTagLong:
            return ![[self readUntil:HproseTagSemicolon] isEqual: @"0"];
        case HproseTagDouble:
            return [[self readUntil:HproseTagSemicolon] doubleValue] != 0;
        case HproseTagNaN: return NO;
        case HproseTagInfinity: [stream readByte]; return YES;
        case HproseTagEmpty: return NO;
        case HproseTagTrue: return YES;
        case HproseTagFalse: return NO;
        case HproseTagUTF8Char: {
            unichar u = [self readUTF8CharWithoutTag];
            return (u != 0 && u != '0');
        }
        case HproseTagString: return [[self readStringWithoutTag] boolValue];
        case HproseTagRef: {
            id ref = [self readRef];
            if ([ref isKindOfClass:[NSString class]]) {
                return [ref boolValue];
            }
            @throw [self castExceptionFromClass:[ref class] to:@"BOOL"];
        }
        default: @throw [self castExceptionFrom:[self tagToString:tag] to:@"BOOL"];
    }
}

- (unichar) readUTF8CharWithoutTag {
    unichar u;
    int c = [stream readByte];
    switch (c >> 4) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7: {
            // 0xxx xxxx
            u = (unichar) c;
            break;
        }
        case 12:
        case 13: {
            // 110x xxxx   10xx xxxx
            int c2 = [stream readByte];
            u = (unichar) (((c & 0x1f) << 6) |
                           (c2 & 0x3f));
            break;
        }
        case 14: {
            // 1110 xxxx  10xx xxxx  10xx xxxx
            int c2 = [stream readByte];
            int c3 = [stream readByte];
            u = (unichar) (((c & 0x0f) << 12) |
                           ((c2 & 0x3f) << 6) |
                           (c3 & 0x3f));
            break;
        }
        default:
            @throw [HproseException exceptionWithReason:@"Bad utf-8 encoding"];
    }
    return u;
}

- (unichar) readUTF8CharWithTag:(int)tag {
    switch (tag) {
        case '0': return 0;
        case '1': return 1;
        case '2': return 2;
        case '3': return 3;
        case '4': return 4;
        case '5': return 5;
        case '6': return 6;
        case '7': return 7;
        case '8': return 8;
        case '9': return 9;
        case HproseTagInteger:
        case HproseTagLong:
            return (unichar)[self readUI16:HproseTagSemicolon];
        case HproseTagDouble:
            return (unichar)[[self readDoubleWithoutTag] unsignedShortValue];
        case HproseTagEmpty: return 0;
        case HproseTagFalse: return 0;
        case HproseTagTrue: return 1;
        case HproseTagUTF8Char: return [self readUTF8CharWithoutTag];
        case HproseTagString: return [[self readStringWithoutTag] characterAtIndex:0];
        case HproseTagRef: {
            id ref = [self readRef];
            if ([ref isKindOfClass:[NSString class]]) {
                return [ref characterAtIndex:0];
            }
            @throw [self castExceptionFromClass:[ref class] to:@"unichar"];
        }
        default: @throw [self castExceptionFrom:[self tagToString:tag] to:@"unichar"];
    }
}

- (NSString *) readUTF8CharAsString {
    unichar u = [self readUTF8CharWithoutTag];
    return [NSString stringWithCharacters:&u length:1];
}

- (NSMutableString *) readUTF8CharAsMutableString {
    unichar u = [self readUTF8CharWithoutTag];
    return [NSMutableString stringWithCharacters:&u length:1];
}

- (int)readTime:(NSMutableString *)dateString formatString:(NSMutableString *)formatString {
    uint8_t buffer[7];
    [stream readBuffer:buffer maxLength:6];
    buffer[6] = 0;
    [dateString appendFormat:@"%s", buffer];
    [formatString appendString:@"HHmmss"];
    int tag = [stream readByte];
    if (tag == HproseTagPoint) {
        [stream readBuffer:buffer maxLength:3];
        buffer[3] = 0;
        [dateString appendFormat:@"%s", buffer];
        [formatString appendString:@"SSS"];
        tag = [stream readByte];
        if (tag >= '0' && tag <= '9') {
            [stream readBuffer:buffer maxLength:2];
            tag = [stream readByte];
            if (tag >= '0' && tag <= '9') {
                [stream readBuffer:buffer maxLength:2];
                tag = [stream readByte];
            }
        }
    }
    return tag;
}

- (NSDate *) readDateTime:(int)tag dateFormatter:(NSDateFormatter *)dateFormatter formatString:(NSMutableString *)formatString dateString:(NSMutableString *)dateString {
    if (tag == HproseTagUTC) {
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    else {
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    }
    [dateFormatter setDateFormat:formatString];
    NSDate *date = [dateFormatter dateFromString:dateString];
    [refer set:date];
    return date;
}

- (NSDate *) readDateWithoutTag {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSMutableString *dateString = [[NSMutableString alloc] initWithCapacity:18];
    NSMutableString *formatString = [[NSMutableString alloc] initWithCapacity:18];
    uint8_t buffer[9];
    [stream readBuffer:buffer maxLength:8];
    buffer[8] = 0;
    [dateString appendFormat:@"%s", buffer];
    [formatString appendString:@"yyyyMMdd"];
    int tag = [stream readByte];
    if (tag == HproseTagTime) {
        tag = [self readTime:dateString formatString:formatString];
    }
    return [self readDateTime:tag dateFormatter:dateFormatter formatString:formatString dateString:dateString];
}

- (NSDate *) readTimeWithoutTag {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSMutableString *dateString = [[NSMutableString alloc] initWithCapacity:18];
    NSMutableString *formatString = [[NSMutableString alloc] initWithCapacity:18];
    int tag = [self readTime:dateString formatString:formatString];
    return [self readDateTime:tag dateFormatter:dateFormatter formatString:formatString dateString:dateString];
}

- (NSData *) readStringAsNSData:(Class)cls {
    NSUInteger len = (NSUInteger)[self readUI32:HproseTagQuote];
    uint8_t *bytes = (uint8_t *)malloc(len * 3);
    int n = 0;
    for (int i = 0; i < len; ++i) {
        int c = [stream readByte];
        switch (c >> 4) {
            case 0:
            case 1:
            case 2:
            case 3:
            case 4:
            case 5:
            case 6:
            case 7:
                bytes[n] = (uint8_t)c;
                ++n;
                break;
            case 12:
            case 13:
                bytes[n] = (uint8_t)c;
                [stream readBuffer:&bytes[++n] maxLength:1];
                ++n;
                break;
            case 14:
                bytes[n] = (uint8_t)c;
                [stream readBuffer:&bytes[++n] maxLength:2];
                n += 2;
                break;
            case 15:
                if ((c & 0xf) <= 4) {
                    bytes[n] = (uint8_t)c;
                    [stream readBuffer:&bytes[++n] maxLength:3];
                    n += 3;
                    ++i;
                    break;
                }
                // no break here!! here need throw exception.
            default:
                free(bytes);
                @throw [HproseException exceptionWithReason:
                        [NSString stringWithString:
                         (c < 0 ? @"end of stream" : @"bad utf-8 encoding")]];
                break;
        }
    }
    [self checkTag:HproseTagQuote];
    return [[cls alloc] initWithBytesNoCopy:bytes length:n freeWhenDone:YES];
}

- (NSString *) readStringAsNSString:(Class)cls {
    NSUInteger len = (NSUInteger)[self readUI32:HproseTagQuote];
    unichar *buffer = (unichar *)malloc(len * sizeof(unichar));
    int c, c2, c3, c4;
    for (int i = 0; i < len; ++i) {
        c = [stream readByte];
        switch (c >> 4) {
            case 0:
            case 1:
            case 2:
            case 3:
            case 4:
            case 5:
            case 6:
            case 7:
                buffer[i] = (unichar)c;
                break;
            case 12:
            case 13:
                c2 = [stream readByte];
                buffer[i] = (unichar)(((c & 0x1f) << 6) |
                                      (c2 & 0x3f));
                break;
            case 14:
                c2 = [stream readByte];
                c3 = [stream readByte];
                buffer[i] = (unichar)(((c & 0x0f) << 12) |
                                      ((c2 & 0x3f) << 6) |
                                      (c3 & 0x3f));
                break;
            case 15:
                if ((c & 0xf) <= 4) {
                    c2 = [stream readByte];
                    c3 = [stream readByte];
                    c4 = [stream readByte];
                    int s = (((c & 0x07) << 18) |
                             ((c2 & 0x3f) << 12) |
                             ((c3 & 0x3f) << 6)  |
                             (c4 & 0x3f)) - 0x10000;
                    if (0 <= s && s <= 0xfffff) {
                        buffer[i] = (unichar)(((s >> 10) & 0x03ff) | 0xd800);
                        buffer[++i] = (unichar)((s & 0x03ff) | 0xdc00);
                        break;
                    }
                }
                // no break here!! here need throw exception.
            default:
                free(buffer);
                @throw [HproseException exceptionWithReason:
                        [NSString stringWithString:
                         ((c < 0) ? @"end of stream" : @"bad utf-8 encoding")]];
                break;
        }
    }
    [self checkTag:HproseTagQuote];
    if (cls != [NSMutableString class]) {
        cls = [NSString class];
    }
    return [[cls alloc] initWithCharactersNoCopy:buffer length:len freeWhenDone:YES];
}

- (NSData *) readDataWithoutTag {
    NSUInteger len = [self readUI32:HproseTagQuote];
    uint8_t *buffer = (uint8_t *)malloc(len);
    [stream readBuffer:buffer maxLength:len];
    [self checkTag:HproseTagQuote];
    NSData *data = [NSData dataWithBytesNoCopy:buffer
                                        length:len
                                  freeWhenDone:YES];
    [refer set:data];
    return data;
}

- (NSMutableData *) readMutableDataWithoutTag {
    NSUInteger len = [self readUI32:HproseTagQuote];
    uint8_t *buffer = (uint8_t *)malloc(len);
    [stream readBuffer:buffer maxLength:len];
    [self checkTag:HproseTagQuote];
    NSMutableData *data = [NSMutableData dataWithBytesNoCopy:buffer
                                                      length:len
                                                freeWhenDone:YES];
    [refer set:data];
    return data;
}

- (NSData *) readStringAsNSData {
    NSData *data = [self readStringAsNSData:[NSData class]];
    [refer set:data];
    return data;
}

- (NSMutableData *) readStringAsNSMutableData {
    NSMutableData *data = (NSMutableData *)[self readStringAsNSData:[NSMutableData class]];
    [refer set:data];
    return data;
}

- (NSString *) readStringWithoutTag {
    NSString *str = [self readStringAsNSString:Nil];
    [refer set:str];
    return str;
}

- (NSMutableString *) readMutableStringWithoutTag {
    NSMutableString *str = (NSMutableString *)[self readStringAsNSString:[NSMutableString class]];
    [refer set:str];
    return str;
}

- (NSString *) readGuidAsString {
    [self checkTag:HproseTagOpenbrace];
    uint8_t *buffer = (uint8_t *)malloc(36);
    [stream readBuffer:buffer maxLength:36];
    NSString *guid = [[NSString alloc]
                      initWithBytesNoCopy:buffer
                      length:36
                      encoding:NSISOLatin1StringEncoding
                      freeWhenDone:YES];
    [self checkTag:HproseTagClosebrace];
    return guid;
}

- (NSString *) readGuidWithoutTag {
    NSString *guid = [self readGuidAsString];
    [refer set:guid];
    return guid;
}

- (NSUUID *) readUUIDWithoutTag {
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:[self readGuidAsString]];
    [refer set:uuid];
    return uuid;
}

- (NSArray *) readArrayWithoutTag {
    NSUInteger count = [self readUI32:HproseTagOpenbrace];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
    [refer set:array];
    for (NSUInteger i = 0; i < count; ++i) {
        [array addObject:[self unserialize]];
    }
    [self checkTag:HproseTagClosebrace];
    return array;
}

- (NSSet *) readSetWithoutTag {
    NSUInteger count = [self readUI32:HproseTagOpenbrace];
    NSCountedSet *set = [NSCountedSet setWithCapacity:count];
    [refer set:set];
    for (NSUInteger i = 0; i < count; ++i) {
        [set addObject:[self unserialize]];
    }
    [self checkTag:HproseTagClosebrace];
    return set;
}

- (NSHashTable *) readHashTableWithoutTag {
    NSUInteger count = [self readUI32:HproseTagOpenbrace];
    NSHashTable *hashtable = [NSHashTable new];
    [refer set:hashtable];
    for (NSUInteger i = 0; i < count; ++i) {
        [hashtable addObject:[self unserialize]];
    }
    [self checkTag:HproseTagClosebrace];
    return hashtable;
}

- (NSDictionary *) readArrayAsDict {
    NSUInteger count = [self readUI32:HproseTagOpenbrace];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:count];
    [refer set:dict];
    for (NSUInteger i = 0; i < count; ++i) {
        id key = @(i);
        id value = [self unserialize];
        dict[key] = value;
    }
    [self checkTag:HproseTagClosebrace];
    return dict;
}

- (NSDictionary *) readDictWithoutTag {
    NSUInteger count = [self readUI32:HproseTagOpenbrace];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:count];
    [refer set:dict];
    for (NSUInteger i = 0; i < count; ++i) {
        id key = [self unserialize];
        id value = [self unserialize];
        dict[key] = value;
    }
    [self checkTag:HproseTagClosebrace];
    return dict;
}

- (NSMapTable *) readArrayAsMapTable {
    NSUInteger count = [self readUI32:HproseTagOpenbrace];
    NSMapTable *map = [NSMapTable new];
    [refer set:map];
    for (NSUInteger i = 0; i < count; ++i) {
        id key = @(i);
        id value = [self unserialize];
        [map setObject:value forKey:key];
    }
    [self checkTag:HproseTagClosebrace];
    return map;
}

- (NSMapTable *) readMapTableWithoutTag {
    NSUInteger count = [self readUI32:HproseTagOpenbrace];
    NSMapTable *map = [NSMapTable new];
    [refer set:map];
    for (NSUInteger i = 0; i < count; ++i) {
        id key = [self unserialize];
        id value = [self unserialize];
        [map setObject:value forKey:key];
    }
    [self checkTag:HproseTagClosebrace];
    return map;

}

- (NSDictionary *) readObjectAsDict {
    Class cls = classref[[self readUI32:HproseTagOpenbrace]];
    NSArray *propNames = fieldsref[cls];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[propNames count]];
    [refer set:dict];
    for (id name in propNames) {
        dict[name] = [self unserialize];
    }
    [self checkTag:HproseTagClosebrace];
    return dict;
}

- (NSMapTable *) readObjectAsMapTable {
    Class cls = classref[[self readUI32:HproseTagOpenbrace]];
    NSArray *propNames = fieldsref[cls];
    NSMapTable *map = [NSMapTable new];
    [refer set:map];
    for (id name in propNames) {
        [map setObject:[self unserialize] forKey:name];
    }
    [self checkTag:HproseTagClosebrace];
    return map;
}

- (id) readObjectWithoutTag:(Class)cls {
    Class cls2 = classref[[self readUI32:HproseTagOpenbrace]];
    if (cls == Nil || cls == [NSObject class] || [cls2 isSubclassOfClass:cls]) {
        cls = cls2;
    }
    else {
        @throw [self castExceptionFromClass:cls2 toClass:cls];
    }
    NSArray *propNames = fieldsref[cls];
    NSDictionary *properties = [HproseHelper getHproseProperties:cls];
    id obj = [cls new];
    [refer set:obj];
    for (id name in propNames) {
        [self readProperty:properties[name] forObject:obj];
    }
    [self checkTag:HproseTagClosebrace];
    return obj;
}

- (id) readMapAsObject:(Class)cls {
    NSDictionary *properties = [HproseHelper getHproseProperties:cls];
    NSUInteger count = [self readUI32:HproseTagOpenbrace];
    id obj = [[cls alloc] init];
    [refer set:obj];
    for (NSUInteger i = 0; i < count; ++i) {
        id name = [self unserialize:[NSString class]];
        [self readProperty:properties[name] forObject:obj];
    }
    [self checkTag:HproseTagClosebrace];
    return obj;
}

- (void) readProperty:(HproseProperty *)property forObject:(id)obj {
    if (property == nil) {
        [self unserialize];
        return;
    }
    IMP setterImp = [property setterImp];
    SEL setter = [property setter];
    id value = [self unserialize:[property classRef] withType:[property type]];
    switch ([property type]) {
        case _C_ID:
            ((void (*)(id, SEL, id))setterImp)(obj, setter, value);
            break;
        case _C_CHR:
            ((void (*)(id, SEL, char))setterImp)(obj, setter, [value charValue]);
            break;
        case _C_SHT:
            ((void (*)(id, SEL, short))setterImp)(obj, setter, [value shortValue]);
            break;
        case _C_INT:
            ((void (*)(id, SEL, int))setterImp)(obj, setter, [value intValue]);
            break;
        case _C_LNG:
            ((void (*)(id, SEL, long))setterImp)(obj, setter, [value longValue]);
            break;
        case _C_LNG_LNG:
            ((void (*)(id, SEL, long long))setterImp)(obj, setter, [value longLongValue]);
            break;
        case _C_UCHR:
            ((void (*)(id, SEL, unsigned char))setterImp)(obj, setter, [value unsignedCharValue]);
            break;
        case _C_USHT:
            ((void (*)(id, SEL, unsigned short))setterImp)(obj, setter, [value unsignedShortValue]);
            break;
        case _C_UINT:
            ((void (*)(id, SEL, unsigned int))setterImp)(obj, setter, [value unsignedIntValue]);
            break;
        case _C_ULNG:
            ((void (*)(id, SEL, unsigned long))setterImp)(obj, setter, [value unsignedLongValue]);
            break;
        case _C_ULNG_LNG:
            ((void (*)(id, SEL, unsigned long long))setterImp)(obj, setter, [value unsignedLongLongValue]);
            break;
        case _C_FLT:
            ((void (*)(id, SEL, float))setterImp)(obj, setter, [value floatValue]);
            break;
        case _C_DBL:
            ((void (*)(id, SEL, double))setterImp)(obj, setter, [value doubleValue]);
            break;
        case _C_BOOL:
            ((void (*)(id, SEL, bool))setterImp)(obj, setter, [value boolValue]);
            break;
        case _C_CHARPTR:
            ((void (*)(id, SEL, const char *))setterImp)(obj, setter, [value UTF8String]);
            break;
        default:
            @throw [HproseException exceptionWithReason:
                    [NSString stringWithFormat:
                     @"Not support this property: %@", [property name]]];
            break;
    }
}

- (void) readClass {
    NSString *className = [self readStringAsNSString:Nil];
    Class cls = [HproseHelper getClass:className];
    int count = [self readI32:HproseTagOpenbrace];
    NSMutableArray *propNames = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++) {
        [propNames addObject:[self readString]];
    }
    [self checkTag:HproseTagClosebrace];
    if (cls == Nil) {
        cls = [HproseHelper createClass:className withPropNames:propNames];
    }
    fieldsref[(id)cls] = propNames;
    [classref addObject:cls];
}

- (id) readRef {
    return [refer read:[self readUI32:HproseTagSemicolon]];
}

@end


@implementation HproseReader

- (id) initWithStream:(NSInputStream *)dataStream simple:(BOOL)b {
    if (self = [super initWithStream:dataStream]) {
        classref = [[NSMutableArray alloc] init];
        refer = b ? [[HproseFakeReaderRefer alloc] init] : [[HproseRealReaderRefer alloc] init];
        fieldsref = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id) initWithStream:(NSInputStream *)dataStream {
    self = [self initWithStream:dataStream simple:NO];
    return self;
}

+ (id) readerWithStream:(NSInputStream *)dataStream simple:(BOOL)b {
    return [[HproseReader alloc] initWithStream:dataStream simple:b];
}

+ (id) readerWithStream:(NSInputStream *)dataStream {
    return [[HproseReader alloc] initWithStream:dataStream];
}


- (id) unserialize {
    int tag = [stream readByte];
    switch (tag) {
        case '0':
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9':
            return @(tag - '0');
        case HproseTagInteger:
            return [self readIntegerWithoutTag];
        case HproseTagDouble:
            return [self readDoubleWithoutTag];
        case HproseTagLong:
            return [self readUntil:HproseTagSemicolon];
        case HproseTagNull:
            return [NSNull null];
        case HproseTagEmpty:
            return @"";
        case HproseTagTrue:
            return @YES;
        case HproseTagFalse:
            return @NO;
        case HproseTagNaN:
            return @(NaN);
        case HproseTagInfinity:
            return [self readInfinityWithoutTag];
        case HproseTagDate:
            return [self readDateWithoutTag];
        case HproseTagTime:
            return [self readTimeWithoutTag];
        case HproseTagBytes:
            return [self readDataWithoutTag];
        case HproseTagUTF8Char:
            return [self readUTF8CharAsString];
        case HproseTagString:
            return [self readStringWithoutTag];
        case HproseTagGuid:
            return [self readUUIDWithoutTag];
        case HproseTagList:
            return [self readArrayWithoutTag];
        case HproseTagMap:
            return [self readDictWithoutTag];
        case HproseTagClass:
            [self readClass];
            return [self readObject:Nil];
        case HproseTagObject:
            return [self readObjectWithoutTag:Nil];
        case HproseTagRef:
            return [self readRef];
        case HproseTagError:
            @throw [HproseException exceptionWithReason:[self readString]];
    }
    @throw unexpectedTag(tag, NULL);
}

- (id) unserialize:(Class)cls {
    return [self unserialize:cls withType:_C_ID];
}

- (id) unserialize:(Class)cls withType:(char)type {
    if (cls == Nil) {
        id result = [self unserialize];
        if (result == [NSNull null]) {
            return nil;
        }
        return result;
    }
    if (cls == [NSObject class]) {
        return [self unserialize];
    }
    if (cls == [NSNumber class]) {
        return [self readNumber:type];
    }
    if (cls == [NSDate class]) {
        return [self readDate];
    }
    if (cls == [NSMutableData class]) {
        return [self readMutableData];
    }
    if (cls == [NSData class]) {
        return [self readData];
    }
    if (cls == [NSMutableString class]) {
        return [self readMutableString];
    }
    if (cls == [NSString class]) {
        return [self readString];
    }
    if ([cls isSubclassOfClass:[NSArray class]]) {
        return [self readArray];
    }
    if ([cls isSubclassOfClass:[NSSet class]]) {
        return [self readSet];
    }
    if ([cls isSubclassOfClass:[NSHashTable class]]) {
        return [self readHashTable];
    }
    if ([cls isSubclassOfClass:[NSDictionary class]]) {
        return [self readDict];
    }
    if ([cls isSubclassOfClass:[NSMapTable class]]) {
        return [self readMapTable];
    }
    return [self readObject:cls];
}

- (void) checkTag:(int)expectTag {
    [self checkTag:expectTag withTag:[stream readByte]];
}

- (void) checkTag:(int)expectTag withTag:(int)tag {
    if (tag != expectTag) {
        char expectTags[2];
        expectTags[0] = (char)expectTag;
        expectTags[1] = 0;
        @throw unexpectedTag(tag, expectTags);
    }
}

- (int) checkTags:(char[])expectTags {
    return [self checkTags:expectTags withTag:[stream readByte]];
}

- (int) checkTags:(char[])expectTags withTag:(int)tag {
    for (int i = 0; expectTags[i] != 0; i++) {
        if (expectTags[i] == tag) return tag;
    }
    @throw unexpectedTag(tag, expectTags);
}

- (int8_t) readInt8 {
    int tag = [stream readByte];
    return (tag == HproseTagNull) ? 0 : [self readInt8WithTag:tag];
}

- (int16_t) readInt16 {
    int tag = [stream readByte];
    return (tag == HproseTagNull) ? 0 : [self readInt16WithTag:tag];
}

- (int32_t) readInt32 {
    int tag = [stream readByte];
    return (tag == HproseTagNull) ? 0 : [self readInt32WithTag:tag];
}

- (int64_t) readInt64 {
    int tag = [stream readByte];
    return (tag == HproseTagNull) ? 0LL : [self readInt64WithTag:tag];
}

- (uint8_t) readUInt8 {
    int tag = [stream readByte];
    return (tag == HproseTagNull) ? 0 : [self readUInt8WithTag:tag];
}

- (uint16_t) readUInt16 {
    int tag = [stream readByte];
    return (tag == HproseTagNull) ? 0 : [self readUInt16WithTag:tag];
}

- (uint32_t) readUInt32 {
    int tag = [stream readByte];
    return (tag == HproseTagNull) ? 0 : [self readUInt32WithTag:tag];
}

- (uint64_t) readUInt64 {
    int tag = [stream readByte];
    return (tag == HproseTagNull) ? 0ULL : [self readUInt64WithTag:tag];
}

- (float) readFloat {
    int tag = [stream readByte];
    return (tag == HproseTagNull) ? 0 : [self readFloatWithTag:tag];
}

- (double) readDouble {
    int tag = [stream readByte];
    return (tag == HproseTagNull) ? 0 : [self readDoubleWithTag:tag];
}

- (BOOL) readBoolean {
    int tag = [stream readByte];
    return (tag == HproseTagNull) ? NO : [self readBooleanWithTag:tag];
}

- (unichar) readUTF8Char {
    int tag = [stream readByte];
    return (tag == HproseTagNull) ? 0 : [self readUTF8CharWithTag:tag];
}

- (NSNumber *) readNumber {
    int tag = [stream readByte];
    switch (tag) {
        case '0':
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9':
            return @(tag - '0');
        case HproseTagInteger:
            return [self readIntegerWithoutTag];
        case HproseTagLong:
            return [[NSNumberFormatter new] numberFromString:[self readUntil:HproseTagSemicolon]];
        case HproseTagDouble:
            return [self readDoubleWithoutTag];
        case HproseTagNaN:
            return @(NaN);
        case HproseTagInfinity:
            return [self readInfinityWithoutTag];
        case HproseTagNull:
            return nil;
        case HproseTagEmpty:
            return @0;
        case HproseTagFalse:
            return @NO;
        case HproseTagTrue:
            return @YES;
        case HproseTagDate:
            return @([[self readDateWithoutTag] timeIntervalSince1970]);
        case HproseTagTime:
            return @([[self readTimeWithoutTag] timeIntervalSince1970]);
        case HproseTagUTF8Char:
            return @([self readUTF8CharWithoutTag]);
        case HproseTagString:
            return [[NSNumberFormatter new] numberFromString:[self readStringWithoutTag]];
        case HproseTagRef: {
            id ref = [self readRef];
            if ([ref isKindOfClass:[NSString class]]) {
                return [[NSNumberFormatter new] numberFromString:ref];
            }
            if ([ref isKindOfClass:[NSDate class]]) {
                return @([ref timeIntervalSince1970]);
            }
            @throw [self castExceptionFromClass:[ref class] to:@"NSNumber"];
        }
        default:
            @throw [self castExceptionFrom:[self tagToString:tag] to:@"NSNumber"];
    }
}

- (NSNumber *) readNumber:(char)type {
    switch (type) {
        case _C_ID: return [self readNumber];
        case _C_CHR: return @((char)[self readInt8]);
        case _C_SHT: return @([self readInt16]);
        case _C_INT: return @([self readInt32]);
        case _C_LNG: return @((sizeof(long) == 4) ? (long)[self readInt32] : (long)[self readInt64]);
        case _C_LNG_LNG: return @([self readInt64]);
        case _C_UCHR: return @([self readUInt8]);
        case _C_USHT: return @([self readUInt16]);
        case _C_UINT: return @([self readUInt32]);
        case _C_ULNG: return @((sizeof(unsigned long) == 4) ? (unsigned long)[self readUInt32] : (unsigned long)[self readUInt64]);
        case _C_ULNG_LNG: return @([self readUInt64]);
        case _C_FLT: return @([self readFloat]);
        case _C_DBL: return @([self readDouble]);
        case _C_BOOL: return @([self readBoolean]);
    }
    @throw [HproseException exceptionWithReason:[NSString stringWithFormat:@"Not support this property: %c", type]];
}

- (NSDate *) readDate {
    int tag = [stream readByte];
    switch (tag) {
        case '0':
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9':
            return [NSDate dateWithTimeIntervalSince1970:(tag - '0')];
        case HproseTagInteger:
            return [NSDate dateWithTimeIntervalSince1970:[self readI32:HproseTagSemicolon]];
        case HproseTagLong:
        case HproseTagDouble:
            return [NSDate dateWithTimeIntervalSince1970:[[self readUntil:HproseTagSemicolon] doubleValue]];
        case HproseTagNull:
            return nil;
        case HproseTagEmpty:
            return nil;
        case HproseTagDate:
            return [self readDateWithoutTag];
        case HproseTagTime:
            return [self readTimeWithoutTag];
        case HproseTagString:
            return [[NSDateFormatter new] dateFromString:[self readStringWithoutTag]];
        case HproseTagRef: {
            id ref = [self readRef];
            if ([ref isKindOfClass:[NSString class]]) {
                return [[NSDateFormatter new] dateFromString:ref];
            }
            if ([ref isKindOfClass:[NSDate class]]) {
                return ref;
            }
            @throw [self castExceptionFromClass:[ref class] to:@"NSDate"];
        }
        default:
            @throw [self castExceptionFrom:[self tagToString:tag] to:@"NSDate"];
    }
}

- (NSData *) readData {
    int tag = [stream readByte];
    switch (tag) {
        case HproseTagNull:
            return nil;
        case HproseTagEmpty:
            return [NSData new];
        case HproseTagBytes:
            return [self readDataWithoutTag];
        case HproseTagString:
            return [self readStringAsNSData];
        case HproseTagRef: {
            id ref = [self readRef];
            if ([ref isKindOfClass:[NSString class]]) {
                return [NSData dataWithBytes:[ref UTF8String] length:[ref lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
            }
            if ([ref isKindOfClass:[NSData class]]) {
                return ref;
            }
            @throw [self castExceptionFromClass:[ref class] to:@"NSData"];
        }
        default:
            @throw [self castExceptionFrom:[self tagToString:tag] to:@"NSData"];
    }
}

- (NSMutableData *) readMutableData {
    int tag = [stream readByte];
    switch (tag) {
        case HproseTagNull:
            return nil;
        case HproseTagEmpty:
            return [NSMutableData new];
        case HproseTagBytes:
            return [self readMutableDataWithoutTag];
        case HproseTagString:
            return [self readStringAsNSMutableData];
        case HproseTagRef: {
            id ref = [self readRef];
            if ([ref isKindOfClass:[NSString class]]) {
                return [NSMutableData dataWithBytes:[ref UTF8String] length:[ref lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
            }
            if ([ref isMemberOfClass:[NSMutableData class]]) {
                return ref;
            }
            if ([ref isMemberOfClass:[NSData class]]) {
                return [NSMutableData dataWithBytes:[ref bytes] length:[ref length]];
            }
            @throw [self castExceptionFromClass:[ref class] to:@"NSMutableData"];
        }
        default:
            @throw [self castExceptionFrom:[self tagToString:tag] to:@"NSMutableData"];
    }
}

- (NSString *) readString {
    int tag = [stream readByte];
    switch (tag) {
        case '0': return @"0";
        case '1': return @"1";
        case '2': return @"2";
        case '3': return @"3";
        case '4': return @"4";
        case '5': return @"5";
        case '6': return @"6";
        case '7': return @"7";
        case '8': return @"8";
        case '9': return @"9";
        case HproseTagInteger:
        case HproseTagLong:
        case HproseTagDouble:
            return [NSString stringWithString:[self readUntil:HproseTagSemicolon]];
        case HproseTagNull:
            return nil;
        case HproseTagEmpty:
            return @"";
        case HproseTagTrue:
            return @"true";
        case HproseTagFalse:
            return @"false";
        case HproseTagNaN:
            return @"NaN";
        case HproseTagInfinity:
            return ([stream readByte] == HproseTagPos) ? @"Infinity" : @"-Infinity";
        case HproseTagDate:
            return [[NSDateFormatter new] stringFromDate:[self readDateWithoutTag]];
        case HproseTagTime:
            return [[NSDateFormatter new] stringFromDate:[self readTimeWithoutTag]];
        case HproseTagUTF8Char:
            return [self readUTF8CharAsString];
        case HproseTagString:
            return [self readStringWithoutTag];
        case HproseTagGuid:
            return [self readGuidWithoutTag];
        case HproseTagRef: {
            id ref = [self readRef];
            if ([ref isKindOfClass:[NSString class]]) {
                return ref;
            }
            if ([ref isKindOfClass:[NSDate class]]) {
                return [[NSDateFormatter new] stringFromDate:ref];
            }
            @throw [self castExceptionFromClass:[ref class] to:@"NSString"];
        }
        default:
            @throw [self castExceptionFrom:[self tagToString:tag] to:@"NSString"];
    }
}

- (NSMutableString *) readMutableString {
    int tag = [stream readByte];
    switch (tag) {
        case '0': return [NSMutableString stringWithString:@"0"];
        case '1': return [NSMutableString stringWithString:@"1"];
        case '2': return [NSMutableString stringWithString:@"2"];
        case '3': return [NSMutableString stringWithString:@"3"];
        case '4': return [NSMutableString stringWithString:@"4"];
        case '5': return [NSMutableString stringWithString:@"5"];
        case '6': return [NSMutableString stringWithString:@"6"];
        case '7': return [NSMutableString stringWithString:@"7"];
        case '8': return [NSMutableString stringWithString:@"8"];
        case '9': return [NSMutableString stringWithString:@"9"];
        case HproseTagInteger:
        case HproseTagLong:
        case HproseTagDouble:
            return (NSMutableString *)[self readUntil:HproseTagSemicolon];
        case HproseTagNull:
            return nil;
        case HproseTagEmpty:
            return [NSMutableString string];
        case HproseTagTrue:
            return [NSMutableString stringWithString:@"true"];
        case HproseTagFalse:
            return [NSMutableString stringWithString:@"false"];
        case HproseTagNaN:
            return [NSMutableString stringWithString:@"NaN"];
        case HproseTagInfinity:
            return [NSMutableString stringWithString:([stream readByte] == HproseTagPos) ? @"Infinity" : @"-Infinity"];
        case HproseTagDate:
            return [NSMutableString stringWithString:[[NSDateFormatter new] stringFromDate:[self readDateWithoutTag]]];
        case HproseTagTime:
            return [NSMutableString stringWithString:[[NSDateFormatter new] stringFromDate:[self readTimeWithoutTag]]];
        case HproseTagUTF8Char:
            return [self readUTF8CharAsMutableString];
        case HproseTagString:
            return [self readMutableStringWithoutTag];
        case HproseTagGuid:
            return [NSMutableString stringWithString:[self readGuidWithoutTag]];
        case HproseTagRef: {
            id ref = [self readRef];
            if ([ref isMemberOfClass:[NSMutableString class]]) {
                return ref;
            }
            if ([ref isMemberOfClass:[NSString class]]) {
                return [NSMutableString stringWithString:ref];
            }
            if ([ref isKindOfClass:[NSDate class]]) {
                return [NSMutableString stringWithString:[[NSDateFormatter new] stringFromDate:ref]];
            }
            @throw [self castExceptionFromClass:[ref class] to:@"NSMutableString"];
        }
        default:
            @throw [self castExceptionFrom:[self tagToString:tag] to:@"NSMutableString"];
    }
}

- (NSUUID *) readUUID {
    int tag = [stream readByte];
    switch (tag) {
        case HproseTagNull:
            return nil;
        case HproseTagEmpty:
            return nil;
        case HproseTagString:
            return [[NSUUID alloc] initWithUUIDString:[self readStringWithoutTag]];
        case HproseTagGuid:
            return [self readUUIDWithoutTag];
        case HproseTagRef: {
            id ref = [self readRef];
            if ([ref isKindOfClass:[NSString class]]) {
                return [[NSUUID alloc] initWithUUIDString:ref];
            }
            if ([ref isKindOfClass:[NSUUID class]]) {
                return ref;
            }
            @throw [self castExceptionFromClass:[ref class] to:@"NSUUID"];
        }
        default:
            @throw [self castExceptionFrom:[self tagToString:tag] to:@"NSUUID"];
    }
}

- (NSArray *) readArray {
    int tag = [stream readByte];
    switch (tag) {
        case HproseTagNull:
            return nil;
        case HproseTagList:
            return [self readArrayWithoutTag];
        case HproseTagRef: {
            id ref = [self readRef];
            if ([ref isKindOfClass:[NSArray class]]) {
                return ref;
            }
            @throw [self castExceptionFromClass:[ref class] to:@"NSArray"];
        }
        default:
            @throw [self castExceptionFrom:[self tagToString:tag] to:@"NSArray"];
    }
}

- (NSSet *) readSet {
    int tag = [stream readByte];
    switch (tag) {
        case HproseTagNull:
            return nil;
        case HproseTagList:
            return [self readSetWithoutTag];
        case HproseTagRef: {
            id ref = [self readRef];
            if ([ref isKindOfClass:[NSSet class]]) {
                return ref;
            }
            @throw [self castExceptionFromClass:[ref class] to:@"NSSet"];
        }
        default:
            @throw [self castExceptionFrom:[self tagToString:tag] to:@"NSSet"];
    }
}

- (NSHashTable *) readHashTable {
    int tag = [stream readByte];
    switch (tag) {
        case HproseTagNull:
            return nil;
        case HproseTagList:
            return [self readHashTableWithoutTag];
        case HproseTagRef: {
            id ref = [self readRef];
            if ([ref isKindOfClass:[NSHashTable class]]) {
                return ref;
            }
            @throw [self castExceptionFromClass:[ref class] to:@"NSHashTable"];
        }
        default:
            @throw [self castExceptionFrom:[self tagToString:tag] to:@"NSHashTable"];
    }
}

- (NSDictionary *) readDict {
    int tag = [stream readByte];
    switch (tag) {
        case HproseTagNull:
            return nil;
        case HproseTagList:
            return [self readArrayAsDict];
        case HproseTagMap:
            return [self readDictWithoutTag];
        case HproseTagClass:
            [self readClass];
            return [self readDict];
        case HproseTagObject:
            return [self readObjectAsDict];
        case HproseTagRef: {
            id ref = [self readRef];
            if ([ref isKindOfClass:[NSDictionary class]]) {
                return ref;
            }
            @throw [self castExceptionFromClass:[ref class] to:@"NSDictionary"];
        }
        default:
            @throw [self castExceptionFrom:[self tagToString:tag] to:@"NSDictionary"];
    }
}

- (NSMapTable *) readMapTable {
    int tag = [stream readByte];
    switch (tag) {
        case HproseTagNull:
            return nil;
        case HproseTagList:
            return [self readArrayAsMapTable];
        case HproseTagMap:
            return [self readMapTableWithoutTag];
        case HproseTagClass:
            [self readClass];
            return [self readMapTable];
        case HproseTagObject:
            return [self readObjectAsMapTable];
        case HproseTagRef: {
            id ref = [self readRef];
            if ([ref isKindOfClass:[NSMapTable class]]) {
                return ref;
            }
            @throw [self castExceptionFromClass:[ref class] to:@"NSMapTable"];
        }
        default:
            @throw [self castExceptionFrom:[self tagToString:tag] to:@"NSMapTable"];
    }
}

- (id) readObject:(Class)cls {
    int tag = [stream readByte];
    switch (tag) {
        case HproseTagNull:
            return nil;
        case HproseTagMap:
            return [self readMapAsObject:cls];
        case HproseTagClass:
            [self readClass];
            return [self readObject:cls];
        case HproseTagObject:
            return [self readObjectWithoutTag:cls];
        case HproseTagRef: {
            id ref = [self readRef];
            if (cls == Nil || [ref isKindOfClass:cls]) {
                return ref;
            }
            @throw [self castExceptionFromClass:[ref class] toClass:cls];
        }
        default:
            @throw [self castExceptionFrom:[self tagToString:tag] toClass:cls];
    }
}

- (void) reset {
    [refer reset];
    [classref removeAllObjects];
    [fieldsref removeAllObjects];
}

@end