#import "Hprose.h"

@interface LogFilter : NSObject<HproseFilter> {
}

- (NSData *) inputFilter:(NSData *) data withContext:(id) context;
- (NSData *) outputFilter:(NSData *) data withContext:(id) context;

@end

