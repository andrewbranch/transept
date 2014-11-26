#include <sys/types.h>
#include <sys/sysctl.h>

@interface UIDevice(Hardware)

- (NSString *) platform;

- (BOOL)hasRetinaDisplay;

- (BOOL)hasMultitasking;

- (BOOL)hasCamera;

@end