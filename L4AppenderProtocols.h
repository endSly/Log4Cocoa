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
// #import "L4Logger.h"
// #import "L4LoggingEvent.h"
// #import "L4Layout.h"
// #import "L4Filter.h"

@class L4Logger, L4Filter, L4Layout, L4LoggingEvent;

@protocol L4OptionHandler <NSObject>

- (void) activateOptions;

@end

@protocol L4ErrorHandler <L4OptionHandler>

- (void) activateOptions; // in Java ErrorHandler extends OptionHanlder, but for now I just copied the method

- (void) setLogger: (L4Logger *) aLogger;

- (void) error: (NSString *) message;

- (void) error: (NSString *) message
     exception: (NSException *) e
     errorCode: (int) errorCode;

- (void) error: (NSString *) message
     exception: (NSException *) e
     errorCode: (int) errorCode
         event: (L4LoggingEvent *) event;

- (void) setAppender: (id) appender; // can't forward declare protocols, so check to see if the object responds
- (void) setBackupAppender: (id) appender;

@end


@protocol L4Appender <NSObject>

- (void) doAppend: (L4LoggingEvent *) anEvent;   // appender log this event

- (void) addFilter: (L4Filter *) newFilter;      // adds to end of list
- (L4Filter *) headFilter;   // returns first filter or nil of there are none
- (void) clearFilters;       // removes all filters from list
- (void) close;              // it is a programing error to append to a close appender

- (BOOL) requiresLayout;

- (NSString *) name;      // unique name of this appender
- (void) setName: (NSString *) aName;

- (L4Layout *) layout;
- (void) setLayout: (L4Layout *) aLayout;

- (id <L4ErrorHandler>) errorHandler;
- (void) setErrorHandler: (id <L4ErrorHandler>) anErrorHandler;

@end


@protocol L4AppenderAttachable <NSObject>

- (void) addAppender: (id <L4Appender>) newAppender;

- (NSEnumerator *) allAppenders;
- (NSArray *) allAppendersArray;

- (id <L4Appender>) appenderWithName: (NSString *) aName;
- (BOOL) isAttached: (id <L4Appender>) appender;

- (void) removeAllAppenders;
- (void) removeAppender: (id <L4Appender>) appender;
- (void) removeAppenderWithName: (NSString *) aName;

@end
