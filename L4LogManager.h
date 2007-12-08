/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import <Foundation/Foundation.h>
#import "L4LoggerProtocols.h"
@class L4Logger;

#define NO_ERROR 0;
#define GUARD_ERROR_CODE 10001;
#define NO_SELECTOR_ERROR_CODE 10002;

@interface L4LogManager : NSObject {
}

+ (void) initialize;

+ (int) setRepositorySelector: (id <L4RepositorySelector>) aSelector guard: (id) aGuard;

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
