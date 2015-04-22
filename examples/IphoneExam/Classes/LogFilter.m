#import <Foundation/Foundation.h>
#import "LogFilter.h"

@implementation LogFilter

- (NSData *) inputFilter:(NSData *) data withContext:(id) context {
    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    return data;
}

- (NSData *) outputFilter:(NSData *) data withContext:(id) context {
    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    return data;
}

@end