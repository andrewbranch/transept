#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "UIDevice+Hardware.h"

@implementation UIDevice(Hardware)

- (NSString *) platform{
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    return platform;
}

- (BOOL)hasRetinaDisplay {
    NSString *platform = [self platform];
    BOOL ret = YES;
    if ([platform isEqualToString:@"iPhone1,1"]) {
        ret = NO;
    }
    else
        if ([platform isEqualToString:@"iPhone1,2"])    ret = NO;
        else
            if ([platform isEqualToString:@"iPhone2,1"])    ret = NO;
            else
                if ([platform isEqualToString:@"iPod1,1"])      ret = NO;
                else
                    if ([platform isEqualToString:@"iPod2,1"])      ret = NO;
                    else
                        if ([platform isEqualToString:@"iPod3,1"])      ret = NO;
    return ret;
}

- (BOOL)hasMultitasking {
    if ([self respondsToSelector:@selector(isMultitaskingSupported)]) {
        return [self isMultitaskingSupported];
    }
    return NO;
}

- (BOOL)hasCamera {
    BOOL ret = NO;
    // check camera availability
    return ret;
}

@end