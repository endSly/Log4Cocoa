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
#import "L4LoggingEvent.h"
#import "L4Level.h"
#import "L4Filter.h"
#import "L4Layout.h"

@interface L4AppenderSkeleton : NSObject {
    NSString *name;
    L4Layout *layout;
    L4Level *threshold;
    L4Filter *headFilter;
    L4Filter *tailFilter;
    id errorHandler;
    BOOL closed;
}

- (void) append: (L4LoggingEvent *) anEvent;
- (BOOL) isAsSevereAsThreshold: (L4Level *) aLevel;

- (L4Level *) threshold;
- (void) setThreshold: (L4Level *) aLevel;

@end


@interface L4AppenderSkeleton (L4OptionHandlerCategory) <L4OptionHandler>

- (void) activateOptions;

@end


@interface L4AppenderSkeleton (L4AppenderCategory) <L4Appender>

- (void) doAppend: (L4LoggingEvent *) anEvent;
// calls [self append: anEvent] after doing threshold checks

- (void) addFilter: (L4Filter *) aFilter;
- (L4Filter *) headFilter;
- (void) clearFilters;
- (void) close;

- (BOOL) requiresLayout;

- (NSString *) name;
- (void) setName: (NSString *) aName;

- (L4Layout *) layout;
- (void) setLayout: (L4Layout *) aLayout;

- (id <L4ErrorHandler>) errorHandler;
- (void) setErrorHandler: (id <L4ErrorHandler>) anErrorHandler;

@end
