#import "ZFPlayerLogManager.h"

static BOOL kLogEnable = NO;

@implementation ZFPlayerLogManager

+ (void)setLogEnable:(BOOL)enable {
    kLogEnable = enable;
}

+ (BOOL)getLogEnable {
    return kLogEnable;
}

// 各个类库, 应该主动提供给外界, 自己当前的版本号. 
+ (NSString *)version {
    return @"4.0.2";
}

+ (void)logWithFunction:(const char *)function lineNumber:(int)lineNumber formatString:(NSString *)formatString {
    if ([self getLogEnable]) {
        NSLog(@"%s[%d]%@", function, lineNumber, formatString);
    }
}

@end
