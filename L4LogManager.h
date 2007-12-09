#import <Foundation/Foundation.h>
#import "L4LoggerProtocols.h"

@class L4Logger;

@interface L4LogManager : NSObject {
}

+ (void) initialize;

+ (id <L4LoggerRepository>) loggerRepository;

+ (L4Logger *) rootLogger;
+ (L4Logger *) loggerForClass: (Class) aClass;
+ (L4Logger *) loggerForName: (NSString *) aName;
+ (L4Logger *) loggerForName: (NSString *) aName factory: (id <L4LoggerFactory>) aFactory;

+ (L4Logger *) exists: (id) loggerNameOrLoggerClass;

+ (NSArray *) currentLoggersArray;
+ (NSEnumerator *) currentLoggers;

+ (void) shutdown;
+ (void) resetConfiguration;

@end
// For copyright & license, see COPYRIGHT.txt.
