#import <Foundation/Foundation.h>
#import "L4AppenderProtocols.h"

@class L4Filter, L4Level, L4LoggingEvent, L4Properties;

/**
 * This class acts as a superclass for classes that want to log. It is not intended
 * to be instantiated, but as Objective C does not have the concept of abstract classes,
 * and as protocols can't have implementations, this class simply impliments some
 * standard, generic logging behaviour.
 */
@interface L4AppenderSkeleton : NSObject <L4Appender> {
	NSString *name; /**< The name for this appender.*/
	L4Layout *layout; /**< The layout used by this appender.*/
	L4Level *threshold; /**< The level below which this appender will not log.*/
	L4Filter *headFilter; /**< The firsst filter used by this appender.*/
	L4Filter *tailFilter; /**< The last filter used by this appender.*/
	BOOL closed; /**< Tracks if this appender has been closed.*/
}

/**
 * Initializes an instance from properties.
 * Refer to the L4PropertyConfigurator class for more information about standard configuration properties.
 * @param initProperties the proterties to use.
 */
- (id) initWithProperties:(L4Properties *)initProperties;

/**
 * Appends an event to the log.
 * @param anEvent the event to be appended.
 */
- (void) append:(L4LoggingEvent *)anEvent;

/**
 * Used to determine if a given event would be logged by this appender
 * given this appensers current threshold.
 * @param aLevel the level to be tested.
 * @return YES if this appended would log, NO otherwise.
 */
- (BOOL) isAsSevereAsThreshold:(L4Level *)aLevel;

/**
 * Accessor for the threshold attribute.
 * Tracks the level at wich this appnded will log an event.
 * @return the current threshold.
 */
- (L4Level *) threshold;

/**
 * Mutator for the threshold attribute.
 * Changes the threshold for this appnder to the new value.
 * @param aLevel the new threshold to use.
 */
- (void) setThreshold:(L4Level *)aLevel;

@end

// For copyright & license, see COPYRIGHT.txt.

