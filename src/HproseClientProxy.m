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
 * HproseClientProxy.m                                    *
 *                                                        *
 * hprose client proxy for Objective-C.                   *
 *                                                        *
 * LastModified: Nov 16, 2017                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import <objc/runtime.h>
#import "HproseException.h"
#import "HproseClient.h"
#import "HproseClientProxy.h"

NSMutableArray *getArguments(NSUInteger count, NSMethodSignature *methodSignature, NSInvocation *anInvocation, BOOL *byRef) {
    NSMutableArray *args = [NSMutableArray arrayWithCapacity:count - 2];
    for (NSUInteger i = 2; i < count; i++) {
        const char *type = [methodSignature getArgumentTypeAtIndex:i];
        id arg;
        int j = 0;
        char t = type[j];
        switch (t) {
            case 'r':
            case 'n':
            case 'N':
            case 'o':
            case 'O':
            case 'R':
            case 'V':
                if (t == 'N' || t == 'o' || t == 'R') {
                    *byRef = YES;
                }
                t = type[++j];
                break;
        }
        switch (t) {
            case _C_ID: {
                __unsafe_unretained id value;
                [anInvocation getArgument:&value atIndex:i];
                if (value == nil) {
                    arg = [NSNull null];
                }
                else {
                    arg = value;
                }
                break;
            }
            case _C_CHR: {
                char value;
                [anInvocation getArgument:&value atIndex:i];
                arg = @(value);
                break;
            }
            case _C_UCHR: {
                unsigned char value;
                [anInvocation getArgument:&value atIndex:i];
                arg = @(value);
                break;
            }
            case _C_SHT: {
                short value;
                [anInvocation getArgument:&value atIndex:i];
                arg = @(value);
                break;
            }
            case _C_USHT: {
                unsigned short value;
                [anInvocation getArgument:&value atIndex:i];
                arg = @(value);
                break;
            }
            case _C_INT: {
                int value;
                [anInvocation getArgument:&value atIndex:i];
                arg = @(value);
                break;
            }
            case _C_UINT: {
                unsigned int value;
                [anInvocation getArgument:&value atIndex:i];
                arg = @(value);
                break;
            }
            case _C_LNG: {
                long value;
                [anInvocation getArgument:&value atIndex:i];
                arg = @(value);
                break;
            }
            case _C_ULNG: {
                unsigned long value;
                [anInvocation getArgument:&value atIndex:i];
                arg = @(value);
                break;
            }
            case _C_LNG_LNG: {
                long long value;
                [anInvocation getArgument:&value atIndex:i];
                arg = @(value);
                break;
            }
            case _C_ULNG_LNG: {
                unsigned long long value;
                [anInvocation getArgument:&value atIndex:i];
                arg = @(value);
                break;
            }
            case _C_FLT: {
                float value;
                [anInvocation getArgument:&value atIndex:i];
                arg = @(value);
                break;
            }
            case _C_DBL: {
                double value;
                [anInvocation getArgument:&value atIndex:i];
                arg = @(value);
                break;
            }
            case _C_BOOL: {
                BOOL value;
                [anInvocation getArgument:&value atIndex:i];
                arg = @(value);
                break;
            }
            case _C_CHARPTR: {
                char *value;
                [anInvocation getArgument:&value atIndex:i];
                arg = @(value);
                break;
            }
            case _C_PTR: {
                switch (type[++j]) {
                    case _C_ID: {
                        __unsafe_unretained id *value;
                        [anInvocation getArgument:&value atIndex:i];
                        if (value == nil || *value == nil) {
                            arg = [NSNull null];
                        }
                        else {
                            arg = *value;
                        }
                        break;
                    }
                    case _C_CHR: {
                        char *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = @(*value);
                        break;
                    }
                    case _C_UCHR: {
                        unsigned char *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = @(*value);
                        break;
                    }
                    case _C_SHT: {
                        short *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = @(*value);
                        break;
                    }
                    case _C_USHT: {
                        unsigned short *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = @(*value);
                        break;
                    }
                    case _C_INT: {
                        int *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = @(*value);
                        break;
                    }
                    case _C_UINT: {
                        unsigned int *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = @(*value);
                        break;
                    }
                    case _C_LNG: {
                        long *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = @(*value);
                        break;
                    }
                    case _C_ULNG: {
                        unsigned long *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = @(*value);
                        break;
                    }
                    case _C_LNG_LNG: {
                        long long *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = @(*value);
                        break;
                    }
                    case _C_ULNG_LNG: {
                        unsigned long long *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = @(*value);
                        break;
                    }
                    case _C_FLT: {
                        float *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = @(*value);
                        break;
                    }
                    case _C_DBL: {
                        double *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = @(*value);
                        break;
                    }
                    case _C_BOOL: {
                        BOOL *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = @(*value);
                        break;
                    }
                    case _C_CHARPTR: {
                        char **value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = @(*value);
                        break;
                    }
                    default:
                        @throw [NSException
                                exceptionWithName:NSParseErrorException
                                reason:[NSString stringWithFormat:@"Not support this type: %s", type]
                                userInfo:nil];
                        break;
                }
                break;
            }
            case _C_ARY_B: {
                int n = 0;
                for (++j; isdigit(type[j]); ++j) n = n * 10 + (type[j] - '0');
                switch (type[j]) {
                    case _C_ID: {
                        __unsafe_unretained id *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSMutableArray arrayWithCapacity:n];
                        for (int k = 0; k < n; ++k) [arg addObject:value[k]];
                        break;
                    }
                    case _C_CHR: {
                        char *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSMutableArray arrayWithCapacity:n];
                        for (int k = 0; k < n; ++k) [arg addObject:@(value[k])];
                        break;
                    }
                    case _C_UCHR: {
                        unsigned char *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSMutableArray arrayWithCapacity:n];
                        for (int k = 0; k < n; ++k) [arg addObject:@(value[k])];
                        break;
                    }
                    case _C_SHT: {
                        short *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSMutableArray arrayWithCapacity:n];
                        for (int k = 0; k < n; ++k) [arg addObject:@(value[k])];
                        break;
                    }
                    case _C_USHT: {
                        unsigned short *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSMutableArray arrayWithCapacity:n];
                        for (int k = 0; k < n; ++k) [arg addObject:@(value[k])];
                        break;
                    }
                    case _C_INT: {
                        int *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSMutableArray arrayWithCapacity:n];
                        for (int k = 0; k < n; ++k) [arg addObject:@(value[k])];
                        break;
                    }
                    case _C_UINT: {
                        unsigned int *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSMutableArray arrayWithCapacity:n];
                        for (int k = 0; k < n; ++k) [arg addObject:@(value[k])];
                        break;
                    }
                    case _C_LNG: {
                        long *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSMutableArray arrayWithCapacity:n];
                        for (int k = 0; k < n; ++k) [arg addObject:@(value[k])];
                        break;
                    }
                    case _C_ULNG: {
                        unsigned long *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSMutableArray arrayWithCapacity:n];
                        for (int k = 0; k < n; ++k) [arg addObject:@(value[k])];
                        break;
                    }
                    case _C_LNG_LNG: {
                        long long *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSMutableArray arrayWithCapacity:n];
                        for (int k = 0; k < n; ++k) [arg addObject:@(value[k])];
                        break;
                    }
                    case _C_ULNG_LNG: {
                        unsigned long long *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSMutableArray arrayWithCapacity:n];
                        for (int k = 0; k < n; ++k) [arg addObject:@(value[k])];
                        break;
                    }
                    case _C_FLT: {
                        float *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSMutableArray arrayWithCapacity:n];
                        for (int k = 0; k < n; ++k) [arg addObject:@(value[k])];
                        break;
                    }
                    case _C_DBL: {
                        double *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSMutableArray arrayWithCapacity:n];
                        for (int k = 0; k < n; ++k) [arg addObject:@(value[k])];
                        break;
                    }
                    case _C_BOOL: {
                        BOOL *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSMutableArray arrayWithCapacity:n];
                        for (int k = 0; k < n; ++k) [arg addObject:@(value[k])];
                        break;
                    }
                    case _C_CHARPTR: {
                        char **value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSMutableArray arrayWithCapacity:n];
                        for (int k = 0; k < n; ++k) [arg addObject:@(value[k])];
                        break;
                    }
                    default:
                        @throw [NSException
                                exceptionWithName:NSParseErrorException
                                reason:[NSString stringWithFormat:@"Not support this type: %s", type]
                                userInfo:nil];
                        break;
                }
                break;
            }
            default:
                @throw [NSException
                        exceptionWithName:NSParseErrorException
                        reason:[NSString stringWithFormat:@"Not support this type: %s", type]
                        userInfo:nil];
                break;
        }
        [args addObject:arg];
    }
    return args;
}

void setArguments(NSUInteger count, NSMethodSignature *methodSignature, NSInvocation *anInvocation, NSMutableArray *args) {
    for (NSUInteger i = 2; i < count; i++) {
        const char *type = [methodSignature getArgumentTypeAtIndex:i];
        id arg = args[i - 2];
        if (arg == [NSNull null]) arg = nil;
        int j = 0;
        BOOL byRef = NO;
        if (type[j] == 'N' || type[j] == 'o' || type[j] == 'R') {
            j++;
            byRef = YES;
        }
        switch (type[j]) {
            case _C_ID:
            case _C_CHR:
            case _C_UCHR:
            case _C_SHT:
            case _C_USHT:
            case _C_INT:
            case _C_UINT:
            case _C_LNG:
            case _C_ULNG:
            case _C_LNG_LNG:
            case _C_ULNG_LNG:
            case _C_FLT:
            case _C_DBL:
            case _C_BOOL:
            case _C_CHARPTR:
                break;
            case _C_PTR: {
                if (!byRef) break;
                switch (type[++j]) {
                    case _C_ID: {
                        __unsafe_unretained id *value;
                        [anInvocation getArgument:&value atIndex:i];
                        *value = arg;
                        break;
                    }
                    case _C_CHR: {
                        char *value;
                        [anInvocation getArgument:&value atIndex:i];
                        *value = [arg charValue];
                        break;
                    }
                    case _C_UCHR: {
                        unsigned char *value;
                        [anInvocation getArgument:&value atIndex:i];
                        *value = [arg unsignedCharValue];
                        break;
                    }
                    case _C_SHT: {
                        short *value;
                        [anInvocation getArgument:&value atIndex:i];
                        *value = [arg shortValue];
                        break;
                    }
                    case _C_USHT: {
                        unsigned short *value;
                        [anInvocation getArgument:&value atIndex:i];
                        *value = [arg unsignedShortValue];
                        break;
                    }
                    case _C_INT: {
                        int *value;
                        [anInvocation getArgument:&value atIndex:i];
                        *value = [arg intValue];
                        break;
                    }
                    case _C_UINT: {
                        unsigned int *value;
                        [anInvocation getArgument:&value atIndex:i];
                        *value = [arg unsignedIntValue];
                        break;
                    }
                    case _C_LNG: {
                        long *value;
                        [anInvocation getArgument:&value atIndex:i];
                        *value = [arg longValue];
                        break;
                    }
                    case _C_ULNG: {
                        unsigned long *value;
                        [anInvocation getArgument:&value atIndex:i];
                        *value = [arg unsignedLongValue];
                        break;
                    }
                    case _C_LNG_LNG: {
                        long long *value;
                        [anInvocation getArgument:&value atIndex:i];
                        *value = [arg longLongValue];
                        break;
                    }
                    case _C_ULNG_LNG: {
                        unsigned long long *value;
                        [anInvocation getArgument:&value atIndex:i];
                        *value = [arg unsignedLongLongValue];
                        break;
                    }
                    case _C_FLT: {
                        float *value;
                        [anInvocation getArgument:&value atIndex:i];
                        *value = [arg floatValue];
                        break;
                    }
                    case _C_DBL: {
                        double *value;
                        [anInvocation getArgument:&value atIndex:i];
                        *value = [arg doubleValue];
                        break;
                    }
                    case _C_BOOL: {
                        BOOL *value;
                        [anInvocation getArgument:&value atIndex:i];
                        *value = [arg boolValue];
                        break;
                    }
                    case _C_CHARPTR: {
                        const char **value;
                        [anInvocation getArgument:&value atIndex:i];
                        *value = [arg UTF8String];
                        break;
                    }
                    default:
                        @throw [NSException
                                exceptionWithName:NSParseErrorException
                                reason:[NSString stringWithFormat:@"Not support this type: %s", type]
                                userInfo:nil];
                        break;
                }
                break;
            }
            case _C_ARY_B: {
                int n = 0;
                for (++j; isdigit(type[j]); ++j) n = n * 10 + (type[j] - '0');
                switch (type[j]) {
                    case _C_ID: {
                        __unsafe_unretained id *value;
                        [anInvocation getArgument:&value atIndex:i];
                        for (int k = 0; k < n; ++k) value[k] = arg[k];
                        break;
                    }
                    case _C_CHR: {
                        char *value;
                        [anInvocation getArgument:&value atIndex:i];
                        for (int k = 0; k < n; ++k) value[k] = [arg[k] charValue];
                        break;
                    }
                    case _C_UCHR: {
                        unsigned char *value;
                        [anInvocation getArgument:&value atIndex:i];
                        for (int k = 0; k < n; ++k) value[k] = [arg[k] unsignedCharValue];
                        break;
                    }
                    case _C_SHT: {
                        short *value;
                        [anInvocation getArgument:&value atIndex:i];
                        for (int k = 0; k < n; ++k) value[k] = [arg[k] shortValue];
                        break;
                    }
                    case _C_USHT: {
                        unsigned short *value;
                        [anInvocation getArgument:&value atIndex:i];
                        for (int k = 0; k < n; ++k) value[k] = [arg[k] unsignedShortValue];
                        break;
                    }
                    case _C_INT: {
                        int *value;
                        [anInvocation getArgument:&value atIndex:i];
                        for (int k = 0; k < n; ++k) value[k] = [arg[k] intValue];
                        break;
                    }
                    case _C_UINT: {
                        unsigned int *value;
                        [anInvocation getArgument:&value atIndex:i];
                        for (int k = 0; k < n; ++k) value[k] = [arg[k] unsignedIntValue];
                        break;
                    }
                    case _C_LNG: {
                        long *value;
                        [anInvocation getArgument:&value atIndex:i];
                        for (int k = 0; k < n; ++k) value[k] = [arg[k] longValue];
                        break;
                    }
                    case _C_ULNG: {
                        unsigned long *value;
                        [anInvocation getArgument:&value atIndex:i];
                        for (int k = 0; k < n; ++k) value[k] = [arg[k] unsignedLongValue];
                        break;
                    }
                    case _C_LNG_LNG: {
                        long long *value;
                        [anInvocation getArgument:&value atIndex:i];
                        for (int k = 0; k < n; ++k) value[k] = [arg[k] longLongValue];
                        break;
                    }
                    case _C_ULNG_LNG: {
                        unsigned long long *value;
                        [anInvocation getArgument:&value atIndex:i];
                        for (int k = 0; k < n; ++k) value[k] = [arg[k] unsignedLongLongValue];
                        break;
                    }
                    case _C_FLT: {
                        float *value;
                        [anInvocation getArgument:&value atIndex:i];
                        for (int k = 0; k < n; ++k) value[k] = [arg[k] floatValue];
                        break;
                    }
                    case _C_DBL: {
                        double *value;
                        [anInvocation getArgument:&value atIndex:i];
                        for (int k = 0; k < n; ++k) value[k] = [arg[k] doubleValue];
                        break;
                    }
                    case _C_BOOL: {
                        BOOL *value;
                        [anInvocation getArgument:&value atIndex:i];
                        for (int k = 0; k < n; ++k) value[k] = [arg[k] boolValue];
                        break;
                    }
                    case _C_CHARPTR: {
                        const char **value;
                        [anInvocation getArgument:&value atIndex:i];
                        for (int k = 0; k < n; ++k) value[k] = [arg[k] UTF8String];
                        break;
                    }
                    default:
                        @throw [NSException
                                exceptionWithName:NSParseErrorException
                                reason:[NSString stringWithFormat:@"Not support this type: %s", type]
                                userInfo:nil];
                        break;
                }
                break;
            }
            default:
                @throw [NSException
                        exceptionWithName:NSParseErrorException
                        reason:[NSString stringWithFormat:@"Not support this type: %s", type]
                        userInfo:nil];
                break;
        }
    }
}

void setReturnValue(char type, __unsafe_unretained id result, NSInvocation *anInvocation) {
    switch (type) {
        case _C_ID: {
            [anInvocation setReturnValue:&result];
            break;
        }
        case _C_CHR: {
            char value = [result charValue];
            [anInvocation setReturnValue:&value];
            break;
        }
        case _C_UCHR: {
            unsigned char value = [result unsignedCharValue];
            [anInvocation setReturnValue:&value];
            break;
        }
        case _C_SHT: {
            short value = [result shortValue];
            [anInvocation setReturnValue:&value];
            break;
        }
        case _C_USHT: {
            unsigned short value = [result unsignedShortValue];
            [anInvocation setReturnValue:&value];
            break;
        }
        case _C_INT: {
            int value = [result intValue];
            [anInvocation setReturnValue:&value];
            break;
        }
        case _C_UINT: {
            unsigned int value = [result unsignedIntValue];
            [anInvocation setReturnValue:&value];
            break;
        }
        case _C_LNG: {
            long value = [result longValue];
            [anInvocation setReturnValue:&value];
            break;
        }
        case _C_ULNG: {
            unsigned long value = [result unsignedLongValue];
            [anInvocation setReturnValue:&value];
            break;
        }
        case _C_LNG_LNG: {
            long long value = [result longLongValue];
            [anInvocation setReturnValue:&value];
            break;
        }
        case _C_ULNG_LNG: {
            unsigned long long value = [result unsignedLongLongValue];
            [anInvocation setReturnValue:&value];
            break;
        }
        case _C_FLT: {
            float value = [result floatValue];
            [anInvocation setReturnValue:&value];
            break;
        }
        case _C_DBL: {
            double value = [result doubleValue];
            [anInvocation setReturnValue:&value];
            break;
        }
        case _C_BOOL: {
            BOOL value = [result boolValue];
            [anInvocation setReturnValue:&value];
            break;
        }
        case _C_CHARPTR: {
            const char *value = [result UTF8String];
            [anInvocation setReturnValue:&value];
            break;
        }
        case _C_VOID: {
            break;
        }
        default:
            @throw [NSException
                    exceptionWithName:NSParseErrorException
                    reason:[NSString stringWithFormat:@"Not support this type: %c", type]
                    userInfo:nil];
            break;
    }
}

@implementation HproseClientProxy

- init:(Protocol *)aProtocol withClient:(HproseClient *)aClient withNameSpace:(NSString *)aNameSpace {
    [self setProtocol:aProtocol];
    [self setClient:aClient];
    [self setNs:aNameSpace];
    return self;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    NSArray *selnames = [NSStringFromSelector([anInvocation selector]) componentsSeparatedByString:@":"];
    NSUInteger namecount = [selnames count];
    NSString *name = selnames[0];
    if (_ns != nil) {
        name = [NSString stringWithFormat:@"%@_%@", _ns, name];
    }
    NSMethodSignature *methodSignature = [anInvocation methodSignature];
    NSUInteger count = [methodSignature numberOfArguments];
    const char *type = [methodSignature methodReturnType];
    HproseCallback callback = NULL;
    HproseBlock __unsafe_unretained block = nil;
    SEL selector = NULL;
    HproseErrorCallback errorCallback = NULL;
    HproseErrorBlock __unsafe_unretained errorBlock = nil;
    SEL errorSelector = NULL;
    id __unsafe_unretained delegate = nil;
    
    BOOL async = NO;
    if ((type[0] == 'V' && type[1] == _C_VOID) || type[0] == _C_VOID) {
        async = YES;
        BOOL _async = (type[0] == 'V');
        if (count > 2) {
            type = [methodSignature getArgumentTypeAtIndex:count - 1];
            if (type[0] == _C_PTR && type[1] == _C_UNDEF) {
                if (count > 3) {
                    type = [methodSignature getArgumentTypeAtIndex:count - 2];
                    if (type[0] == _C_PTR && type[1] == _C_UNDEF) {
                        [anInvocation getArgument:&callback atIndex:count - 2];
                        [anInvocation getArgument:&errorCallback atIndex:count - 1];
                        count -= 2;
                    }
                    else if (type[0] == _C_ID && type[1] == _C_UNDEF) {
                        [anInvocation getArgument:&block atIndex:count - 2];
                        [anInvocation getArgument:&errorCallback atIndex:count - 1];
                        count -= 2;
                    }
                    else if (type[0] == _C_SEL) {
                        [anInvocation getArgument:&selector atIndex:count - 2];
                        [anInvocation getArgument:&errorCallback atIndex:count - 1];
                        count -= 2;
                    }
                    else if ((type[0] == _C_ID) && (count > 4)) {
                        type = [methodSignature getArgumentTypeAtIndex:count - 3];
                        if (type[0] == _C_SEL) {
                            [anInvocation getArgument:&selector atIndex:count - 3];
                            [anInvocation getArgument:&delegate atIndex:count - 2];
                            [anInvocation getArgument:&errorCallback atIndex:count - 1];
                            count -= 3;
                        }
                        else if ([selnames[namecount - 1] isEqual: @"error"] ||
                                 [selnames[namecount - 1] isEqual: @"errorCallback"] ||
                                 [selnames[namecount - 1] isEqual: @"errorHandler"]) {
                            [anInvocation getArgument:&errorCallback atIndex:count - 1];
                            count--;
                        }
                        else {
                            [anInvocation getArgument:&callback atIndex:count - 1];
                            count--;
                        }
                    }
                    else if ([selnames[namecount - 1] isEqual: @"error"] ||
                             [selnames[namecount - 1] isEqual: @"errorCallback"] ||
                             [selnames[namecount - 1] isEqual: @"errorHandler"]) {
                        [anInvocation getArgument:&errorCallback atIndex:count - 1];
                        count--;
                    }
                    else {
                        [anInvocation getArgument:&callback atIndex:count - 1];
                        count--;
                    }
                }
                else if ([selnames[namecount - 1] isEqual: @"error"] ||
                         [selnames[namecount - 1] isEqual: @"errorCallback"] ||
                         [selnames[namecount - 1] isEqual: @"errorHandler"]) {
                    [anInvocation getArgument:&errorCallback atIndex:count - 1];
                    count--;
                }
                else {
                    [anInvocation getArgument:&callback atIndex:count - 1];
                    count--;
                }
            }
            else if (type[0] == _C_ID && type[1] == _C_UNDEF) {
                if (count > 3) {
                    type = [methodSignature getArgumentTypeAtIndex:count - 2];
                    if (type[0] == _C_PTR && type[1] == _C_UNDEF) {
                        [anInvocation getArgument:&callback atIndex:count - 2];
                        [anInvocation getArgument:&errorBlock atIndex:count - 1];
                        count -= 2;
                    }
                    else if (type[0] == _C_ID && type[1] == _C_UNDEF) {
                        [anInvocation getArgument:&block atIndex:count - 2];
                        [anInvocation getArgument:&errorBlock atIndex:count - 1];
                        count -= 2;
                    }
                    else if (type[0] == _C_SEL) {
                        [anInvocation getArgument:&selector atIndex:count - 2];
                        [anInvocation getArgument:&errorBlock atIndex:count - 1];
                        count -= 2;
                    }
                    else if ((type[0] == _C_ID) && (count > 4)) {
                        type = [methodSignature getArgumentTypeAtIndex:count - 3];
                        if (type[0] == _C_SEL) {
                            [anInvocation getArgument:&selector atIndex:count - 3];
                            [anInvocation getArgument:&delegate atIndex:count - 2];
                            [anInvocation getArgument:&errorBlock atIndex:count - 1];
                            count -= 3;
                        }
                        else if ([selnames[namecount - 1] isEqual: @"error"] ||
                                 [selnames[namecount - 1] isEqual: @"errorCallback"] ||
                                 [selnames[namecount - 1] isEqual: @"errorHandler"] ||
                                 [selnames[namecount - 1] isEqual: @"errorBlock"]) {
                            [anInvocation getArgument:&errorBlock atIndex:count - 1];
                            count--;
                        }
                        else {
                            [anInvocation getArgument:&block atIndex:count - 1];
                            count--;
                        }
                    }
                    else if ([selnames[namecount - 1] isEqual: @"error"] ||
                             [selnames[namecount - 1] isEqual: @"errorCallback"] ||
                             [selnames[namecount - 1] isEqual: @"errorHandler"] ||
                             [selnames[namecount - 1] isEqual: @"errorBlock"]) {
                        [anInvocation getArgument:&errorBlock atIndex:count - 1];
                        count--;
                    }
                    else {
                        [anInvocation getArgument:&block atIndex:count - 1];
                        count--;
                    }
                }
                else if ([selnames[namecount - 1] isEqual: @"error"] ||
                         [selnames[namecount - 1] isEqual: @"errorCallback"] ||
                         [selnames[namecount - 1] isEqual: @"errorHandler"] ||
                         [selnames[namecount - 1] isEqual: @"errorBlock"]) {
                    [anInvocation getArgument:&errorBlock atIndex:count - 1];
                    count--;
                }
                else {
                    [anInvocation getArgument:&block atIndex:count - 1];
                    count--;
                }
            }
            else if (type[0] == _C_SEL) {
                if (count > 3) {
                    type = [methodSignature getArgumentTypeAtIndex:count - 2];
                    if (type[0] == _C_PTR && type[1] == _C_UNDEF) {
                        [anInvocation getArgument:&callback atIndex:count - 2];
                        [anInvocation getArgument:&errorSelector atIndex:count - 1];
                        count -= 2;
                    }
                    else if (type[0] == _C_ID && type[1] == _C_UNDEF) {
                        [anInvocation getArgument:&block atIndex:count - 2];
                        [anInvocation getArgument:&errorSelector atIndex:count - 1];
                        count -= 2;
                    }
                    else if (type[0] == _C_SEL) {
                        [anInvocation getArgument:&selector atIndex:count - 2];
                        [anInvocation getArgument:&errorSelector atIndex:count - 1];
                        count -= 2;
                    }
                    else if ((type[0] == _C_ID) && (count > 4)) {
                        type = [methodSignature getArgumentTypeAtIndex:count - 3];
                        if (type[0] == _C_SEL) {
                            [anInvocation getArgument:&selector atIndex:count - 3];
                            [anInvocation getArgument:&delegate atIndex:count - 2];
                            [anInvocation getArgument:&errorSelector atIndex:count - 1];
                            count -= 3;
                        }
                        else if ([selnames[namecount - 1] isEqual: @"error"] ||
                                 [selnames[namecount - 1] isEqual: @"errorCallback"] ||
                                 [selnames[namecount - 1] isEqual: @"errorHandler"] ||
                                 [selnames[namecount - 1] isEqual: @"errorSelector"]) {
                            [anInvocation getArgument:&errorSelector atIndex:count - 1];
                            count--;
                        }
                        else {
                            [anInvocation getArgument:&selector atIndex:count - 1];
                            count--;
                        }
                    }
                    else if ([selnames[namecount - 1] isEqual: @"error"] ||
                             [selnames[namecount - 1] isEqual: @"errorCallback"] ||
                             [selnames[namecount - 1] isEqual: @"errorHandler"] ||
                             [selnames[namecount - 1] isEqual: @"errorSelector"]) {
                        [anInvocation getArgument:&errorSelector atIndex:count - 1];
                        count--;
                    }
                    else {
                        [anInvocation getArgument:&selector atIndex:count - 1];
                        count--;
                    }
                }
                else if ([selnames[namecount - 1] isEqual: @"error"] ||
                         [selnames[namecount - 1] isEqual: @"errorCallback"] ||
                         [selnames[namecount - 1] isEqual: @"errorHandler"] ||
                         [selnames[namecount - 1] isEqual: @"errorSelector"]) {
                    [anInvocation getArgument:&errorSelector atIndex:count - 1];
                    count--;
                }
                else {
                    [anInvocation getArgument:&selector atIndex:count - 1];
                    count--;
                }
            }
            else if ((type[0] == _C_ID) && (count > 3)) {
                type = [methodSignature getArgumentTypeAtIndex:count - 2];
                if (type[0] == _C_SEL) {
                    if (count > 4) {
                        type = [methodSignature getArgumentTypeAtIndex:count - 3];
                        if (type[0] == _C_PTR && type[1] == _C_UNDEF) {
                            [anInvocation getArgument:&callback atIndex:count - 3];
                            [anInvocation getArgument:&errorSelector atIndex:count - 2];
                            [anInvocation getArgument:&delegate atIndex:count - 1];
                            count -= 3;
                        }
                        else if (type[0] == _C_ID && type[1] == _C_UNDEF) {
                            [anInvocation getArgument:&block atIndex:count - 3];
                            [anInvocation getArgument:&errorSelector atIndex:count - 2];
                            [anInvocation getArgument:&delegate atIndex:count - 1];
                            count -= 3;
                        }
                        else if (type[0] == _C_SEL) {
                            [anInvocation getArgument:&selector atIndex:count - 3];
                            [anInvocation getArgument:&errorSelector atIndex:count - 2];
                            [anInvocation getArgument:&delegate atIndex:count - 1];
                            count -= 3;
                        }
                        else if ([selnames[namecount - 2] isEqual: @"error"] ||
                                 [selnames[namecount - 2] isEqual: @"errorCallback"] ||
                                 [selnames[namecount - 2] isEqual: @"errorHandler"] ||
                                 [selnames[namecount - 2] isEqual: @"errorSelector"]) {
                            [anInvocation getArgument:&errorSelector atIndex:count - 2];
                            [anInvocation getArgument:&delegate atIndex:count - 1];
                            count -= 2;
                        }
                        else {
                            [anInvocation getArgument:&selector atIndex:count - 2];
                            [anInvocation getArgument:&delegate atIndex:count - 1];
                            count -= 2;
                        }
                    }
                    else if ([selnames[namecount - 2] isEqual: @"error"] ||
                             [selnames[namecount - 2] isEqual: @"errorCallback"] ||
                             [selnames[namecount - 2] isEqual: @"errorHandler"] ||
                             [selnames[namecount - 2] isEqual: @"errorSelector"]) {
                        [anInvocation getArgument:&errorSelector atIndex:count - 2];
                        [anInvocation getArgument:&delegate atIndex:count - 1];
                        count -= 2;
                    }
                    else {
                        [anInvocation getArgument:&selector atIndex:count - 2];
                        [anInvocation getArgument:&delegate atIndex:count - 1];
                        count -= 2;
                    }
                }
                else {
                    async = _async;
                }
            }
            else {
                async = _async;
            }
        }
        else {
            async = _async;
        }
    }
    BOOL byref = NO;
    NSMutableArray *args = getArguments(count, methodSignature, anInvocation, &byref);
    HproseInvokeSettings *settings = [[HproseInvokeSettings alloc] init];
    settings.byref = byref;
    if (async) {
        if ([methodSignature isOneway]) {
            settings.oneway = YES;
        }
        settings.async = YES;
        settings.callback = callback;
        settings.block = block;
        settings.selector = selector;
        settings.errorCallback = errorCallback;
        settings.errorBlock = errorBlock;
        settings.errorSelector = errorSelector;
        settings.delegate = delegate;
        [_client invoke:name withArgs:args settings:settings];
    }
    else {
        type = [methodSignature methodReturnType];
        char t = type[0];
        switch (t) {
            case 'r':
            case 'n':
            case 'N':
            case 'o':
            case 'O':
            case 'R':
            case 'V':
                if (t == 'V' && type[1] == _C_ID) {
                    settings.resultClass = [Promise class];
                }
                t = type[1];
                break;
        }
        if (t == _C_ID) {
            if (strlen(type) > 3) {
                NSString *className = [@(type)
                                       substringWithRange:
                                       NSMakeRange(2, strlen(type) - 3)];
                settings.resultClass = objc_getClass([className UTF8String]);
            }
        }
        settings.resultType = t;
        id result = [_client invoke:name
                           withArgs:args
                           settings:settings];
        if (byref) {
            setArguments(count, methodSignature, anInvocation, args);
        }
        if ([result isKindOfClass:[NSException class]]) {
            @throw result;
        }
        setReturnValue(t, result, anInvocation);
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    const char *types = protocol_getMethodDescription(_protocol, aSelector, YES, YES).types;
    return [NSMethodSignature signatureWithObjCTypes:types];
}

@end
