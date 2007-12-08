/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import <Foundation/Foundation.h>
#import "L4LoggerProtocols.h"

@class L4Level, L4Logger;

// ### TODO Add support the L4RendererSupport protocol,
// called from the L4LoggingEvent:renderedMessage method
//
@interface L4LoggerStore : NSObject <L4LoggerRepository> {
	L4Logger *root;
	NSMutableDictionary *repository;
	NSMutableArray *loggers;
	int thresholdInt;
	L4Level *threshold;
	BOOL emittedNoAppenderWarning;
	BOOL emittedNoResourceBundleWarning;
}

/**
 * enables thread locking, no need to lock if not mulit-threaded.
 */
+ (void) taskNowMultiThreaded: (NSNotification *) event;


/**
 * the following are L4LoggerRepository methods
 */
- (id) initWithRoot: (id) rootLogger;

/**
 * Is the repository disabled for a given level? The answer depends
 * on the repository threshold and the <code>level</code>
 * parameter. See also {@link #setThreshold} method.
 */
- (BOOL) isDisabled: (int) aLevel;
- (L4Logger *) exists: (id) loggerNameOrLoggerClass;

- (L4Level *) threshold;
- (void) setThreshold: (L4Level *) aLevel;
- (void) setThresholdByName: (NSString *) aLevelName;

- (L4Logger *) rootLogger;

/**
 * Gets a logger for the class object, if it doesn't exist already
 * it is created by composing the pseudo-fqcn and then calling
 * loggerForName:factory: which does the hard work.
 */
- (L4Logger *) loggerForClass: (Class) aClass;

/** a wrapper for loggerForName:factory: with self as the factory */
- (L4Logger *) loggerForName: (NSString *) aName;

/**
 * returns a logger with name or creates it & inserts it into the
 * repository and hooks up all pointers to pre-existing parents
 * children efficiently (thanks to the Log4J folks algorithm).
 */
- (L4Logger *) loggerForName: (NSString *) aName
					 factory: (id <L4LoggerFactory>) aFactory;

- (NSArray *) currentLoggersArray;
- (NSEnumerator *) currentLoggers;

- (void) emitNoAppenderWarning: (L4Logger *) aLogger;

- (void) resetConfiguration;
- (void) shutdown;

@end


@interface L4LoggerStore (L4LoggerFactoryCategory) <L4LoggerFactory>

- (L4Logger *) makeNewLoggerInstance: (NSString *) aName;

@end
