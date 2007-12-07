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

// #import "Log4Cocoa.h"
#import <Foundation/Foundation.h>

// ALL < DEBUG < INFO < WARN < ERROR < FATAL < OFF

#define   OFF_INT  99
#define FATAL_INT  50
#define ERROR_INT  40
#define  WARN_INT  30
#define  INFO_INT  20
#define DEBUG_INT  10
#define   ALL_INT  0

@interface L4Level : NSObject {
    int      intValue;
    int      syslogEquivalent;
    NSString *name;
}

+ (void) initialize;

+ (L4Level *) withLevel: (int) aLevel
               withName: (NSString *) aName
       syslogEquivalent: (int) sysLogLevel;

+ (L4Level *) off;
+ (L4Level *) fatal;
+ (L4Level *) error;
+ (L4Level *) warn;
+ (L4Level *) info;
+ (L4Level *) debug;
+ (L4Level *) all;

+ (L4Level *) levelWithName: (NSString *) aLevel;
+ (L4Level *) levelWithName: (NSString *) aLevel
               defaultLevel: (L4Level *) defaultLevel;

+ (L4Level *) levelWithInt: (int) aLevel;
+ (L4Level *) levelWithInt: (int) aLevel
              defaultLevel: (L4Level *) defaultLevel;

- (id) initLevel: (int) aLevel
        withName: (NSString *) aName
syslogEquivalent: (int) sysLogLevel;

- (void) dealloc;
- (NSString *) description;

- (int) intValue;

- (NSString *) stringValue;

- (int) syslogEquivalent;

/* this is Log4J method name */
- (BOOL) isGreaterOrEqual: (L4Level *) aLevel;

/* this is a better name for the method, but I won't */
/* use it for now to stay in synch with Log4J. */
- (BOOL) isEnabledFor: (L4Level *) aLevel;

- (oneway void) release; // prevents releasing of singleton copies

@end
