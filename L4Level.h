/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import <Foundation/Foundation.h>

// ALL < DEBUG < INFO < WARN < ERROR < FATAL < OFF

#define   OFF_INT  99
#define FATAL_INT  50
#define ERROR_INT  40
#define  WARN_INT  30
#define  INFO_INT  20
#define DEBUG_INT  10
#define   ALL_INT  0

@interface L4Level : NSObject {
    int      intValue;
    int      syslogEquivalent;
    NSString *name;
}

+ (void) initialize;

+ (L4Level *) withLevel: (int) aLevel
               withName: (NSString *) aName
       syslogEquivalent: (int) sysLogLevel;

+ (L4Level *) off;
+ (L4Level *) fatal;
+ (L4Level *) error;
+ (L4Level *) warn;
+ (L4Level *) info;
+ (L4Level *) debug;
+ (L4Level *) all;

+ (L4Level *) levelWithName: (NSString *) aLevel;
+ (L4Level *) levelWithName: (NSString *) aLevel
               defaultLevel: (L4Level *) defaultLevel;

+ (L4Level *) levelWithInt: (int) aLevel;
+ (L4Level *) levelWithInt: (int) aLevel
              defaultLevel: (L4Level *) defaultLevel;

- (id) initLevel: (int) aLevel
        withName: (NSString *) aName
syslogEquivalent: (int) sysLogLevel;

- (void) dealloc;
- (NSString *) description;

- (int) intValue;

- (NSString *) stringValue;

- (int) syslogEquivalent;

/* this is Log4J method name */
- (BOOL) isGreaterOrEqual: (L4Level *) aLevel;

/* this is a better name for the method, but I won't */
/* use it for now to stay in synch with Log4J. */
- (BOOL) isEnabledFor: (L4Level *) aLevel;

- (oneway void) release; // prevents releasing of singleton copies

@end
