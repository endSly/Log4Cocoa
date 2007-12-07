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
#import "L4LoggerProtocols.h"
#import "L4Logger.h"
#import "L4Level.h"
#import "L4LogLog.h"

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

/********
 * enables thread locking, no need to lock if not mulit-threaded.
 */
+ (void) taskNowMultiThreaded: (NSNotification *) event;


/*******
 * the following are L4LoggerRepository methods
 */
- (id) initWithRoot: (id) rootLogger;

/******
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

/*****
 * Gets a logger for the class object, if it doesn't exist already
 * it is created by composing the pseudo-fqcn and then calling
 * loggerForName:factory: which does the hard work.
 */
- (L4Logger *) loggerForClass: (Class) aClass;

/* a wrapper for loggerForName:factory: with self as the factory */
- (L4Logger *) loggerForName: (NSString *) aName;

/*****
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


@interface L4LoggerStore (L4RepositorySelectorCategory) <L4RepositorySelector>

- (id <L4LoggerRepository>) loggerRepository;

@end


@interface L4LoggerStore (L4LoggerFactoryCategory) <L4LoggerFactory>

- (L4Logger *) makeNewLoggerInstance: (NSString *) aName;

@end
