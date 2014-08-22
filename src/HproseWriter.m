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
 * HproseWriter.m                                         *
 *                                                        *
 * hprose writer class for Objective-C.                   *
 *                                                        *
 * LastModified: Aug 22, 2014                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import <objc/runtime.h>
#import "HproseException.h"
#import "HproseTags.h"
#import "HproseProperty.h"
#import "HproseHelper.h"
#import "HproseWriter.h"

@interface HproseWriter(PrivateMethods)

- (NSUInteger) writeClass:(Class)cls;
- (void) writeProperty:(HproseProperty *)property forObject:(id)o;

- (void) writeInt8:(int8_t)i withStream:(NSOutputStream *)dataStream;
- (void) writeInt16:(int16_t)i withStream:(NSOutputStream *)dataStream;
- (void) writeInt32:(int32_t)i withStream:(NSOutputStream *)dataStream;
- (void) writeInt64:(int64_t)i withStream:(NSOutputStream *)dataStream;
- (void) writeUInt8:(uint8_t)i withStream:(NSOutputStream *)dataStream;
- (void) writeUInt16:(uint16_t)i withStream:(NSOutputStream *)dataStream;
- (void) writeUInt32:(uint32_t)i withStream:(NSOutputStream *)dataStream;
- (void) writeUInt64:(uint64_t)i withStream:(NSOutputStream *)dataStream;

@end

@implementation HproseWriter(PrivateMethods)

static uint8_t minInt32Buf[11] = {'-', '2', '1', '4', '7', '4', '8', '3', '6', '4', '8'};
static uint8_t minInt64Buf[20] = {'-', '9', '2', '2', '3', '3', '7', '2', '0', '3', '6', '8', '5', '4', '7', '7', '5', '8', '0', '8'};

- (NSUInteger) writeClass:(Class)cls {
    NSDictionary * properties = [HproseHelper getHproseProperties:cls];
    [stream writeByte:HproseTagClass];
    NSString *className = [HproseHelper getClassName:cls];
    int len = (int)[className length];
    [self writeInt32:len withStream:stream];
    [stream writeByte:HproseTagQuote];
    if (len > 0) {
        [stream writeBuffer:(const uint8_t *)[className UTF8String] maxLength:len];
    }
    [stream writeByte:HproseTagQuote];
    int count = (int)[properties count];
    if (count > 0) {
        [self writeInt32:count withStream:stream];
    }
    [stream writeByte:HproseTagOpenbrace];
    for (id name in properties) {
        [self writeString: name];
    }
    [stream writeByte:HproseTagClosebrace];
    [classref addObject:cls];
    return [classref count] - 1;
}

- (void) writeProperty:(HproseProperty *)property forObject:(id)o {
    IMP getterImp = [property getterImp];
    SEL getter = [property getter];
    switch ([property type]) {
        case _C_ID:
            [self serialize:((id (*)(id, SEL))getterImp)(o, getter)];
            break;
        case _C_CHR:
            [self writeInt8:((char (*)(id, SEL))getterImp)(o, getter)];
            break;
        case _C_SHT:
            [self writeInt16:((short (*)(id, SEL))getterImp)(o, getter)];
            break;
        case _C_INT:
            [self writeInt32:((int (*)(id, SEL))getterImp)(o, getter)];
            break;
        case _C_LNG:
            (sizeof(long) == 4) ?
            [self writeInt32:((long (*)(id, SEL))getterImp)(o, getter)] :
            [self writeInt64:((long (*)(id, SEL))getterImp)(o, getter)];
            break;
        case _C_LNG_LNG:
            [self writeInt64:((long long (*)(id, SEL))getterImp)(o, getter)];
            break;
        case _C_UCHR:
            [self writeUInt8:((unsigned char (*)(id, SEL))getterImp)(o, getter)];
            break;
        case _C_USHT:
            [self writeUInt16:((unsigned short (*)(id, SEL))getterImp)(o, getter)];
            break;
        case _C_UINT:
            [self writeUInt32:((unsigned int (*)(id, SEL))getterImp)(o, getter)];
            break;
        case _C_ULNG:
            (sizeof(unsigned long) == 4) ?
            [self writeUInt32:((unsigned long (*)(id, SEL))getterImp)(o, getter)] :
            [self writeUInt64:((unsigned long (*)(id, SEL))getterImp)(o, getter)];
            break;
        case _C_ULNG_LNG:
            [self writeUInt64:((unsigned long long (*)(id, SEL))getterImp)(o, getter)];
            break;
        case _C_FLT:
            [self writeFloat:((float (*)(id, SEL))getterImp)(o, getter)];
            break;
        case _C_DBL:
            [self writeDouble:((double (*)(id, SEL))getterImp)(o, getter)];
            break;
        case _C_BOOL:
            [self writeBoolean:((bool (*)(id, SEL))getterImp)(o, getter)];
            break;
        case _C_CHARPTR:
            [self writeString:@(((const char * (*)(id, SEL))getterImp)(o, getter))];
            break;
        default:
            @throw [HproseException exceptionWithReason:
                    [NSString stringWithFormat:
                     @"Not support this property: %@", [property name]]];
            break;
    }
}

- (void) writeInt8:(int8_t)i withStream:(NSOutputStream *)dataStream {
    if (i == INT8_MIN) {
        [self writeInt32:(int32_t)i withStream:dataStream];
        return;
    }
    int off, len;
    if (i >= 0 && i <= 9) {
        buf[0] = (uint8_t)(i + '0');
        off = 0;
        len = 1;
    }
    else {
        off = 20;
        len = 0;
        BOOL neg = NO;
        if (i < 0) {
            neg = YES;
            i = -i;
        }
        while (i != 0) {
            buf[--off] = (uint8_t) (i % 10 + '0');
            ++len;
            i /= 10;
        }
        if (neg) {
            buf[--off] = '-';
            ++len;
        }
    }
    [dataStream writeBuffer:(const uint8_t *)(buf + off) maxLength:len];
}

- (void) writeInt16:(int16_t)i withStream:(NSOutputStream *)dataStream {
    if (i == INT16_MIN) {
        [self writeInt32:(int32_t)i withStream:dataStream];
        return;
    }
    int off, len;
    if (i >= 0 && i <= 9) {
        buf[0] = (uint8_t)(i + '0');
        off = 0;
        len = 1;
    }
    else {
        off = 20;
        len = 0;
        BOOL neg = NO;
        if (i < 0) {
            neg = YES;
            i = -i;
        }
        while (i != 0) {
            buf[--off] = (uint8_t) (i % 10 + '0');
            ++len;
            i /= 10;
        }
        if (neg) {
            buf[--off] = '-';
            ++len;
        }
    }
    [dataStream writeBuffer:(const uint8_t *)(buf + off) maxLength:len];
}

- (void) writeInt32:(int32_t)i withStream:(NSOutputStream *)dataStream {
    if (i == INT32_MIN) {
        [dataStream writeBuffer:minInt32Buf maxLength:11];
        return;
    }
    int off, len;
    if (i >= 0 && i <= 9) {
        buf[0] = (uint8_t)(i + '0');
        off = 0;
        len = 1;
    }
    else {
        off = 20;
        len = 0;
        BOOL neg = NO;
        if (i < 0) {
            neg = YES;
            i = -i;
        }
        while (i != 0) {
            buf[--off] = (uint8_t) (i % 10 + '0');
            ++len;
            i /= 10;
        }
        if (neg) {
            buf[--off] = '-';
            ++len;
        }
    }
    [dataStream writeBuffer:(buf + off) maxLength:len];
}

- (void) writeInt64:(int64_t)i withStream:(NSOutputStream *)dataStream {
    if (i == INT64_MIN) {
        [dataStream writeBuffer:minInt64Buf maxLength:20];
        return;
    }
    int off, len;
    if (i >= 0 && i <= 9) {
        buf[0] = (uint8_t)(i + '0');
        off = 0;
        len = 1;
    }
    else {
        off = 20;
        len = 0;
        BOOL neg = NO;
        if (i < 0) {
            neg = YES;
            i = -i;
        }
        while (i != 0) {
            buf[--off] = (uint8_t) (i % 10 + '0');
            ++len;
            i /= 10;
        }
        if (neg) {
            buf[--off] = '-';
            ++len;
        }
    }
    [dataStream writeBuffer:(buf + off) maxLength:len];
}

- (void) writeUInt8:(uint8_t)i withStream:(NSOutputStream *)dataStream {
    int off, len;
    if (i <= 9) {
        buf[0] = (uint8_t)(i + '0');
        off = 0;
        len = 1;
    }
    else {
        off = 20;
        len = 0;
        while (i != 0) {
            buf[--off] = (uint8_t) (i % 10 + '0');
            ++len;
            i /= 10;
        }
    }
    [dataStream writeBuffer:(buf + off) maxLength:len];
}

- (void) writeUInt16:(uint16_t)i withStream:(NSOutputStream *)dataStream {
    int off, len;
    if (i <= 9) {
        buf[0] = (uint8_t)(i + '0');
        off = 0;
        len = 1;
    }
    else {
        off = 20;
        len = 0;
        while (i != 0) {
            buf[--off] = (uint8_t) (i % 10 + '0');
            ++len;
            i /= 10;
        }
    }
    [dataStream writeBuffer:(buf + off) maxLength:len];
}

- (void) writeUInt32:(uint32_t)i withStream:(NSOutputStream *)dataStream {
    int off, len;
    if (i <= 9) {
        buf[0] = (uint8_t)(i + '0');
        off = 0;
        len = 1;
    }
    else {
        off = 20;
        len = 0;
        while (i != 0) {
            buf[--off] = (uint8_t) (i % 10 + '0');
            ++len;
            i /= 10;
        }
    }
    [dataStream writeBuffer:(buf + off) maxLength:len];
}

- (void) writeUInt64:(uint64_t)i withStream:(NSOutputStream *)dataStream {
    int off, len;
    if (i <= 9) {
        buf[0] = (uint8_t)(i + '0');
        off = 0;
        len = 1;
    }
    else {
        off = 20;
        len = 0;
        while (i != 0) {
            buf[--off] = (uint8_t) (i % 10 + '0');
            ++len;
            i /= 10;
        }
    }
    [dataStream writeBuffer:(buf + off) maxLength:len];
}

@end

@interface HproseFakeWriterRefer : NSObject<HproseWriterRefer>;

@end

@implementation HproseFakeWriterRefer

- (void) set:(id)obj {

}

- (BOOL) write:(id)obj {
    return NO;
}

- (void) reset {

}

@end

@interface HproseRealWriterRefer : NSObject<HproseWriterRefer> {
    HproseWriter *w;
    NSMutableArray *ref;
}

- (id) init:(HproseWriter *)writer;

@end

@implementation HproseRealWriterRefer

- (id) init:(HproseWriter *)writer {
    if((self = [self init])) {
        w = writer;
        ref = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) set:(id)obj {
    [ref addObject:obj];
}

- (BOOL) write:(id)obj {
    NSUInteger r = [ref indexOfObject:obj];
    if (r != NSNotFound) {
        [w.stream writeByte:HproseTagRef];
        [w writeInt32:(int)r withStream:w.stream];
        [w.stream writeByte:HproseTagSemicolon];
        return YES;
    }
    return NO;
}

- (void) reset {
    [ref removeAllObjects];
}

@end

@implementation HproseWriter

@synthesize stream;

static NSTimeZone *utcTimeZone;
static NSDateFormatter *gDateFormatter;
static NSDateFormatter *gTimeFormatter;
static NSDateFormatter *gUTCDateFormatter;
static NSDateFormatter *gUTCTimeFormatter;
static Class classOfNSCFBoolean;

+ (void) initialize {
    if (self == [HproseWriter class]) {
        utcTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        gDateFormatter = [[NSDateFormatter alloc] init];
        gTimeFormatter = [[NSDateFormatter alloc] init];
        gUTCDateFormatter = [[NSDateFormatter alloc] init];
        gUTCTimeFormatter = [[NSDateFormatter alloc] init];
        [gDateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        [gTimeFormatter setTimeZone:[NSTimeZone localTimeZone]];
        [gUTCDateFormatter setTimeZone:utcTimeZone];
        [gUTCTimeFormatter setTimeZone:utcTimeZone];
        [gDateFormatter setDateFormat:@"yyyyMMdd"];
        [gTimeFormatter setDateFormat:@"HHmmss.SSS"];
        [gUTCDateFormatter setDateFormat:@"yyyyMMdd"];
        [gUTCTimeFormatter setDateFormat:@"HHmmss.SSS"];
        NSNumber *b = @YES;
        classOfNSCFBoolean = [b class];
    }
}

- (id) initWithStream:(NSOutputStream *)dataStream {
    self = [self initWithStream:dataStream simple:NO];
    return self;
}

- (id) initWithStream:(NSOutputStream *)dataStream simple:(BOOL)b {
    if (self = [super init]) {
        [self setStream:dataStream];
        classref = [NSMutableArray new];
        refer = b ? [HproseFakeWriterRefer new] : [[HproseRealWriterRefer alloc] init:self];
    }
    return self;
}

+ (id) writerWithStream:(NSOutputStream *)dataStream {
    return [[HproseWriter alloc] initWithStream:dataStream];
}

+ (id) writerWithStream:(NSOutputStream *)dataStream simple:(BOOL)b {
    return [[HproseWriter alloc] initWithStream:dataStream simple:b];
}

- (void) serialize:(id)obj {
    if (obj == nil || obj == [NSNull null]) {
        [self writeNull];
        return;
    }
    Class c = [obj class];
    if (c == classOfNSCFBoolean) {
        [self writeBoolean:[obj boolValue]];
    }
    else if ([c isSubclassOfClass:[NSNumber class]]) {
        [self writeNumber:(NSNumber *)obj];
    }
    else if ([c isSubclassOfClass:[NSDate class]]) {
        if ([[NSTimeZone defaultTimeZone] isEqual:utcTimeZone]) {
            [self writeUTCDateWithRef:(NSDate *)obj];
        }
        else {
            [self writeDateWithRef:(NSDate *)obj];
        }
    }
    else if ([c isSubclassOfClass:[NSData class]]) {
        [self writeDataWithRef:(NSData *)obj];
    }
    else if ([c isSubclassOfClass:[NSString class]]) {
        if ([obj length] == 0) {
            [self writeEmpty];
        }
        else if ([obj length] == 1) {
            [self writeUTF8Char:[obj characterAtIndex:0]];
        }
        else {
            [self writeStringWithRef:(NSString *)obj];
        }
    }
    else if ([c isSubclassOfClass:[NSUUID class]]) {
        [self writeUUIDWithRef:(NSUUID *)obj];
    }
    else if ([c isSubclassOfClass:[NSArray class]]) {
        [self writeArrayWithRef:(NSArray *)obj];
    }
    else if ([c isSubclassOfClass:[NSDictionary class]]) {
        [self writeDictWithRef:(NSDictionary *)obj];
    }
    else if ([c isSubclassOfClass:[NSSet class]]) {
        [self writeSetWithRef:(NSSet *)obj];
    }
    else if ([c isSubclassOfClass:[NSHashTable class]]) {
        [self writeHashTableWithRef:(NSHashTable *)obj];
    }
    else if ([c isSubclassOfClass:[NSMapTable class]]) {
        [self writeMapTableWithRef:(NSMapTable *)obj];
    }
    else {
        [self writeObjectWithRef:obj];
    }
}

- (void) writeInt8:(int8_t)i {
    if (i >= 0 && i <= 9) {
        [stream writeByte:'0' + i];
        return;
    }
    [stream writeByte:HproseTagInteger];
    [self writeInt8:i withStream:stream];
    [stream writeByte:HproseTagSemicolon];
}

- (void) writeInt16:(int16_t)i {
    if (i >= 0 && i <= 9) {
        [stream writeByte:'0' + i];
        return;
    }
    [stream writeByte:HproseTagInteger];
    [self writeInt16:i withStream:stream];
    [stream writeByte:HproseTagSemicolon];
}

- (void) writeInt32:(int32_t)i {
    if (i >= 0 && i <= 9) {
        [stream writeByte:'0' + i];
        return;
    }
    [stream writeByte:HproseTagInteger];
    [self writeInt32:i withStream:stream];
    [stream writeByte:HproseTagSemicolon];
}

- (void) writeInt64:(int64_t)i {
    if (i >= 0 && i <= 9) {
        [stream writeByte:'0' + i];
        return;
    }
    [stream writeByte:HproseTagLong];
    [self writeInt64:i withStream:stream];
    [stream writeByte:HproseTagSemicolon];
}

- (void) writeUInt8:(uint8_t)i {
    if (i <= 9) {
        [stream writeByte:'0' + i];
        return;
    }
    [stream writeByte:HproseTagInteger];
    [self writeUInt8:i withStream:stream];
    [stream writeByte:HproseTagSemicolon];
}

- (void) writeUInt16:(uint16_t)i {
    if (i <= 9) {
        [stream writeByte:'0' + i];
        return;
    }
    [stream writeByte:HproseTagInteger];
    [self writeUInt16:i withStream:stream];
    [stream writeByte:HproseTagSemicolon];
}

- (void) writeUInt32:(uint32_t)i {
    if (i <= 9) {
        [stream writeByte:'0' + i];
        return;
    }
    [stream writeByte:HproseTagLong];
    [self writeUInt32:i withStream:stream];
    [stream writeByte:HproseTagSemicolon];
}

- (void) writeUInt64:(uint64_t)i {
    if (i <= 9) {
        [stream writeByte:'0' + i];
        return;
    }
    [stream writeByte:HproseTagLong];
    [self writeUInt64:i withStream:stream];
    [stream writeByte:HproseTagSemicolon];
}

- (void) writeBigInteger:(NSString *)bi {
    [stream writeByte:HproseTagLong];
    NSData * data = [bi dataUsingEncoding:NSASCIIStringEncoding];
    [stream writeBuffer:(const uint8_t *)[data bytes] maxLength:[data length]];
    [stream writeByte:HproseTagSemicolon];
}

- (void) writeFloat:(float)f {
    if (isnan(f)) {
        [self writeNaN];
    }
    else if (isinf(f)) {
        if (signbit(f)) {
            [self writeNInf];
        }
        else {
            [self writeInf];
        }
    }
    else {
        [stream writeByte:HproseTagDouble];
        NSData * data = [[@(f) stringValue]
                         dataUsingEncoding:NSASCIIStringEncoding];
        [stream writeBuffer:(const uint8_t *)[data bytes] maxLength:[data length]];
        [stream writeByte:HproseTagSemicolon];
    }
}

- (void) writeDouble:(double)d {
    if (isnan(d)) {
        [self writeNaN];
    }
    else if (isinf(d)) {
        if (signbit(d)) {
            [self writeNInf];
        }
        else {
            [self writeInf];
        }
    }
    else {
        [stream writeByte:HproseTagDouble];
        NSData * data = [[@(d) stringValue]
                         dataUsingEncoding:NSASCIIStringEncoding];
        [stream writeBuffer:(const uint8_t *)[data bytes] maxLength:[data length]];
        [stream writeByte:HproseTagSemicolon];
    }
}

- (void) writeNumber:(NSNumber *)n {
    if([n class] == classOfNSCFBoolean) {
        [self writeBoolean:[n boolValue]];
    }
    else {
        const char *type = [n objCType];
        switch (type[0]) {
            case _C_CHR:
                [self writeInt8:[n charValue]];
                break;
            case _C_SHT:
                [self writeInt16:[n shortValue]];
                break;
            case _C_INT:
                [self writeInt32:[n intValue]];
                break;
            case _C_LNG:
                (sizeof(long) == 4) ?
                [self writeInt32:[n longValue]] :
                [self writeInt64:[n longValue]];
                break;
            case _C_LNG_LNG:
                [self writeInt64:[n longLongValue]];
                break;
            case _C_UCHR:
                [self writeUInt8:[n unsignedCharValue]];
                break;
            case _C_USHT:
                [self writeUInt16:[n unsignedShortValue]];
                break;
            case _C_UINT:
                [self writeUInt32:[n unsignedIntValue]];
                break;
            case _C_ULNG:
                (sizeof(unsigned long) == 4) ?
                [self writeUInt32:[n unsignedLongValue]] :
                [self writeUInt64:[n unsignedLongValue]];
                break;
            case _C_ULNG_LNG:
                [self writeUInt64:[n unsignedLongLongValue]];
                break;
            case _C_FLT:
                [self writeFloat:[n floatValue]];
                break;
            case _C_DBL:
                [self writeDouble:[n doubleValue]];
                break;
            case _C_BOOL:
                [self writeBoolean:[n boolValue]];
                break;
            default:
                @throw [HproseException exceptionWithReason:
                        [NSString stringWithFormat:
                         @"Not support this type: %s", type]];
                break;
        }
    }
}

- (void) writeNull {
    [stream writeByte:HproseTagNull];
}

- (void) writeNaN {
    [stream writeByte:HproseTagNaN];
}

- (void) writeInf {
    [stream writeByte:HproseTagInfinity];
    [stream writeByte:HproseTagPos];
}

- (void) writeNInf {
    [stream writeByte:HproseTagInfinity];
    [stream writeByte:HproseTagNeg];
}

- (void) writeEmpty {
    [stream writeByte:HproseTagEmpty];
}

- (void) writeBoolean:(BOOL)b {
    [stream writeByte:(b ? HproseTagTrue : HproseTagFalse)];
}

- (void) writeDate:(NSDate *)date {
    [refer set:date];
    NSString *d = [gDateFormatter stringFromDate:date];
    NSString *t = [gTimeFormatter stringFromDate:date];
    NSData * data;
    if ([t isEqualToString:@"000000.000"]) {
        [stream writeByte:HproseTagDate];
        data = [d dataUsingEncoding:NSASCIIStringEncoding];
        [stream writeBuffer:(const uint8_t *)[data bytes] maxLength:[data length]];
        [stream writeByte:HproseTagSemicolon];
    }
    else if ([d isEqualToString:@"19700101"]) {
        [stream writeByte:HproseTagTime];
        data = [t dataUsingEncoding:NSASCIIStringEncoding];
        [stream writeBuffer:(const uint8_t *)[data bytes] maxLength:[data length]];
        [stream writeByte:HproseTagSemicolon];
    }
    else {
        [stream writeByte:HproseTagDate];
        data = [d dataUsingEncoding:NSASCIIStringEncoding];
        [stream writeBuffer:(const uint8_t *)[data bytes] maxLength:[data length]];
        [stream writeByte:HproseTagTime];
        data = [t dataUsingEncoding:NSASCIIStringEncoding];
        [stream writeBuffer:(const uint8_t *)[data bytes] maxLength:[data length]];
        [stream writeByte:HproseTagSemicolon];
    }
}

- (void) writeDateWithRef:(NSDate *)date {
    if (![refer write:date]) {
        [self writeDate:date];
    }
}

- (void) writeUTCDate:(NSDate *)date {
    [refer set:date];
    NSString *d = [gUTCDateFormatter stringFromDate:date];
    NSString *t = [gUTCTimeFormatter stringFromDate:date];
    NSData * data;
    if ([t isEqualToString:@"000000.000"]) {
        [stream writeByte:HproseTagDate];
        data = [d dataUsingEncoding:NSASCIIStringEncoding];
        [stream writeBuffer:(const uint8_t *)[data bytes] maxLength:[data length]];
        [stream writeByte:HproseTagUTC];
    }
    else if ([d isEqualToString:@"19700101"]) {
        [stream writeByte:HproseTagTime];
        data = [t dataUsingEncoding:NSASCIIStringEncoding];
        [stream writeBuffer:(const uint8_t *)[data bytes] maxLength:[data length]];
        [stream writeByte:HproseTagUTC];
    }
    else {
        [stream writeByte:HproseTagDate];
        data = [d dataUsingEncoding:NSASCIIStringEncoding];
        [stream writeBuffer:(const uint8_t *)[data bytes] maxLength:[data length]];
        [stream writeByte:HproseTagTime];
        data = [t dataUsingEncoding:NSASCIIStringEncoding];
        [stream writeBuffer:(const uint8_t *)[data bytes] maxLength:[data length]];
        [stream writeByte:HproseTagUTC];
    }
}

- (void) writeUTCDateWithRef:(NSDate *)date {
    if (![refer write:date]) {
        [self writeUTCDate:date];
    }
}

- (void) writeBytes:(const uint8_t *)bytes length:(int)l {
    NSData * data = [[NSData alloc] initWithBytesNoCopy:(void *)bytes
                                    length:l
                                    freeWhenDone:NO];
    [self writeData:data];
}

- (void) writeBytesWithRef:(const uint8_t *)bytes length:(int)l {
    NSData * data = [[NSData alloc] initWithBytesNoCopy:(void *)bytes
                                    length:l
                                    freeWhenDone:NO];
    [self writeDataWithRef:data];
}

- (void) writeData:(NSData *)data {
    [refer set:data];
    [stream writeByte:HproseTagBytes];
    int length = (int)[data length];
    if (length > 0) {
        [self writeInt32:length withStream:stream];
    }
    [stream writeByte:HproseTagQuote];
    if (length > 0) {
        [stream writeBuffer:(const uint8_t *)[data bytes] maxLength:length];
    }
    [stream writeByte:HproseTagQuote];
}

- (void) writeDataWithRef:(NSData *)data {
    if (![refer write:data]) {
        [self writeData:data];
    }
}

- (void) writeUTF8Char:(unichar)c {
    [stream writeByte:HproseTagUTF8Char];
    if (c < 0x80) {
        [stream writeByte:c];
    }
    else if (c < 0x800) {
        [stream writeByte:(0xc0 | (c >> 6))];
        [stream writeByte:(0x80 | (c & 0x3f))];
    }
    else {
        [stream writeByte:(0xe0 | (c >> 12))];
        [stream writeByte:(0x80 | ((c >> 6) & 0x3f))];
        [stream writeByte:(0x80 | (c & 0x3f))];
    }
}

- (void) writeString:(NSString *)str {
    [refer set:str];
    [stream writeByte:HproseTagString];
    int length = (int)[str length];
    if (length > 0) {
        [self writeInt32:length withStream:stream];
    }
    [stream writeByte:HproseTagQuote];
    if (length > 0) {
        NSData * data = [str dataUsingEncoding:NSUTF8StringEncoding];
        [stream writeBuffer:(const uint8_t *)[data bytes] maxLength:[data length]];
    }
    [stream writeByte:HproseTagQuote];
}

- (void) writeStringWithRef:(NSString *)str {
    if (![refer write:str]) {
        [self writeString:str];
    }
}

- (void) writeUUID:(NSUUID *)uuid {
    [refer set:uuid];
    [stream writeByte:HproseTagGuid];
    [stream writeByte:HproseTagOpenbrace];
    NSData * data = [[uuid UUIDString] dataUsingEncoding:NSUTF8StringEncoding];
    [stream writeBuffer:(const uint8_t *)[data bytes] maxLength:[data length]];
    [stream writeByte:HproseTagClosebrace];
}

- (void) writeUUIDWithRef:(NSUUID *)uuid {
    if (![refer write:uuid]) {
        [self writeUUID:uuid];
    }
}

- (void) writeArray:(NSArray *)array {
    [refer set:array];
    [stream writeByte:HproseTagList];
    int count = (int)[array count];
    if (count > 0) {
        [self writeInt32:count withStream:stream];
    }
    [stream writeByte:HproseTagOpenbrace];
    if (count > 0) {
        for (id obj in array) {
            [self serialize:obj];
        }
    }
    [stream writeByte:HproseTagClosebrace];
}

- (void) writeArrayWithRef:(NSArray *)array {
    if (![refer write:array]) {
        [self writeArray:array];
    }
}

- (void) writeSet:(NSSet *)set {
    [refer set:set];
    [stream writeByte:HproseTagList];
    int count = (int)[set count];
    if (count > 0) {
        [self writeInt32:count withStream:stream];
    }
    [stream writeByte:HproseTagOpenbrace];
    if (count > 0) {
        for (id obj in set) {
            [self serialize:obj];
        }
    }
    [stream writeByte:HproseTagClosebrace];
}

- (void) writeSetWithRef:(NSSet *)set {
    if (![refer write:set]) {
        [self writeSet:set];
    }
}

- (void) writeHashTable:(NSHashTable *)hashtable {
    [refer set:hashtable];
    [stream writeByte:HproseTagList];
    int count = (int)[hashtable count];
    if (count > 0) {
        [self writeInt32:count withStream:stream];
    }
    [stream writeByte:HproseTagOpenbrace];
    if (count > 0) {
        for (id obj in hashtable) {
            [self serialize:obj];
        }
    }
    [stream writeByte:HproseTagClosebrace];
}

- (void) writeHashTableWithRef:(NSHashTable *)hashtable {
    if (![refer write:hashtable]) {
        [self writeHashTable:hashtable];
    }
}

- (void) writeDict:(NSDictionary *)dict {
    [refer set:dict];
    [stream writeByte:HproseTagMap];
    int count = (int)[dict count];
    if (count) {
        [self writeInt32:count withStream:stream];
    }
    [stream writeByte:HproseTagOpenbrace];
    if (count > 0) {
        for (id key in dict) {
            [self serialize:key];
            [self serialize:dict[key]];
        }
    }
    [stream writeByte:HproseTagClosebrace];
}

- (void) writeDictWithRef:(NSDictionary *)dict {
    if (![refer write:dict]) {
        [self writeDict:dict];
    }
}

- (void) writeMapTable:(NSMapTable *)map {
    [refer set:map];
    [stream writeByte:HproseTagMap];
    int count = (int)[map count];
    if (count) {
        [self writeInt32:count withStream:stream];
    }
    [stream writeByte:HproseTagOpenbrace];
    if (count > 0) {
        for (id key in map) {
            [self serialize:key];
            [self serialize:[map objectForKey:key]];
        }
    }
    [stream writeByte:HproseTagClosebrace];
}

- (void) writeMapTableWithRef:(NSMapTable *)map {
    if (![refer write:map]) {
        [self writeMapTable:map];
    }
}

- (void) writeObject:(id)obj {
    Class cls = [obj class];
    NSUInteger cr = [classref indexOfObjectIdenticalTo:cls];
    if (cr == NSNotFound) {
        cr = [self writeClass:cls];
    }
    [refer set:obj];
    NSDictionary * properties = [HproseHelper getHproseProperties:cls];
    [stream writeByte:HproseTagObject];
    [self writeInt32:(int)cr withStream:stream];
    [stream writeByte:HproseTagOpenbrace];
    if ([properties count] > 0) {
        for (id name in properties) {
            [self writeProperty:properties[name] forObject:obj];
        }
    }
    [stream writeByte:HproseTagClosebrace];

}

- (void) writeObjectWithRef:(id)obj {
    if (![refer write:obj]) {
        [self writeObject:obj];
    }
}

- (void) reset {
    [classref removeAllObjects];
    [refer reset];
}

@end