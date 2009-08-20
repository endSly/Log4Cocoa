/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import "L4Logger.h"
#import "L4AppenderAttachable.h"
#import "L4Level.h"
#import "L4LoggerStore.h"
#import "L4LoggingEvent.h"
#import "L4LogLog.h"
#import "L4RootLogger.h"


static L4LoggerStore *_loggerRepository = nil;

@implementation L4Logger

+ (void) initialize
{
	id rootLogger = [[L4RootLogger alloc] initWithLevel:[L4Level debug]];
	_loggerRepository = [[L4LoggerStore alloc] initWithRoot:rootLogger];
	[rootLogger autorelease];

	[L4LoggingEvent startTime];
}

- init
{
	return nil; // never use this constructor
}

- (id) initWithName:(NSString *) aName
{
	self = [super init];
	if( self != nil ) {
		name = [aName copy];
		additivity = YES;
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
	return additivity;
}

- (void) setAdditivity:(BOOL) newAdditivity
{
        additivity = newAdditivity;
}

- (L4Logger *) parent
{
	return parent;
}

- (void) setParent:(L4Logger *) theParent
{
    @synchronized(self) {
        [parent autorelease];
        parent = [theParent retain];
    }
}

- (NSString *) name
{
	return name;
}

- (id <L4LoggerRepository>) loggerRepository
{
	return repository;
}

- (void) setLoggerRepository:(id <L4LoggerRepository>) aRepository
{
    @synchronized(self) {
        if( repository != aRepository ) {
            [repository autorelease];
            repository = [aRepository retain];
        }
    }
}

// NO METHOD CALLING - PERFORMANCE TWEAKED METHOD
- (L4Level *) effectiveLevel
{
	L4Level *effectiveLevel = nil;
    @synchronized(self) {
        L4Logger *aLogger = self;
        while (aLogger != nil) {
            if((aLogger->level) != nil) {
                effectiveLevel = aLogger->level;
                break;
            }
            aLogger = aLogger->parent;
        }
    }
        
    if (effectiveLevel == nil) {
        [L4LogLog error:@"Root Logger Not Found!"];
    }
	return effectiveLevel;
}

- (L4Level *) level
{
	return level;
}

/* nil is ok, because then we just pick up the parent's level */
- (void) setLevel:(L4Level *) aLevel
{
    @synchronized(self) {
    	if( level != aLevel ) {
	    	[level autorelease];
		    level = [aLevel retain];
	    }
	}
}

/* ********************************************************************* */
#pragma mark AppenderRelatedMethods methods
/* ********************************************************************* */

- (void) callAppenders:(L4LoggingEvent *) event
{
	int writes = 0;

	@synchronized(self) {
	
        for( L4Logger *aLogger = self; aLogger != nil; aLogger = [aLogger parent] ) {
            if( [aLogger aai] != nil ) {
                writes += [[aLogger aai] appendLoopOnAppenders:event];
            }
            if( ![aLogger additivity] ) {
                break;
            }
        }
    }
        
    if( writes == 0 ) {
        [repository emitNoAppenderWarning:self];
    }
}

- (L4AppenderAttachable *) aai
{
	return aai;
}

- (NSArray *) allAppenders
{
	return [aai allAppenders];
}

- (id <L4Appender>) appenderWithName:(NSString *) aName
{
	return [aai appenderWithName:aName];
}

- (void) addAppender:(id <L4Appender>) appender
{
    @synchronized(self) {
        if( aai == nil ) {
            aai = [[L4AppenderAttachable alloc] init];
        }
        
        [aai addAppender:appender];
    }
}

- (BOOL) isAttached:(id <L4Appender>) appender
{
    BOOL isAttached = NO;
    @synchronized(self) {
        if((appender != nil) && (aai != nil)) {
            isAttached = [aai isAttached:appender];
        }
    }
    return isAttached;
}

- (void) closeNestedAppenders
{
    @synchronized(self) {
        NSEnumerator *enumerator = [[self allAppenders] objectEnumerator];
        id <L4Appender> anObject;
        
        while ((anObject = (id <L4Appender>)[enumerator nextObject])) {
            [anObject close];
        }
    }
}

- (void) removeAllAppenders
{
    @synchronized(self) {
        [aai removeAllAppenders];
        [aai release];
        aai = nil;
    }
}

- (void) removeAppender:(id <L4Appender>) appender
{
    [aai removeAppender:appender];
}

- (void) removeAppenderWithName:(NSString *) aName
{
    [aai removeAppenderWithName:aName];
}

/* ********************************************************************* */
#pragma mark CoreLoggingMethods methods
/* ********************************************************************* */

// ALL < DEBUG < INFO < WARN < ERROR < FATAL < OFF

- (BOOL) isDebugEnabled 
{ 
	return [self isEnabledFor:[L4Level debug]]; 
}
- (BOOL) isInfoEnabled  
{ 
	return [self isEnabledFor:[L4Level info]]; 
}
- (BOOL) isWarnEnabled  
{ 
	return [self isEnabledFor:[L4Level warn]]; 
}
- (BOOL) isErrorEnabled 
{ 
	return [self isEnabledFor:[L4Level error]]; 
}
- (BOOL) isFatalEnabled 
{ 
	return [self isEnabledFor:[L4Level fatal]]; 
}

- (BOOL) isEnabledFor:(L4Level *) aLevel
{
	if([repository isDisabled:[aLevel intValue]]) {
		return NO;
	}
	return [aLevel isGreaterOrEqual:[self effectiveLevel]];
}

- (void) lineNumber:(int) lineNumber
		   fileName:(char *) fileName
		 methodName:(char *) methodName
			 assert:(BOOL) anAssertion
				log:(NSString *) aMessage
{
	if( !anAssertion ) {
		[self lineNumber:lineNumber 
				fileName:fileName 
			  methodName:methodName 
				 message:aMessage 
				   level:[L4Level error] 
			   exception:nil];
	}
}

- (void) lineNumber:(int) lineNumber
		   fileName:(char *) fileName
		 methodName:(char *) methodName
			message:(id) aMessage
			  level:(L4Level *) aLevel
		  exception:(NSException *) e
{
	if([repository isDisabled:[aLevel intValue]]) {
		return;
	}
	
	if([aLevel isGreaterOrEqual:[self effectiveLevel]]) {
		[self forcedLog:[L4LoggingEvent logger:self
										 level:aLevel
									lineNumber:lineNumber
									  fileName:fileName
									methodName:methodName
									   message:aMessage
									 exception:e]];
	}
}

- (void) forcedLog:(L4LoggingEvent *) event
{
	[self callAppenders:event];
}

/* ********************************************************************* */
#pragma mark Logger management methods
/* ********************************************************************* */
+ (id <L4LoggerRepository>) loggerRepository
{
	return _loggerRepository;
}

+ (L4Logger *) rootLogger
{
	return [_loggerRepository rootLogger];
}

+ (L4Logger *) loggerForClass:(Class) aClass
{
	return [_loggerRepository loggerForClass:aClass];
}

+ (L4Logger *) loggerForName:(NSString *) aName
{
	return [_loggerRepository loggerForName:aName];
}

+ (L4Logger *) loggerForName:(NSString *) aName factory:(id <L4LoggerFactory>) aFactory
{
	return [_loggerRepository loggerForName:aName factory:aFactory];
}

+ (NSArray *) currentLoggers
{
	return [_loggerRepository currentLoggers];
}

+ (void) shutdown
{
	return [_loggerRepository shutdown];
}

+ (void) resetConfiguration
{
	return [_loggerRepository resetConfiguration];
}

@end


@implementation L4FunctionLogger
static L4FunctionLogger *instance;
+ (L4FunctionLogger *)instance
{
	if (instance == nil) {
		instance = [[L4FunctionLogger alloc] init];
	}
	return instance;
}

- (void) dealloc
{
	[instance release];
	instance = nil;
	[super dealloc];
}
@end
