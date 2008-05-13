/**
 * For copyright & license, see COPYRIGHT.txt.
 */
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


/* ********************************************************************* */
#pragma mark Base macros used for logging from objects
/* ********************************************************************* */
#define L4_PLAIN(type) self, __LINE__, __FILE__, __PRETTY_FUNCTION__, @selector(lineNumber:fileName:methodName:type:), NO, YES, nil
#define L4_EXCEPTION(type, e) self, __LINE__, __FILE__, __PRETTY_FUNCTION__, @selector(lineNumber:fileName:methodName:type:exception:), NO, YES, e
#define L4_ASSERTION(assertion) self, __LINE__, __FILE__, __PRETTY_FUNCTION__, @selector(lineNumber:fileName:methodName:assert:log:), YES, assertion, nil
/* ********************************************************************* */
#pragma mark Base macros used for logging from C functions
/* ********************************************************************* */
#define L4C_PLAIN(type) [L4FunctionLogger instance], __LINE__, __FILE__, __PRETTY_FUNCTION__, @selector(lineNumber:fileName:methodName:type:), NO, YES, nil
#define L4C_EXCEPTION(type, e) [L4FunctionLogger instance], __LINE__, __FILE__, __PRETTY_FUNCTION__, @selector(lineNumber:fileName:methodName:type:exception:), NO, YES, e
#define L4C_ASSERTION(assertion) [L4FunctionLogger instance], __LINE__, __FILE__, __PRETTY_FUNCTION__, @selector(lineNumber:fileName:methodName:assert:log:), YES, assertion, nil

/* ********************************************************************* */
#pragma mark Macros that log from objects
/* ********************************************************************* */
#define log4Debug(message, ...) if([[self l4Logger] isDebugEnabled]) log4Log(L4_PLAIN(debug), message, ##__VA_ARGS__)
#define log4Info(message, ...)  if([[self l4Logger] isInfoEnabled]) log4Log(L4_PLAIN(info), message, ##__VA_ARGS__)
#define log4Warn(message, ...)  log4Log(L4_PLAIN(warn), message, ##__VA_ARGS__)
#define log4Error(message, ...) log4Log(L4_PLAIN(error), message, ##__VA_ARGS__)
#define log4Fatal(message, ...) log4Log(L4_PLAIN(fatal), message, ##__VA_ARGS__)
/* ********************************************************************* */
#pragma mark Macros that log from C functions
/* ********************************************************************* */
#define log4CDebug(message, ...) if([[[L4FunctionLogger instance] l4Logger] isDebugEnabled]) log4Log(L4C_PLAIN(debug), message, ##__VA_ARGS__)
#define log4CInfo(message, ...)  if([[[L4FunctionLogger instance] l4Logger] isInfoEnabled]) log4Log(L4C_PLAIN(info), message, ##__VA_ARGS__)
#define log4CWarn(message, ...)  log4Log(L4C_PLAIN(warn), message, ##__VA_ARGS__)
#define log4CError(message, ...) log4Log(L4C_PLAIN(error), message, ##__VA_ARGS__)
#define log4CFatal(message, ...) log4Log(L4C_PLAIN(fatal), message, ##__VA_ARGS__)


/* ********************************************************************* */
#pragma mark Macros that log with an exception from objects
/* ********************************************************************* */
#define log4DebugWithException(message, e, ...) if([[self l4Logger] isDebugEnabled]) log4Log(L4_EXCEPTION(debug, e), message, ##__VA_ARGS__)
#define log4InfoWithException(message, e, ...)  if([[self l4Logger] isInfoEnabled]) log4Log(L4_EXCEPTION(info, e), message, ##__VA_ARGS__)
#define log4WarnWithException(message, e, ...)  log4Log(L4_EXCEPTION(warn, e), message, ##__VA_ARGS__)
#define log4ErrorWithException(message, e, ...) log4Log(L4_EXCEPTION(error, e), message, ##__VA_ARGS__)
#define log4FatalWithException(message, e, ...) log4Log(L4_EXCEPTION(fatal, e), message, ##__VA_ARGS__)
/* ********************************************************************* */
#pragma mark Macros that log with an exception from C functions
/* ********************************************************************* */
#define log4CDebugWithException(message, e, ...) if([[[L4FunctionLogger instance] l4Logger] isDebugEnabled]) log4Log(L4C_EXCEPTION(debug, e), message, ##__VA_ARGS__)
#define log4CInfoWithException(message, e, ...)  if([[[L4FunctionLogger instance] l4Logger] isInfoEnabled]) log4Log(L4C_EXCEPTION(info, e), message, ##__VA_ARGS__)
#define log4CWarnWithException(message, e, ...)  log4Log(L4C_EXCEPTION(warn, e), message, ##__VA_ARGS__)
#define log4CErrorWithException(message, e, ...) log4Log(L4C_EXCEPTION(error, e), message, ##__VA_ARGS__)
#define log4CFatalWithException(message, e, ...) log4Log(L4C_EXCEPTION(fatal, e), message, ##__VA_ARGS__)

/* ********************************************************************* */
#pragma mark Macro that log when an assertion is false from objects
/* ********************************************************************* */
#define log4Assert(assertion, message, ...) log4Log(L4_ASSERTION(assertion), message, ##__VA_ARGS__)
/* ********************************************************************* */
#pragma mark Macro that log when an assertion is false from C functions
/* ********************************************************************* */
#define log4CAssert(assertion, message, ...) log4Log(L4C_ASSERTION(assertion), message, ##__VA_ARGS__)

/**
 * This is the primary interface into the logging framework. 
 * The functionality of the class is broken down into the following areas:
 *	<dl> 
 *  <dt><b>Base methods</b></dt>
 *	<dd> responsible for setting the level at which messages get logged.</dd>
 *  <dt> <b>AppenderRelatedMethods methods</b></dt>
 *	<dd> responsible for adding, calling, and removing L4Appender instances.</dd>
 *  <dt> <b>CoreLoggingMethods methods </b></dt>
 *	<dd> the methods that do the actual logging.</dd>
 *  <dt> <b>LogManagerCoverMethods methods </b></dt>
 *	<dd> Class methods the handle the chain of L4Logger instances, and find the correct L4Logger
 *		 instance for a given class or logger name.</dd>
 *  </dl>
 */
@interface L4Logger : NSObject {
	NSString *name; /**< The name of this logger.*/
	L4Level *level; /**< The level of this logger.*/
	L4Logger *parent; /**< The parent of this logger.*/
	id <L4LoggerRepository> repository; /**< Don't know.*/
	 /**
	  * Flag for if log messages are additive.  If YES, logging events are set to parent loggers.  
	  * If NO, parents are not called. 
	  */
	BOOL additive;
	L4AppenderAttachableImpl *aai; /**< What does the actual appending for this logger.*/
}

/**
 * Handles when the application using logging becomes multi-threaded.
 * The initialize method fist calls this method, and registers with the default
 * notification center for NSWillBecomeMultiThreadedNotification events.
 *
 * @param event NSWillBecomeMultiThreadedNotification notification.
 */
+ (void) taskNowMultiThreaded:(NSNotification *) event;

/**
 * DON'T USE, only for use of log manager
 * @param loggerName the name of this logger.
 */
- (id) initWithName:(NSString *) loggerName;

/**
 * Accessor for additivity.
 * @return YES if this logger is additive, NO if it is not.
 */
- (BOOL) additivity;

/**
 * Mutator for additivity.
 * @param newAdditivity YES if this logger is to be additive, NO if it is not.
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

/* ********************************************************************* */
#pragma mark AppenderRelatedMethods methods
/* ********************************************************************* */
/**
 * Appends the logging event to every appender attached to this logger. If this logger is additive, the
 * message propagates up the parent chain until all of them have been called, or one is found that is
 * not addative.
 * If no appender could be found to append to, a warning is emited to that effect.
 * @param event the logging event.
 */
- (void) callAppenders:(L4LoggingEvent *) event;

/**
 * Accessor for the appender attached to this logger.
 */
- (L4AppenderAttachableImpl *) aai;

/**
 * Accessor for the appenders attached to this logger. A L4AppenderAttachableImpl can have more than one
 * logger attached to it.
 */
- (NSArray *) allAppenders;

/**
 * Accessor for named appender if in list.
 * @param aName the name of the appender to find.
 * @return if found the appender.  Otherwise, nil.
 */
- (id <L4Appender>) appenderWithName:(NSString *) aName;

/**
 * Adds an appender to those attached to this logger instance.
 * @param appender the L4Appender to add.  If nil, a new L4AppenderAttachableImpl is created and added.
 */
- (void) addAppender:(id <L4Appender>) appender;
/**
 * Determines if a given L4Appender is attached to this logger instance.
 * @param appender the L4Appender of interest.
 * @return YES if it is attached, NO if it is not.
 */
- (BOOL) isAttached:(id <L4Appender>) appender;

/**
 * Closes all appenders attached to this logging instance.
 */
- (void) closeNestedAppenders;

/**
 * Removes all appenders attached to this logging instance.
 */
- (void) removeAllAppenders;

/**
 * Removes the given appender from those attached to this logging instance.
 * @param appender to be removed.
 */
- (void) removeAppender:(id <L4Appender>) appender;

/**
 * Removes the appender with the given name from those attached to this logging instance.
 * @param aName the name of the appender to be removed.
 */
- (void) removeAppenderWithName:(NSString *) aName;

/* ********************************************************************* */
#pragma mark CoreLoggingMethods methods
/* ********************************************************************* */
/* ALL < DEBUG < INFO < WARN < ERROR < FATAL < OFF */

/**
 * Determines if a debug message should be logged.
 * @return YES if debug messages are enabled, NO if they are not.
 */
- (BOOL) isDebugEnabled;

/**
 * Determines if an info message should be logged.
 * @return YES if info messages are enabled, NO if they are not.
 */
- (BOOL) isInfoEnabled;

/**
 * Determines if a warn message should be logged.
 * @return YES if warn messages are enabled, NO if they are not.
 */
- (BOOL) isWarnEnabled;

/**
 * Determines if an error message should be logged.
 * @return YES if error messages are enabled, NO if they are not.
 */
- (BOOL) isErrorEnabled;

/**
 * Determines if a fatel message should be logged.
 * @return YES if fatel messages are enabled, NO if they are not.
 */
- (BOOL) isFatalEnabled;

/**
 * Determines if aLevel should be logged.
 * @param aLevel the L4Level to be checked.
 * @return YES if logging is enabled for the level, NO if it is not.
 */
- (BOOL) isEnabledFor:(L4Level *) aLevel;

/**
 * Logs an error message in an NSAssert is false.
 * <b>This is considered a framework method, and probably should not be called from outside the framework.</b>
 *
 * @param anAssertion the NSAssert to be tested.
 * @param aMessage the message to be logged if the assertion is false.
 */
- (void) assert:(BOOL) anAssertion
			log:(NSString *) aMessage;

/**
 * Logs an error message in an NSAssert is false.
 * <b>This is considered a framework method, and probably should not be called from outside the framework.</b>
 *
 * @param lineNumber the line number in the source file where the assertion is.
 * @param fileName the name of the source file containing the assertion.
 * @param methodName the name of the method containing the assertion.
 * @param anAssertion the NSAssert to be tested.
 * @param aMessage the message to be logged if the assertian is false.
 */
- (void) lineNumber:(int) lineNumber
		   fileName:(char *) fileName
		 methodName:(char *) methodName
			 assert:(BOOL) anAssertion
				log:(NSString *) aMessage;

/**
 * Logs a message with a level of debug.
 * <b>This is considered a framework method, and probably should not be called from outside the framework.</b>
 *
 * @param aMessage the message to be logged.
 */
- (void) debug:(id) aMessage;

/**
 * Logs a message with an excpetion at a level of debug.
 * <b>This is considered a framework method, and probably should not be called from outside the framework.</b>
 *
 * @param aMessage the message to be logged.
 * @param e the exception to be logged.
 */
- (void) debug:(id) aMessage
	 exception:(NSException *) e;

/**
 * Logs a message with a level of debug.
 * <b>This is considered a framework method, and probably should not be called from outside the framework.</b>
 *
 * @param lineNumber the line number in the source file where the log statement is.
 * @param fileName the name of the source file containing the log statement.
 * @param methodName the name of the method containing the log statement.
 * @param aMessage the message to be logged.
 */
- (void) lineNumber:(int) lineNumber
		   fileName:(char *) fileName
		 methodName:(char *) methodName
			  debug:(id) aMessage;

/**
 * Logs a message with an excpetion at a level of debug.
 * <b>This is considered a framework method, and probably should not be called from outside the framework.</b>
 *
 * @param lineNumber the line number in the source file where the log statement is.
 * @param fileName the name of the source file containing the log statement.
 * @param methodName the name of the method containing the log statement.
 * @param aMessage the message to be logged.
 * @param e the exception to be logged.
 */
- (void) lineNumber:(int) lineNumber
		   fileName:(char *) fileName
		 methodName:(char *) methodName
			  debug:(id) aMessage
		  exception:(NSException *) e;

/**
 * Logs a message with a level of info.
 * <b>This is considered a framework method, and probably should not be called from outside the framework.</b>
 *
 * @param aMessage the message to be logged.
 */
- (void) info:(id) aMessage;

/**
 * Logs a message with an excpetion at a level of info.
 * <b>This is considered a framework method, and probably should not be called from outside the framework.</b>
 *
 * @param aMessage the message to be logged.
 * @param e the exception to be logged.
 */
- (void) info:(id) aMessage
	exception:(NSException *) e;

/**
 * Logs a message with a level of info.
 * <b>This is considered a framework method, and probably should not be called from outside the framework.</b>
 *
 * @param lineNumber the line number in the source file where the log statement is.
 * @param fileName the name of the source file containing the log statement.
 * @param methodName the name of the method containing the log statement.
 * @param aMessage the message to be logged.
 */
- (void) lineNumber:(int) lineNumber
		   fileName:(char *) fileName
		 methodName:(char *) methodName
			   info:(id) aMessage;

/**
 * Logs a message with an excpetion at a level of info.
 * <b>This is considered a framework method, and probably should not be called from outside the framework.</b>
 *
 * @param lineNumber the line number in the source file where the log statement is.
 * @param fileName the name of the source file containing the log statement.
 * @param methodName the name of the method containing the log statement.
 * @param aMessage the message to be logged.
 * @param e the exception to be logged.
 */
- (void) lineNumber:(int) lineNumber
		   fileName:(char *) fileName
		 methodName:(char *) methodName
			   info:(id) aMessage
		  exception:(NSException *) e;

/**
 * Logs a message with a level of warn.
 * <b>This is considered a framework method, and probably should not be called from outside the framework.</b>
 *
 * @param aMessage the message to be logged.
 */
- (void) warn:(id) aMessage;

/**
 * Logs a message with an excpetion at a level of warn.
 * <b>This is considered a framework method, and probably should not be called from outside the framework.</b>
 *
 * @param aMessage the message to be logged.
 * @param e the exception to be logged.
 */
- (void) warn:(id) aMessage
	exception:(NSException *) e;

/**
 * Logs a message with a level of warn.
 * <b>This is considered a framework method, and probably should not be called from outside the framework.</b>
 *
 * @param lineNumber the line number in the source file where the log statement is.
 * @param fileName the name of the source file containing the log statement.
 * @param methodName the name of the method containing the log statement.
 * @param aMessage the message to be logged.
 */
- (void) lineNumber:(int) lineNumber
		   fileName:(char *) fileName
		 methodName:(char *) methodName
			   warn:(id) aMessage;

/**
 * Logs a message with an excpetion at a level of warn.
 * <b>This is considered a framework method, and probably should not be called from outside the framework.</b>
 *
 * @param lineNumber the line number in the source file where the log statement is.
 * @param fileName the name of the source file containing the log statement.
 * @param methodName the name of the method containing the log statement.
 * @param aMessage the message to be logged.
 * @param e the exception to be logged.
 */
- (void) lineNumber:(int) lineNumber
		   fileName:(char *) fileName
		 methodName:(char *) methodName
			   warn:(id) aMessage
		  exception:(NSException *) e;

/**
 * Logs a message with a level of error.
 * <b>This is considered a framework method, and probably should not be called from outside the framework.</b>
 *
 * @param aMessage the message to be logged.
 */
- (void) error:(id) aMessage;

/**
 * Logs a message with an excpetion at a level of error.
 * <b>This is considered a framework method, and probably should not be called from outside the framework.</b>
 *
 * @param aMessage the message to be logged.
 * @param e the exception to be logged.
 */
- (void) error:(id) aMessage
	 exception:(NSException *) e;

/**
 * Logs a message with a level of error.
 * <b>This is considered a framework method, and probably should not be called from outside the framework.</b>
 *
 * @param lineNumber the line number in the source file where the log statement is.
 * @param fileName the name of the source file containing the log statement.
 * @param methodName the name of the method containing the log statement.
 * @param aMessage the message to be logged.
 */
- (void) lineNumber:(int) lineNumber
		   fileName:(char *) fileName
		 methodName:(char *) methodName
			  error:(id) aMessage;

/**
 * Logs a message with an excpetion at a level of error.
 * <b>This is considered a framework method, and probably should not be called from outside the framework.</b>
 *
 * @param lineNumber the line number in the source file where the log statement is.
 * @param fileName the name of the source file containing the log statement.
 * @param methodName the name of the method containing the log statement.
 * @param aMessage the message to be logged.
 * @param e the exception to be logged.
 */
- (void) lineNumber:(int) lineNumber
		   fileName:(char *) fileName
		 methodName:(char *) methodName
			  error:(id) aMessage
		  exception:(NSException *) e;

/**
 * Logs a message with a level of fatal.
 * <b>This is considered a framework method, and probably should not be called from outside the framework.</b>
 *
 * @param aMessage the message to be logged.
 */
- (void) fatal:(id) aMessage;

/**
 * Logs a message with an excpetion at a level of fatal.
 * <b>This is considered a framework method, and probably should not be called from outside the framework.</b>
 *
 * @param aMessage the message to be logged.
 * @param e the exception to be logged.
 */
- (void) fatal:(id) aMessage
	 exception:(NSException *) e;

/**
 * Logs a message with a level of fatal.
 * <b>This is considered a framework method, and probably should not be called from outside the framework.</b>
 *
 * @param lineNumber the line number in the source file where the log statement is.
 * @param fileName the name of the source file containing the log statement.
 * @param methodName the name of the method containing the log statement.
 * @param aMessage the message to be logged.
 */
- (void) lineNumber:(int) lineNumber
		   fileName:(char *) fileName
		 methodName:(char *) methodName
			  fatal:(id) aMessage;

/**
 * Logs a message with an excpetion at a level of fatal.
 * <b>This is considered a framework method, and probably should not be called from outside the framework.</b>
 *
 * @param lineNumber the line number in the source file where the log statement is.
 * @param fileName the name of the source file containing the log statement.
 * @param methodName the name of the method containing the log statement.
 * @param aMessage the message to be logged.
 * @param e the exception to be logged.
 */
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
/**
 * Forwards the L4LoggingEvent to all attached appenders; the other methods in this class create
 * an L4LoggingEvent and call this method.
 * <b>This is considered a framework method, and probably should not be called from outside the framework.</b>
 *
 * @param event the event to be logged.
 */
- (void) forcedLog:(L4LoggingEvent *) event;


/* ********************************************************************* */
#pragma mark LogManagerCoverMethods methods
/* ********************************************************************* */
+ (L4Logger *) rootLogger;

+ (L4Logger *) loggerForClass:(Class) aClass;
+ (L4Logger *) loggerForName:(NSString *) aName;
+ (L4Logger *) loggerForName:(NSString *) aName
					 factory:(id <L4LoggerFactory>) aFactory;

+ (NSArray *) currentLoggers;
@end

/**
 * This class is a dummy class; its only purpose is to facilitate logging from
 * methods.  It serves as the 'self' argument.  Log level for methods can be 
 * adjusted with this, but keep in mind that it applies to all function logging.
 */
@interface L4FunctionLogger : NSObject
{
	L4FunctionLogger *instance; /**< the singleon instance of this class. */
}
/**
 * Accessor for the singleton instance.
 */
+ (L4FunctionLogger *)instance;
@end
