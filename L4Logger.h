#import <Foundation/Foundation.h>
#import "L4AppenderProtocols.h"
#import "L4LoggerProtocols.h"

@class L4AppenderAttachableImpl, L4Level, L4LoggingEvent;

/**
 * LOGGING MACROS: These macros are convience macros that easily
 * allow the capturing of line number, source file, and method
 * name information without interupting the flow of your
 * source code.
 *
 * To use these macros, instead of
 *   [[self log] info: @"Your Log message."];
 * use
 *   L4Info( @"Your Log message." );
 * or
 *   L4InfoWithException( @"Your Log message.", andException);
 *
 * Frankly, I don't know why you would not want to use these macros, but
 * I've left the simple methods in place just in case that's what you want
 * to do or can't use these macros for some reason.
 */

void log4Log(id object, int line, char *file, const char *method,
			  SEL sel, BOOL isAssertion, BOOL assertion, 
			  id exception, id message, ...);


#define L4_PLAIN(type) self, __LINE__, __FILE__, __PRETTY_FUNCTION__, @selector(lineNumber:fileName:methodName:type:), NO, YES, nil
#define L4_EXCEPTION(type, e) self, __LINE__, __FILE__, __PRETTY_FUNCTION__, @selector(lineNumber:fileName:methodName:type:exception:), NO, YES, e
#define L4_ASSERTION(assertion) self, __LINE__, __FILE__, __PRETTY_FUNCTION__, @selector(lineNumber:fileName:methodName:assert:log:), YES, assertion, nil

#define log4Debug(message, ...) if([[self l4Logger] isDebugEnabled]) log4Log(L4_PLAIN(debug), message, ##__VA_ARGS__)
#define log4Info(message, ...)  if([[self l4Logger] isInfoEnabled]) log4Log(L4_PLAIN(info), message, ##__VA_ARGS__)
#define log4Warn(message, ...)  log4Log(L4_PLAIN(warn), message, ##__VA_ARGS__)
#define log4Error(message, ...) log4Log(L4_PLAIN(error), message, ##__VA_ARGS__)
#define log4Fatal(message, ...) log4Log(L4_PLAIN(fatal), message, ##__VA_ARGS__)

#define log4DebugWithException(message, e, ...) if([[self l4Logger] isDebugEnabled]) log4Log(L4_EXCEPTION(debug, e), message, ##__VA_ARGS__)
#define log4InfoWithException(message, e, ...)  if([[self l4Logger] isInfoEnabled]) log4Log(L4_EXCEPTION(info, e), message, ##__VA_ARGS__)
#define log4WarnWithException(message, e, ...)  log4Log(L4_EXCEPTION(warn, e), message, ##__VA_ARGS__)
#define log4ErrorWithException(message, e, ...) log4Log(L4_EXCEPTION(error, e), message, ##__VA_ARGS__)
#define log4FatalWithException(message, e, ...) log4Log(L4_EXCEPTION(fatal, e), message, ##__VA_ARGS__)

#define log4Assert(assertion, message, ...) log4Log(L4_ASSERTION(assertion), message, ##__VA_ARGS__)

@interface L4Logger : NSObject {
	NSString *name; /**< The name of this logger.*/
	L4Level *level; /**< The level of this logger.*/
	L4Logger *parent; /**< The parent of this logger.*/
	id <L4LoggerRepository> repository; /**< Don't know.*/
	BOOL additive; /**< Don't know.*/
	L4AppenderAttachableImpl *aai; /**< What does the actual appending for this logger.*/
}

/**
 * Don't know.
 * @param event
 */
+ (void) taskNowMultiThreaded:(NSNotification *) event;

/**
 * DON'T USE, only for use of log manager
 * @param loggerName the name of this logger.
 */
- (id) initWithName:(NSString *) loggerName;

/**
 * Accessor for additivity.
 * @return if additive is set.
 */
- (BOOL) additivity;

/**
 * Mutator for additivity.
 * @param newAdditivity the new value.
 */
- (void) setAdditivity:(BOOL) newAdditivity;

/**
 * Accessor for the loggers parent.
 * @return parent; root Logger returs nil.
 */
- (L4Logger *) parent;

/**
 * Mutator for this loggers parent.
 * @param theParent the new parent.
 */
- (void) setParent:(L4Logger *) theParent;

/**
 * Accessor for the name attribute.
 * @return the name for this logger.
 */
- (NSString *) name;

/**
 * Acccessor for this loggers repository.
 * @return the repository for this logger.
 */
- (id <L4LoggerRepository>) loggerRepository;

/**
 * The mutator for this loggers repository.
 * @param aRepository the new value.
 */
- (void) setLoggerRepository:(id <L4LoggerRepository>) aRepository;

/**
 * The efective level for this logger.  Events with a level below this will not be logged.
 * @return the minimum level this logger will log.
 */
- (L4Level *) effectiveLevel;

/**
 * Accessor for the level of this logger.
 * @return the level of this logger.
 */
- (L4Level *) level;

/**
 * Mutator for the level of this logger.
 * @param aLevel the new level for this logger.
 */
- (void) setLevel:(L4Level *) aLevel; // nil is ok, because then we just pick up the parent's level

@end

@interface L4Logger (AppenderRelatedMethods)

- (void) callAppenders:(L4LoggingEvent *) event;

- (L4AppenderAttachableImpl *) aai;

- (NSArray *) allAppenders;
- (id <L4Appender>) appenderWithName:(NSString *) aName; // returns appender if in list, otherwise nil

- (void) addAppender:(id <L4Appender>) appender; // SYNCHRONIZED
- (BOOL) isAttached:(id <L4Appender>) appender;

- (void) closeNestedAppenders;

- (void) removeAllAppenders;
- (void) removeAppender:(id <L4Appender>) appender;
- (void) removeAppenderWithName:(NSString *) aName;

@end

@interface L4Logger (CoreLoggingMethods)

/* ALL < DEBUG < INFO < WARN < ERROR < FATAL < OFF */

- (BOOL) isDebugEnabled;
- (BOOL) isInfoEnabled;
- (BOOL) isWarnEnabled;   /* added not in Log4J */
- (BOOL) isErrorEnabled;  /* added not in Log4J */ 
- (BOOL) isFatalEnabled;  /* added not in Log4J */

- (BOOL) isEnabledFor:(L4Level *) aLevel;

- (void) assert:(BOOL) anAssertion
			log:(NSString *) aMessage;

- (void) lineNumber:(int) lineNumber
		   fileName:(char *) fileName
		 methodName:(char *) methodName
			 assert:(BOOL) anAssertion
				log:(NSString *) aMessage;

/* Debug */

- (void) debug:(id) aMessage;

- (void) debug:(id) aMessage
	 exception:(NSException *) e;

- (void) lineNumber:(int) lineNumber
		   fileName:(char *) fileName
		 methodName:(char *) methodName
			  debug:(id) aMessage;

- (void) lineNumber:(int) lineNumber
		   fileName:(char *) fileName
		 methodName:(char *) methodName
			  debug:(id) aMessage
		  exception:(NSException *) e;

/* Info */

- (void) info:(id) aMessage;

- (void) info:(id) aMessage
	exception:(NSException *) e;

- (void) lineNumber:(int) lineNumber
		   fileName:(char *) fileName
		 methodName:(char *) methodName
			   info:(id) aMessage;

- (void) lineNumber:(int) lineNumber
		   fileName:(char *) fileName
		 methodName:(char *) methodName
			   info:(id) aMessage
		  exception:(NSException *) e;

/* Warn */

- (void) warn:(id) aMessage;

- (void) warn:(id) aMessage
	exception:(NSException *) e;

- (void) lineNumber:(int) lineNumber
		   fileName:(char *) fileName
		 methodName:(char *) methodName
			   warn:(id) aMessage;

- (void) lineNumber:(int) lineNumber
		   fileName:(char *) fileName
		 methodName:(char *) methodName
			   warn:(id) aMessage
		  exception:(NSException *) e;

/* Error */

- (void) error:(id) aMessage;

- (void) error:(id) aMessage
	 exception:(NSException *) e;

- (void) lineNumber:(int) lineNumber
		   fileName:(char *) fileName
		 methodName:(char *) methodName
			  error:(id) aMessage;

- (void) lineNumber:(int) lineNumber
		   fileName:(char *) fileName
		 methodName:(char *) methodName
			  error:(id) aMessage
		  exception:(NSException *) e;

/* Fatal */

- (void) fatal:(id) aMessage;

- (void) fatal:(id) aMessage
	 exception:(NSException *) e;

- (void) lineNumber:(int) lineNumber
		   fileName:(char *) fileName
		 methodName:(char *) methodName
			  fatal:(id) aMessage;

- (void) lineNumber:(int) lineNumber
		   fileName:(char *) fileName
		 methodName:(char *) methodName
			  fatal:(id) aMessage
		  exception:(NSException *) e;

/* Legacy primitive logging methods			   */
/* See below, forcedLog:(L4LoggingEvent *) event */

- (void) log:(id) aMessage
	   level:(L4Level *) aLevel;

- (void) log:(id) aMessage
	   level:(L4Level *) aLevel
   exception:(NSException *) e;

- (void) log:(id) aMessage
	   level:(L4Level *) aLevel
   exception:(NSException *) e
  lineNumber:(int) lineNumber
	fileName:(char *) fileName
  methodName:(char *) methodName;

- (void) forcedLog:(id) aMessage
			 level:(L4Level *) aLevel
		 exception:(NSException *) e
		lineNumber:(int) lineNumber
		  fileName:(char *) fileName
		methodName:(char *) methodName;

/* This is the designated logging method that the others invoke. */

- (void) forcedLog:(L4LoggingEvent *) event;

@end


@interface L4Logger (LogManagerCoverMethods)

+ (L4Logger *) rootLogger;

+ (L4Logger *) loggerForClass:(Class) aClass;
+ (L4Logger *) loggerForName:(NSString *) aName;
+ (L4Logger *) loggerForName:(NSString *) aName
					 factory:(id <L4LoggerFactory>) aFactory;

+ (NSArray *) currentLoggers;

@end
// For copyright & license, see COPYRIGHT.txt.
