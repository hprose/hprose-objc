#import "Hprose.h"

@interface LogFilter : NSObject<HproseFilter> {
}

- (NSData *) inputFilter:(NSData *) data withContext:(HproseContext *) context;
- (NSData *) outputFilter:(NSData *) data withContext:(HproseContext *) context;

@end

