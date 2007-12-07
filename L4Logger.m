/****************************
*
* Copyright (c) 2002, 2003, Bob Frank
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions
* are met:
*
*  - Redistributions of source code must retain the above copyright
*    notice, this list of conditions and the following disclaimer.
*
*  - Redistributions in binary form must reproduce the above copyright
*    notice, this list of conditions and the following disclaimer in the
*    documentation and/or other materials provided with the distribution.
*
*  - Neither the name of Log4Cocoa nor the names of its contributors or owners
*    may be used to endorse or promote products derived from this software
*    without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
* "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
* LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
* A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
* OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
* SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
* TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
* OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
* OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
* NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*
****************************/

#import "L4Logger.h"
#import "L4AppenderAttachableImpl.h"
#import "L4Level.h"
#import "L4LoggingEvent.h"
#import "L4LogLog.h"
#import "L4LogManager.h"
#import "L4NSObjectAdditions.h"
#import "L4PreprocessorStatics.h"

static L4Level *_fatal = nil;
static L4Level *_error = nil;
static L4Level *_warn  = nil;
static L4Level *_info  = nil;
static L4Level *_debug = nil;
static NSLock *_loggerLock = nil;

id objc_msgSend(id self, SEL op, ...);

void log4Log(id object, int line, char *file, const char *method,
              SEL sel, BOOL isAssertion, BOOL assertion, 
              id exception, id message, ...)
{
    NSString *combinedMessage;
    if ( [message isKindOfClass:[NSString class]] )
    {
        va_list args;
        va_start(args, message);
        combinedMessage = [[NSString alloc] initWithFormat:message
                                                 arguments:args];
        va_end(args);
    }
    else
    {
        combinedMessage = [message retain];
    }

    if ( isAssertion )
    {
        objc_msgSend([object l4Logger], sel, line, file, method, 
                     assertion, combinedMessage);
    }
    else
    {
        objc_msgSend([object l4Logger], sel, line, file, method, 
                     combinedMessage, exception);
    }
    
    [combinedMessage release];
}

@implementation L4Logger

+ (void) initialize
{
    // Making sure that we capture the startup time of
    // this application.  This sanity check is also in
    // +[L4Configurator initialize] too.
    //
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

+ (void) taskNowMultiThreaded: (NSNotification *) event {
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
    if( self != nil )
    {
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

/* root Logger returs nil */
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
    if( repository != aRepository )
    {
        [repository autorelease];
        repository = [aRepository retain];
    }
}

// NO METHOD CALLING - PERFORMANCE TWEAKED METHOD
- (L4Level *) effectiveLevel
{
    L4Logger *aLogger = (L4Logger *)self;
    for(; aLogger != nil; aLogger = aLogger->parent)
    {
        if((aLogger->level) != nil)
        {
            return aLogger->level;
        }
    }
    // should we have an emit once only error message here?
    // cause root logger wasn't found.
    // ### TODO ???
    [L4LogLog error: @"Root Logger Not Found!"];
    return nil;
}

- (L4Level *) level
{
    return level;
}

/* nil is ok, because then we just pick up the parent's level */
- (void) setLevel: (L4Level *) aLevel
{
    if( level != aLevel )
    {
        [level autorelease];
        level = [aLevel retain];
    }
}

@end


@implementation L4Logger (LogManagerCoverMethods)

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

+ (L4Logger *) loggerForName: (NSString *) loggerName
                     factory: (id <L4LoggerFactory>) aFactory
{
    return [L4LogManager loggerForName: loggerName
                               factory: aFactory];
}

/* returns logger if it exists, otherise nil */
+ (L4Logger *) exists: (NSString *) loggerName
{
    return [L4LogManager exists: loggerName];
}

+ (NSArray *) currentLoggersArray
{
    return [L4LogManager currentLoggersArray];
}

+ (NSEnumerator *) currentLoggers
{
    return [L4LogManager currentLoggers];
}

@end


@implementation L4Logger (AppenderRelatedMethods)

- (void) callAppenders: (L4LoggingEvent *) event
{
    L4Logger *aLogger = self;
    int writes = 0;

//    [_loggerLock lock];  // ### LOCKING

    for( aLogger = self; aLogger != nil; aLogger = [aLogger parent] )
    {
        if( [aLogger aai] != nil )
        {
            writes += [[aLogger aai] appendLoopOnAppenders: event];
        }
        if( ![aLogger additivity] )
        {
            break;
        }
    }

//    [_loggerLock unlock];  // ### LOCKING

    if( writes == 0 )
    {
        [repository emitNoAppenderWarning: self];
    }
}

- (L4AppenderAttachableImpl *) aai
{
    return aai;
}

- (NSArray *) allAppendersArray
{
    return [aai allAppendersArray];
}

- (NSEnumerator *) allAppenders
{
    return [aai allAppenders];
}

/* Returns appender if in list, otherwise nil */
- (id <L4Appender>) appenderWithName: (NSString *) aName
{
    return [aai appenderWithName: aName];
}

- (void) addAppender: (id <L4Appender>) appender // SYNCHRONIZED
{
//    [_loggerLock lock];  // ### LOCKING
    if( aai == nil )
    {
        aai = [[L4AppenderAttachableImpl alloc] init];
    }

    [aai addAppender: appender];
//    [_loggerLock unlock];  // ### LOCKING
}

- (BOOL) isAttached: (id <L4Appender>) appender
{
    if((appender == nil) || (aai == nil))
    {
        return NO;
    }
    return [aai isAttached: appender];
}

// This is weird ... don't normally call this method directly.
// It is designed to be called form L4LoggerStore:shutdown
// I don't quite understand the semantics of calling close,
// but I've ported it directly for now.  I will play with this
// more later.
//
- (void) closeNestedAppenders
{
    NSEnumerator *enumerator = [self allAppenders];
    id <L4Appender> anObject;

    while ((anObject = (id <L4Appender>)[enumerator nextObject]))
    {
        if([anObject conformsToProtocol: @protocol(L4AppenderAttachable)])
        {
            // ### ???
            // I DON'T UNDERSTAND THIS ??? why just AppenderAttachables?
            // if an appender needs to get sent close before it shutdowns
            // it should implement the L4AppenderAttachable protocol
            // weird?!?!?!
            //
//            [_loggerLock lock];  // ### LOCKING
            [anObject close];
//            [_loggerLock unlock];  // ### LOCKING
        }
    }
}

- (void) removeAllAppenders
{
//    [_loggerLock lock];  // ### LOCKING
    [aai removeAllAppenders];
    [aai release];
    aai = nil;
//    [_loggerLock unlock];  // ### LOCKING
}

- (void) removeAppender: (id <L4Appender>) appender
{
//    [_loggerLock lock];  // ### LOCKING
    [aai removeAppender: appender];
//    [_loggerLock unlock];  // ### LOCKING
}

- (void) removeAppenderWithName: (NSString *) aName
{
//    [_loggerLock lock];  // ### LOCKING
    [aai removeAppenderWithName: aName];
//    [_loggerLock unlock];  // ### LOCKING
}

@end


@implementation L4Logger (CoreLoggingMethods)

// ALL < DEBUG < INFO < WARN < ERROR < FATAL < OFF

- (BOOL) isDebugEnabled { return [self isEnabledFor: _debug]; }
- (BOOL) isInfoEnabled  { return [self isEnabledFor: _info]; }

// I added these convience methods, they're not in Log4J
- (BOOL) isWarnEnabled  { return [self isEnabledFor: _warn]; }
- (BOOL) isErrorEnabled { return [self isEnabledFor: _error]; }
- (BOOL) isFatalEnabled { return [self isEnabledFor: _fatal]; }

- (BOOL) isEnabledFor: (L4Level *) aLevel
{
    if([repository isDisabled: [aLevel intValue]])
    {
        return NO;
    }
    return [aLevel isGreaterOrEqual: [self effectiveLevel]];
}

- (void) assert: (BOOL) anAssertion
            log: (NSString *) aMessage
{
    if( !anAssertion )
    {
        [self error: aMessage];
    }
}

- (void) lineNumber: (int) lineNumber
           fileName: (char *) fileName
         methodName: (char *) methodName
             assert: (BOOL) anAssertion
                log: (NSString *) aMessage
{
    if( !anAssertion )
    {
        [self lineNumber: lineNumber
                fileName: fileName
              methodName: methodName
                   error: aMessage
               exception: nil];
    }
}

/* debug */

- (void) debug: (id) aMessage
{
    [self lineNumber: NO_LINE_NUMBER
            fileName: NO_FILE_NAME
          methodName: NO_METHOD_NAME
               debug: aMessage
           exception: nil];
}

- (void) debug: (id) aMessage
     exception: (NSException *) e
{
    [self lineNumber: NO_LINE_NUMBER
            fileName: NO_FILE_NAME
          methodName: NO_METHOD_NAME
               debug: aMessage
           exception: e];
}

- (void) lineNumber: (int) lineNumber
           fileName: (char *) fileName
         methodName: (char *) methodName
              debug: (id) aMessage
{
    [self lineNumber: lineNumber
            fileName: fileName
          methodName: methodName
               debug: aMessage
           exception: nil];
}

- (void) lineNumber: (int) lineNumber
           fileName: (char *) fileName
         methodName: (char *) methodName
              debug: (id) aMessage
          exception: (NSException *) e
{
    // Check repository threshold level
    //
    if([repository isDisabled: [_debug intValue]])
    {
        return;
    }

    // Check this particular loggers level
    //
    if([_debug isGreaterOrEqual: [self effectiveLevel]])
    {
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
    [self lineNumber: NO_LINE_NUMBER
            fileName: NO_FILE_NAME
          methodName: NO_METHOD_NAME
                info: aMessage
           exception: nil];
}

- (void) info: (id) aMessage
    exception: (NSException *) e
{
    [self lineNumber: NO_LINE_NUMBER
            fileName: NO_FILE_NAME
          methodName: NO_METHOD_NAME
                info: aMessage
           exception: e];
}

- (void) lineNumber: (int) lineNumber
           fileName: (char *) fileName
         methodName: (char *) methodName
               info: (id) aMessage
{
    [self lineNumber: lineNumber
            fileName: fileName
          methodName: methodName
                info: aMessage
           exception: nil];
}

- (void) lineNumber: (int) lineNumber
           fileName: (char *) fileName
         methodName: (char *) methodName
               info: (id) aMessage
          exception: (NSException *) e
{
    // Check repository threshold level
    //
    if([repository isDisabled: [_info intValue]])
    {
        return;
    }

    // Check this particular loggers level
    //
    if([_info isGreaterOrEqual: [self effectiveLevel]])
    {
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
    [self lineNumber: NO_LINE_NUMBER
            fileName: NO_FILE_NAME
          methodName: NO_METHOD_NAME
                warn: aMessage
           exception: nil];
}

- (void) warn: (id) aMessage
    exception: (NSException *) e
{
    [self lineNumber: NO_LINE_NUMBER
            fileName: NO_FILE_NAME
          methodName: NO_METHOD_NAME
                warn: aMessage
           exception: e];
}

- (void) lineNumber: (int) lineNumber
           fileName: (char *) fileName
         methodName: (char *) methodName
               warn: (id) aMessage
{
    [self lineNumber: lineNumber
            fileName: fileName
          methodName: methodName
                warn: aMessage
           exception: nil];
}

- (void) lineNumber: (int) lineNumber
           fileName: (char *) fileName
         methodName: (char *) methodName
               warn: (id) aMessage
          exception: (NSException *) e
{
    // Check repository threshold level
    //
    if([repository isDisabled: [_warn intValue]])
    {
        return;
    }

    // Check this particular loggers level
    //
    if([_warn isGreaterOrEqual: [self effectiveLevel]])
    {
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
    [self lineNumber: NO_LINE_NUMBER
            fileName: NO_FILE_NAME
          methodName: NO_METHOD_NAME
               error: aMessage
           exception: nil];
}

- (void) error: (id) aMessage
     exception: (NSException *) e
{
    [self lineNumber: NO_LINE_NUMBER
            fileName: NO_FILE_NAME
          methodName: NO_METHOD_NAME
               error: aMessage
           exception: e];
}

- (void) lineNumber: (int) lineNumber
           fileName: (char *) fileName
         methodName: (char *) methodName
              error: (id) aMessage
{
    [self lineNumber: lineNumber
            fileName: fileName
          methodName: methodName
               error: aMessage
           exception: nil];
}

- (void) lineNumber: (int) lineNumber
           fileName: (char *) fileName
         methodName: (char *) methodName
              error: (id) aMessage
          exception: (NSException *) e
{
    // Check repository threshold level
    //
    if([repository isDisabled: [_error intValue]])
    {
        return;
    }

    // Check this particular loggers level
    //
    if([_error isGreaterOrEqual: [self effectiveLevel]])
    {
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
    [self lineNumber: NO_LINE_NUMBER
            fileName: NO_FILE_NAME
          methodName: NO_METHOD_NAME
               fatal: aMessage
           exception: nil];
}

- (void) fatal: (id) aMessage
     exception: (NSException *) e
{
    [self lineNumber: NO_LINE_NUMBER
            fileName: NO_FILE_NAME
          methodName: NO_METHOD_NAME
               fatal: aMessage
           exception: e];
}

- (void) lineNumber: (int) lineNumber
           fileName: (char *) fileName
         methodName: (char *) methodName
              fatal: (id) aMessage
{
    [self lineNumber: lineNumber
            fileName: fileName
          methodName: methodName
               fatal: aMessage
           exception: nil];
}

- (void) lineNumber: (int) lineNumber
           fileName: (char *) fileName
         methodName: (char *) methodName
              fatal: (id) aMessage
          exception: (NSException *) e
{
    // Check repository threshold level
    //
    if([repository isDisabled: [_fatal intValue]])
    {
        return;
    }

    // Check this particular loggers level
    //
    if([_fatal isGreaterOrEqual: [self effectiveLevel]])
    {
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
- (void) log: (id) aMessage
       level: (L4Level *) aLevel
{
    [self forcedLog: [L4LoggingEvent logger: self
                                      level: aLevel
                                    message: aMessage]];
}

/* legacy method, see forcedLog: (L4LoggingEvent *) event */
- (void) log: (id) aMessage
       level: (L4Level *) aLevel
   exception: (NSException *) e
{
    [self forcedLog: [L4LoggingEvent logger: self
                                      level: aLevel
                                    message: aMessage
                                  exception: e]];
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
