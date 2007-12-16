#import <Foundation/Foundation.h>
#import "L4LoggerProtocols.h"

@class L4Logger;

@interface L4LogManager : NSObject {
}

/**
 * Set the class up for use.  In this case, that means setting the root logger.
 */
+ (void) initialize;

/**
 * Accessor for the logger repository.
 * @return the logger repository.
 */
+ (id <L4LoggerRepository>) loggerRepository;

/**
 * Accessor for the root logger.
 * @return the root logger.
 */
+ (L4Logger *) rootLogger;

/**
 * Accesses the logger for the given class.
 * @param aClass the class we want the logger for.
 * @return the logger for the class
 */
+ (L4Logger *) loggerForClass: (Class) aClass;

/**
 * Accesses the logger for the given name.
 * @param aName the name of the logger we want.
 * @return the logger for the class
 */
+ (L4Logger *) loggerForName: (NSString *) aName;

/**
 * Accesses the logger for the given name.
 * @param aName the name of the logger we want.
 * @param aFactory the factory to use to create the logger if it does not yet exist.
 * @return the logger for the class
 */
+ (L4Logger *) loggerForName: (NSString *) aName factory: (id <L4LoggerFactory>) aFactory;

/**
 * The array of loggers.
 * @return the current loggers.
 */
+ (NSArray *) currentLoggers;

/**
 * Shut down logging.
 */
+ (void) shutdown;

/**
 * Reset the logging configuration.
 */
+ (void) resetConfiguration;

@end
// For copyright & license, see COPYRIGHT.txt.
