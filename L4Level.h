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
	int	  intValue; /**< The int value of this log level.*/
	int	  syslogEquivalent; /**< The int equivelent for syslog.*/
	NSString *name; /**< The name of this level.*/
}

/**
 * Sets up default instanes of leels.
 */
+ (void) initialize;

/**
 * Creates and returns an instance with the provided values.
 * @param aLevel the level for this instance.
 * @param aName the neame for this level.
 * @param sysLogLevel the system log level for this instance.
 * @return the new instance.
 */
+ (L4Level *) withLevel:(int) aLevel withName:(NSString *) aName syslogEquivalent:(int) sysLogLevel;

/**
 * Accessor for the default instance with a level of off.
 * @return the off instance.
 */
+ (L4Level *) off;
/**
 * Accessor for the default instance with a level of fatal.
 * @return the fatal instance.
 */
+ (L4Level *) fatal;
/**
 * Accessor for the default instance with a level of error.
 * @return the error instance.
 */
+ (L4Level *) error;
/**
 * Accessor for the default instance with a level of warn.
 * @return the warn instance.
 */
+ (L4Level *) warn;
/**
 * Accessor for the default instance with a level of info.
 * @return the info instance.
 */
+ (L4Level *) info;
/**
 * Accessor for the default instance with a level of debug.
 * @return debug off instance.
 */
+ (L4Level *) debug;
/**
 * Accessor for the default instance with a level of all.
 * @return the all instance.
 */
+ (L4Level *) all;

+ (L4Level *) levelWithName: (NSString *) aLevel;
+ (L4Level *) levelWithName: (NSString *) aLevel defaultLevel: (L4Level *) defaultLevel;

+ (L4Level *) levelWithInt: (int) aLevel;
+ (L4Level *) levelWithInt: (int) aLevel defaultLevel: (L4Level *) defaultLevel;

- (id) initLevel: (int) aLevel withName: (NSString *) aName syslogEquivalent: (int) sysLogLevel;

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
// For copyright & license, see COPYRIGHT.txt.
