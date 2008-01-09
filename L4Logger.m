/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import "L4Logger.h"
#import "L4AppenderAttachableImpl.h"
#import "L4Level.h"
#import "L4LoggingEvent.h"
#import "L4LogLog.h"
#import "L4LogManager.h"
#import "NSObject+Log4Cocoa.h"

static int   NO_LINE_NUMBER = -1;
static char *NO_FILE_NAME   = "";
static char *NO_METHOD_NAME = "";

static L4Level *_fatal = nil;
static L4Level *_error = nil;
static L4Level *_warn  = nil;
static L4Level *_info  = nil;
static L4Level *_debug = nil;
static NSLock *_loggerLock = nil;

id objc_msgSend(id self, SEL op, ...);

void log4Log(id object, int line, char *file, const char *method, SEL sel, BOOL isAssertion, BOOL assertion,  id exception, id message, ...)
{
	NSString *combinedMessage;
	if ( [message isKindOfClass:[NSString class]] ) {
		va_list args;
		va_start(args, message);
		combinedMessage = [[NSString alloc] initWithFormat:message arguments:args];
		va_end(args);
	} else {
		combinedMessage = [message retain];
	}

	if ( isAssertion ) {
		objc_msgSend([object l4Logger], sel, line, file, method, assertion, combinedMessage);
	} else {
		objc_msgSend([object l4Logger], sel, line, file, method, combinedMessage, exception);
	}
	
	[combinedMessage release];
}

@implementation L4Logger

+ (void) initialize
{
	[L4LoggingEvent startTime];

	_debug = [L4Level debug];
	_info  = [L4Level info];
	_warn  = [L4Level warn];
	_error = [L4Level error];
	_fatal = [L4Level fatal];

	if ([NSThread isMultiThreaded]) {
		[self taskNowMultiThreaded: nil];
	} else {
		[[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(taskNowMultiThreaded:)
													 name: NSWillBecomeMultiThreadedNotification
												   object: nil];
	}
}

+ (void) taskNowMultiThreaded: (NSNotification *) event 
{
	if (!_loggerLock) {
		_loggerLock = [[NSLock alloc] init];
		// we can add other things here.
	}
}



- init
{
	return nil; // never use this constructor
}

- (id) initWithName: (NSString *) aName
{
	self = [super init];
	if( self != nil ) {
		name = [aName retain];
		additive = YES;
	}
	
	return self;
}

- (void) dealloc
{
	[repository release];
	[parent release];
	[name release];
	[aai release];
	[super dealloc];
}

- (BOOL) additivity
{
	return additive;
}

- (void) setAdditivity: (BOOL) newAdditivity
{
	additive = newAdditivity;
}

- (L4Logger *) parent
{
	return parent;
}

- (void) setParent: (L4Logger *) theParent
{
	[parent autorelease];
	parent = [theParent retain];
}

- (NSString *) name
{
	return name;
}

- (id <L4LoggerRepository>) loggerRepository
{
	return repository;
}

- (void) setLoggerRepository: (id <L4LoggerRepository>) aRepository
{
	if( repository != aRepository ) {
		[repository autorelease];
		repository = [aRepository retain];
	}
}

// NO METHOD CALLING - PERFORMANCE TWEAKED METHOD
- (L4Level *) effectiveLevel
{
	L4Level *effectiveLevel;
	L4Logger *aLogger = self;
	while (aLogger != nil) {
		if((aLogger->level) != nil) {
			effectiveLevel = aLogger->level;
			break;
		}
		aLogger = aLogger->parent;
	}
	
	if (effectiveLevel == nil) {
		[L4LogLog error: @"Root Logger Not Found!"];
	}
	return effectiveLevel;
}

- (L4Level *) level
{
	return level;
}

/* nil is ok, because then we just pick up the parent's level */
- (void) setLevel: (L4Level *) aLevel
{
	if( level != aLevel ) {
		[level autorelease];
		level = [aLevel retain];
	}
}

/* ********************************************************************* */
#pragma mark LogManagerCoverMethods methods
/* ********************************************************************* */
+ (L4Logger *) rootLogger
{
	return [L4LogManager rootLogger];
}

+ (L4Logger *) loggerForClass: (Class) aClass
{
	return [L4LogManager loggerForClass: aClass];
}

+ (L4Logger *) loggerForName: (NSString *) loggerName
{
	return [L4LogManager loggerForName: loggerName];
}

+ (L4Logger *) loggerForName: (NSString *) loggerName factory: (id <L4LoggerFactory>) aFactory
{
	return [L4LogManager loggerForName: loggerName factory: aFactory];
}

+ (NSArray *) currentLoggers
{
	return [L4LogManager currentLoggers];
}

/* ********************************************************************* */
#pragma mark AppenderRelatedMethods methods
/* ********************************************************************* */

- (void) callAppenders:(L4LoggingEvent *) event
{
	L4Logger *aLogger = self;
	int writes = 0;
	
	//	[_loggerLock lock];  // ### LOCKING
	
	for( aLogger = self; aLogger != nil; aLogger = [aLogger parent] ) {
		if( [aLogger aai] != nil ) {
			writes += [[aLogger aai] appendLoopOnAppenders: event];
		}
		if( ![aLogger additivity] ) {
			break;
		}
	}
	
	//	[_loggerLock unlock];  // ### LOCKING
	
	if( writes == 0 ) {
		[repository emitNoAppenderWarning: self];
	}
}

- (L4AppenderAttachableImpl *) aai
{
	return aai;
}

- (NSArray *) allAppenders
{
	return [aai allAppenders];
}

- (id <L4Appender>) appenderWithName: (NSString *) aName
{
	return [aai appenderWithName: aName];
}

- (void) addAppender: (id <L4Appender>) appender
{
	//	[_loggerLock lock];  // ### LOCKING
	if( aai == nil ) {
		aai = [[L4AppenderAttachableImpl alloc] init];
	}
	
	[aai addAppender: appender];
	//	[_loggerLock unlock];  // ### LOCKING
}

- (BOOL) isAttached: (id <L4Appender>) appender
{
	if((appender == nil) || (aai == nil)) {
		return NO;
	}
	return [aai isAttached: appender];
}

- (void) closeNestedAppenders
{
	NSEnumerator *enumerator = [[self allAppenders] objectEnumerator];
	id <L4Appender> anObject;
	
	while ((anObject = (id <L4Appender>)[enumerator nextObject])) {
		[anObject close];
	}
}

- (void) removeAllAppenders
{
	//	[_loggerLock lock];  // ### LOCKING
	[aai removeAllAppenders];
	[aai release];
	aai = nil;
	//	[_loggerLock unlock];  // ### LOCKING
}

- (void) removeAppender: (id <L4Appender>) appender
{
	//	[_loggerLock lock];  // ### LOCKING
	[aai removeAppender: appender];
	//	[_loggerLock unlock];  // ### LOCKING
}

- (void) removeAppenderWithName: (NSString *) aName
{
	//	[_loggerLock lock];  // ### LOCKING
	[aai removeAppenderWithName: aName];
	//	[_loggerLock unlock];  // ### LOCKING
}

/* ********************************************************************* */
#pragma mark CoreLoggingMethods methods
/* ********************************************************************* */

// ALL < DEBUG < INFO < WARN < ERROR < FATAL < OFF

- (BOOL) isDebugEnabled { return [self isEnabledFor: _debug]; }
- (BOOL) isInfoEnabled  { return [self isEnabledFor: _info]; }

// I added these convience methods, they're not in Log4J
- (BOOL) isWarnEnabled  { return [self isEnabledFor: _warn]; }
- (BOOL) isErrorEnabled { return [self isEnabledFor: _error]; }
- (BOOL) isFatalEnabled { return [self isEnabledFor: _fatal]; }

- (BOOL) isEnabledFor: (L4Level *) aLevel
{
	if([repository isDisabled: [aLevel intValue]]) {
		return NO;
	}
	return [aLevel isGreaterOrEqual: [self effectiveLevel]];
}

- (void) assert: (BOOL) anAssertion log: (NSString *) aMessage
{
	if( !anAssertion ) {
		[self error: aMessage];
	}
}

- (void) lineNumber: (int) lineNumber
		   fileName: (char *) fileName
		 methodName: (char *) methodName
			 assert: (BOOL) anAssertion
				log: (NSString *) aMessage
{
	if( !anAssertion ) {
		[self lineNumber: lineNumber fileName: fileName methodName: methodName error: aMessage exception: nil];
	}
}

/* debug */

- (void) debug: (id) aMessage
{
	[self lineNumber: NO_LINE_NUMBER fileName: NO_FILE_NAME methodName: NO_METHOD_NAME debug: aMessage exception: nil];
}

- (void) debug: (id) aMessage exception: (NSException *) e
{
	[self lineNumber: NO_LINE_NUMBER fileName: NO_FILE_NAME methodName: NO_METHOD_NAME debug: aMessage exception: e];
}

- (void) lineNumber: (int) lineNumber
		   fileName: (char *) fileName
		 methodName: (char *) methodName
			  debug: (id) aMessage
{
	[self lineNumber: lineNumber fileName: fileName methodName: methodName debug: aMessage exception: nil];
}

- (void) lineNumber: (int) lineNumber
		   fileName: (char *) fileName
		 methodName: (char *) methodName
			  debug: (id) aMessage
		  exception: (NSException *) e
{
	if([repository isDisabled: [_debug intValue]]) {
		return;
	}
	
	// Check this particular loggers level
	//
	if([_debug isGreaterOrEqual: [self effectiveLevel]]) {
		[self forcedLog: [L4LoggingEvent logger: self
										  level: _debug
									 lineNumber: lineNumber
									   fileName: fileName
									 methodName: methodName
										message: aMessage
									  exception: e]];
	}
}

/* info */

- (void) info: (id) aMessage
{
	[self lineNumber: NO_LINE_NUMBER fileName: NO_FILE_NAME methodName: NO_METHOD_NAME info: aMessage exception: nil];
}

- (void) info: (id) aMessage exception: (NSException *) e
{
	[self lineNumber: NO_LINE_NUMBER fileName: NO_FILE_NAME methodName: NO_METHOD_NAME info: aMessage exception: e];
}

- (void) lineNumber: (int) lineNumber
		   fileName: (char *) fileName
		 methodName: (char *) methodName
			   info: (id) aMessage
{
	[self lineNumber: lineNumber fileName: fileName methodName: methodName info: aMessage exception: nil];
}

- (void) lineNumber: (int) lineNumber
		   fileName: (char *) fileName
		 methodName: (char *) methodName
			   info: (id) aMessage
		  exception: (NSException *) e
{
	if([repository isDisabled: [_info intValue]]) {
		return;
	}
	
	if([_info isGreaterOrEqual: [self effectiveLevel]]) {
		[self forcedLog: [L4LoggingEvent logger: self
										  level: _info
									 lineNumber: lineNumber
									   fileName: fileName
									 methodName: methodName
										message: aMessage
									  exception: e]];
	}
}

/* warn */

- (void) warn: (id) aMessage
{
	[self lineNumber: NO_LINE_NUMBER fileName: NO_FILE_NAME methodName: NO_METHOD_NAME warn: aMessage exception: nil];
}

- (void) warn: (id) aMessage exception: (NSException *) e
{
	[self lineNumber: NO_LINE_NUMBER fileName: NO_FILE_NAME methodName: NO_METHOD_NAME warn: aMessage exception: e];
}

- (void) lineNumber: (int) lineNumber
		   fileName: (char *) fileName
		 methodName: (char *) methodName
			   warn: (id) aMessage
{
	[self lineNumber: lineNumber fileName: fileName methodName: methodName warn: aMessage exception: nil];
}

- (void) lineNumber: (int) lineNumber
		   fileName: (char *) fileName
		 methodName: (char *) methodName
			   warn: (id) aMessage
		  exception: (NSException *) e
{
	if([repository isDisabled: [_warn intValue]]) {
		return;
	}
	
	if([_warn isGreaterOrEqual: [self effectiveLevel]]) {
		[self forcedLog: [L4LoggingEvent logger: self
										  level: _warn
									 lineNumber: lineNumber
									   fileName: fileName
									 methodName: methodName
										message: aMessage
									  exception: e]];
	}
}

/* error */

- (void) error: (id) aMessage
{
	[self lineNumber: NO_LINE_NUMBER fileName: NO_FILE_NAME methodName: NO_METHOD_NAME error: aMessage exception: nil];
}

- (void) error: (id) aMessage exception: (NSException *) e
{
	[self lineNumber: NO_LINE_NUMBER fileName: NO_FILE_NAME methodName: NO_METHOD_NAME error: aMessage exception: e];
}

- (void) lineNumber: (int) lineNumber
		   fileName: (char *) fileName
		 methodName: (char *) methodName
			  error: (id) aMessage
{
	[self lineNumber: lineNumber fileName: fileName methodName: methodName error: aMessage exception: nil];
}

- (void) lineNumber: (int) lineNumber
		   fileName: (char *) fileName
		 methodName: (char *) methodName
			  error: (id) aMessage
		  exception: (NSException *) e
{
	if([repository isDisabled: [_error intValue]]) {
		return;
	}
	
	if([_error isGreaterOrEqual: [self effectiveLevel]]) {
		[self forcedLog: [L4LoggingEvent logger: self
										  level: _error
									 lineNumber: lineNumber
									   fileName: fileName
									 methodName: methodName
										message: aMessage
									  exception: e]];
	}
}

/* fatal */

- (void) fatal: (id) aMessage
{
	[self lineNumber: NO_LINE_NUMBER fileName: NO_FILE_NAME methodName: NO_METHOD_NAME fatal: aMessage exception: nil];
}

- (void) fatal: (id) aMessage exception: (NSException *) e
{
	[self lineNumber: NO_LINE_NUMBER fileName: NO_FILE_NAME methodName: NO_METHOD_NAME fatal: aMessage exception: e];
}

- (void) lineNumber: (int) lineNumber
		   fileName: (char *) fileName
		 methodName: (char *) methodName
			  fatal: (id) aMessage
{
	[self lineNumber: lineNumber fileName: fileName methodName: methodName fatal: aMessage exception: nil];
}

- (void) lineNumber: (int) lineNumber
		   fileName: (char *) fileName
		 methodName: (char *) methodName
			  fatal: (id) aMessage
		  exception: (NSException *) e
{
	if([repository isDisabled: [_fatal intValue]]) {
		return;
	}
	
	if([_fatal isGreaterOrEqual: [self effectiveLevel]]) {
		[self forcedLog: [L4LoggingEvent logger: self
										  level: _fatal
									 lineNumber: lineNumber
									   fileName: fileName
									 methodName: methodName
										message: aMessage
									  exception: e]];
	}
}

/* legacy method, see forcedLog: (L4LoggingEvent *) event */
- (void) log: (id) aMessage level: (L4Level *) aLevel
{
	[self forcedLog: [L4LoggingEvent logger: self level: aLevel message: aMessage]];
}

/* legacy method, see forcedLog: (L4LoggingEvent *) event */
- (void) log: (id) aMessage level: (L4Level *) aLevel exception: (NSException *) e
{
	[self forcedLog: [L4LoggingEvent logger: self level: aLevel message: aMessage exception: e]];
}

/* legacy method, see forcedLog: (L4LoggingEvent *) event */
- (void) log: (id) aMessage
	   level: (L4Level *) aLevel
   exception: (NSException *) e
  lineNumber: (int) lineNumber
	fileName: (char *) fileName
  methodName: (char *) methodName
{
	[self forcedLog: [L4LoggingEvent logger: self
									  level: aLevel
								 lineNumber: lineNumber
								   fileName: fileName
								 methodName: methodName
									message: aMessage
								  exception: e]];
}

/* legacy method, see forcedLog: (L4LoggingEvent *) event */
- (void) forcedLog: (id) aMessage
			 level: (L4Level *) aLevel
		 exception: (NSException *) e
		lineNumber: (int) lineNumber
		  fileName: (char *) fileName
		methodName: (char *) methodName
{
	[self callAppenders: [L4LoggingEvent logger: self
										  level: aLevel
									 lineNumber: lineNumber
									   fileName: fileName
									 methodName: methodName
										message: aMessage
									  exception: e]];
}

// THIS IS THE MAIN METHOD, the other few above methods are still here due to the porting process
// I'm not entirely sure if they're going to stick around, but definately for now.
//
- (void) forcedLog: (L4LoggingEvent *) event
{
	[self callAppenders: event];
}
@end
