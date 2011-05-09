#import <Foundation/Foundation.h>
#import "L4LoggerProtocols.h"

@class L4Level, L4Logger;

/**
 * An event to be logged.  This class embodies all of the information needed to generate a log message to an appender.
 */
@interface L4LogEvent : NSObject {
	NSNumber *lineNumber; /**< The line number where the event was generated.*/
	NSString *fileName; /**< The name of the file where the event was generated.*/
	NSString *methodName; /**< The name of the method where the event was generated.*/
	L4Logger *logger; /**< The logger this event should use.*/
	L4Level *level; /**< The level of this event.*/
	id message; /**< The message of this event.*/
	NSString *renderedMessage; /**< The string version of message. */
	NSException *exception; /**< Any exception that was logged as part of this event.*/
	NSDate *timestamp; /**< The timestamp for when this event was generated.*/
    
	char *rawFileName; /**< The raw filename for where the event was generated.*/
	char *rawMethodName; /**< The raw method name for where the event was generated. */
	int   rawLineNumber; /**< The raw line number for where the event was generated. */
}

/**
 * Set up the class for use. To do this we simply get the time the app was started; this value
 * is not exact; it is the time this class is initialized.  Should be fine.
 */
+ (void) initialize;

/**
 * The time the class was initialized; used to determine how long an event 
 * occured into the appliction run.
 * @return the start time of the application.
 */
+ (NSDate *) startTime;

/**
 * Creates a logging event with the given parameters.
 * @param aLogger the logger this event should use.
 * @param aLevel the level of this log event.
 * @param aMessage the message to be logged.
 * @return the new logging event.
 */
+ (L4LogEvent *) logger:(L4Logger *) aLogger
                  level:(L4Level *) aLevel
                message:(id) aMessage;

/**
 * Creates a logging event with the given parameters.
 * @param aLogger the logger this event should use.
 * @param aLevel the level of this log event.
 * @param aMessage the message to be logged.
 * @param e an exception to go along with this log event.
 * @return the new logging event.
 */
+ (L4LogEvent *) logger:(L4Logger *) aLogger
                  level:(L4Level *) aLevel
                message:(id) aMessage
              exception:(NSException *) e;

/**
 * Creates a logging event with the given parameters.
 * @param aLogger the logger this event should use.
 * @param aLevel the level of this log event.
 * @param aLineNumber the line number in the file where this event was generated.
 * @param aFileName the name of the file where this event was generated.
 * @param aMethodName the name of the method where this event was generated.
 * @param aMessage the message to be logged.
 * @param e an exception to go along with this log event.
 * @return the new logging event.
 */
+ (L4LogEvent *) logger:(L4Logger *) aLogger
                  level:(L4Level *) aLevel
             lineNumber:(int) aLineNumber
               fileName:(char *) aFileName
             methodName:(char *) aMethodName
                message:(id) aMessage
              exception:(NSException *) e;

/**
 * Creates a logging event with the given parameters.
 * @param aLogger the logger this event should use.
 * @param aLevel the level of this log event.
 * @param aLineNumber the line number in the file where this event was generated.
 * @param aFileName the name of the file where this event was generated.
 * @param aMethodName the name of the method where this event was generated.
 * @param aMessage the message to be logged.
 * @param e an exception to go along with this log event.
 * @param aDate the time stamp for when this event was generated.
 * @return the new logging event.
 */
- (id) initWithLogger:(L4Logger *) aLogger
				level:(L4Level *) aLevel
		   lineNumber:(int) aLineNumber
			 fileName:(char *) aFileName
		   methodName:(char *) aMethodName
			  message:(id) aMessage
			exception:(NSException *) e
	   eventTimestamp:(NSDate *) aDate;

- (L4Logger *) logger; /**< Accessor for the logger atribute.*/
- (L4Level *) level; /**< Access for the level attrbiute.*/

- (NSNumber *) lineNumber; /**< Accesor for the lineNumber attribute.*/
- (NSString *) fileName; /**< Access for the fileName attribute.*/
- (NSString *) methodName; /**< Accessor for the methodName attribute.*/

- (NSDate *) timestamp; /**< Accessor for the timestamp attribute.*/
- (NSException *) exception; /**< Accessor for the exception attribute.*/
- (long) millisSinceStart; /**< Accessor for the millisSinceStart attribute.*/
- (id) message; /**< Accessor for the message attribute.*/
- (NSString *) renderedMessage; /**< Accessor for the renderedMessage attribute.*/

@end
// For copyright & license, see LICENSE.
