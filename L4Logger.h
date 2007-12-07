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

#define log4Debug(message, args...) if([[self l4Logger] isDebugEnabled]) log4Log(L4_PLAIN(debug), message, (args))
#define log4Info(message, args...)  if([[self l4Logger] isInfoEnabled]) log4Log(L4_PLAIN(info), message, (args))
#define log4Warn(message, args...)  log4Log(L4_PLAIN(warn), message, (args))
#define log4Error(message, args...) log4Log(L4_PLAIN(error), message, (args))
#define log4Fatal(message, args...) log4Log(L4_PLAIN(fatal), message, (args))

#define log4DebugWithException(message, e, args...) if([[self l4Logger] isDebugEnabled]) log4Log(L4_EXCEPTION(debug, e), message, (args))
#define log4InfoWithException(message, e, args...)  if([[self l4Logger] isInfoEnabled]) log4Log(L4_EXCEPTION(info, e), message, (args))
#define log4WarnWithException(message, e, args...)  log4Log(L4_EXCEPTION(warn, e), message, (args))
#define log4ErrorWithException(message, e, args...) log4Log(L4_EXCEPTION(error, e), message, (args))
#define log4FatalWithException(message, e, args...) log4Log(L4_EXCEPTION(fatal, e), message, (args))

#define log4Assert(assertion, message, args...) log4Log(L4_ASSERTION(assertion), message, (args))

@interface L4Logger : NSObject {
    NSString *name;
    L4Level *level;
    L4Logger *parent;
    id <L4LoggerRepository> repository;
    BOOL additive;
    L4AppenderAttachableImpl *aai;
}

+ (void) taskNowMultiThreaded: (NSNotification *) event;

// DON'T USE, only for use of log manager
- (id) initWithName: (NSString *) loggerName;

- (BOOL) additivity;
- (void) setAdditivity: (BOOL) newAdditivity;

- (L4Logger *) parent; // root Logger returs nil
- (void) setParent: (L4Logger *) theParent;

- (NSString *) name;
- (id <L4LoggerRepository>) loggerRepository;
- (void) setLoggerRepository: (id <L4LoggerRepository>) aRepository;

- (L4Level *) effectiveLevel;

- (L4Level *) level;
- (void) setLevel: (L4Level *) aLevel; // nil is ok, because then we just pick up the parent's level

@end

@interface L4Logger (AppenderRelatedMethods)

- (void) callAppenders: (L4LoggingEvent *) event;

- (L4AppenderAttachableImpl *) aai;

- (NSArray *) allAppendersArray;
- (NSEnumerator *) allAppenders;
- (id <L4Appender>) appenderWithName: (NSString *) aName; // returns appender if in list, otherwise nil

- (void) addAppender: (id <L4Appender>) appender; // SYNCHRONIZED
- (BOOL) isAttached: (id <L4Appender>) appender;

- (void) closeNestedAppenders;

- (void) removeAllAppenders;
- (void) removeAppender: (id <L4Appender>) appender;
- (void) removeAppenderWithName: (NSString *) aName;

@end

@interface L4Logger (CoreLoggingMethods)

/* ALL < DEBUG < INFO < WARN < ERROR < FATAL < OFF */

- (BOOL) isDebugEnabled;
- (BOOL) isInfoEnabled;
- (BOOL) isWarnEnabled;   /* added not in Log4J */
- (BOOL) isErrorEnabled;  /* added not in Log4J */ 
- (BOOL) isFatalEnabled;  /* added not in Log4J */

- (BOOL) isEnabledFor: (L4Level *) aLevel;

- (void) assert: (BOOL) anAssertion
            log: (NSString *) aMessage;

- (void) lineNumber: (int) lineNumber
           fileName: (char *) fileName
         methodName: (char *) methodName
             assert: (BOOL) anAssertion
                log: (NSString *) aMessage;

/* Debug */

- (void) debug: (id) aMessage;

- (void) debug: (id) aMessage
     exception: (NSException *) e;

- (void) lineNumber: (int) lineNumber
           fileName: (char *) fileName
         methodName: (char *) methodName
              debug: (id) aMessage;

- (void) lineNumber: (int) lineNumber
           fileName: (char *) fileName
         methodName: (char *) methodName
              debug: (id) aMessage
          exception: (NSException *) e;

/* Info */

- (void) info: (id) aMessage;

- (void) info: (id) aMessage
    exception: (NSException *) e;

- (void) lineNumber: (int) lineNumber
           fileName: (char *) fileName
         methodName: (char *) methodName
               info: (id) aMessage;

- (void) lineNumber: (int) lineNumber
           fileName: (char *) fileName
         methodName: (char *) methodName
               info: (id) aMessage
          exception: (NSException *) e;

/* Warn */

- (void) warn: (id) aMessage;

- (void) warn: (id) aMessage
    exception: (NSException *) e;

- (void) lineNumber: (int) lineNumber
           fileName: (char *) fileName
         methodName: (char *) methodName
               warn: (id) aMessage;

- (void) lineNumber: (int) lineNumber
           fileName: (char *) fileName
         methodName: (char *) methodName
               warn: (id) aMessage
          exception: (NSException *) e;

/* Error */

- (void) error: (id) aMessage;

- (void) error: (id) aMessage
     exception: (NSException *) e;

- (void) lineNumber: (int) lineNumber
           fileName: (char *) fileName
         methodName: (char *) methodName
              error: (id) aMessage;

- (void) lineNumber: (int) lineNumber
           fileName: (char *) fileName
         methodName: (char *) methodName
              error: (id) aMessage
          exception: (NSException *) e;

/* Fatal */

- (void) fatal: (id) aMessage;

- (void) fatal: (id) aMessage
     exception: (NSException *) e;

- (void) lineNumber: (int) lineNumber
           fileName: (char *) fileName
         methodName: (char *) methodName
              fatal: (id) aMessage;

- (void) lineNumber: (int) lineNumber
           fileName: (char *) fileName
         methodName: (char *) methodName
              fatal: (id) aMessage
          exception: (NSException *) e;

/* Legacy primitive logging methods               */
/* See below, forcedLog: (L4LoggingEvent *) event */

- (void) log: (id) aMessage
       level: (L4Level *) aLevel;

- (void) log: (id) aMessage
       level: (L4Level *) aLevel
   exception: (NSException *) e;

- (void) log: (id) aMessage
       level: (L4Level *) aLevel
   exception: (NSException *) e
  lineNumber: (int) lineNumber
    fileName: (char *) fileName
  methodName: (char *) methodName;

- (void) forcedLog: (id) aMessage
             level: (L4Level *) aLevel
         exception: (NSException *) e
        lineNumber: (int) lineNumber
          fileName: (char *) fileName
        methodName: (char *) methodName;

/* This is the designated logging method that the others invoke. */

- (void) forcedLog: (L4LoggingEvent *) event;

@end


@interface L4Logger (LogManagerCoverMethods)

+ (L4Logger *) rootLogger;

+ (L4Logger *) loggerForClass: (Class) aClass;
+ (L4Logger *) loggerForName: (NSString *) aName;
+ (L4Logger *) loggerForName: (NSString *) aName
                     factory: (id <L4LoggerFactory>) aFactory;

/* returns logger if it exists, otherise nil */
+ (L4Logger *) exists: (NSString *) loggerName;

+ (NSArray *) currentLoggersArray;
+ (NSEnumerator *) currentLoggers;

@end

