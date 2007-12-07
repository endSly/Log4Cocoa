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
#import "L4AppenderSkeleton.h"
#import "L4LoggingEvent.h"
#import "L4AppenderProtocols.h"

@interface L4WriterAppender : L4AppenderSkeleton
{
    BOOL immediateFlush;        // default is YES
    NSStringEncoding encoding;  // default is lossy ASCII
    BOOL lossyEncoding;         // default is YES
    NSFileHandle *fileHandle;
    // L4QuietWriter // actual writer ?!?
}

- (id) init;

/*
- (id) initWithLayout: (L4Layout *) aLayout
          ouputStream: (NSFileHandle *) os;

- (id) initWithLayout: (L4Layout *) aLayout
               writer: (NSFileHandle *) aWriter;
*/
- (id) initWithLayout: (L4Layout *) aLayout
           fileHandle: (NSFileHandle *) aFileHandle;

- (BOOL) immediateFlush;
- (void) setImmediateFlush: (BOOL) flush;

// Reminder: the nesting of calls is:
//
//    doAppend()
//      - check threshold
//      - filter
//      - append();
//        - checkEntryConditions();
//        - subAppend();
//
- (void) append: (L4LoggingEvent *) anEvent;
- (void) subAppend: (L4LoggingEvent *) anEvent;
- (void) write: (NSString *) theString; // does the actual writing

/*!
	@method setFileHandle:
	@abstract Sets the NSFileHandle where the log output will go
	@param fh The NSFileHandle where you want the log output to go
*/
- (void)setFileHandle: (NSFileHandle *) fh;

/**
This method determines if there is a sense in attempting to append.

<p>It checks whether there is a set output target and also if
there is a set layout. If these checks fail, then the boolean
value <code>false</code> is returned. */
- (BOOL) checkEntryConditions;

- (void) closeWriter;
- (void) reset;

/******************* ### TODO
- (OUTPUT_STREAM) createWriter: (OUTPUT_STREAM) os;
- (void) setWriter: (WRITER) aWriter; // synchronized ... make thread safe??
*/
- (void) writeHeader;
- (void) writeFooter;

- (NSStringEncoding) encoding;
- (void) setEncoding: (NSStringEncoding) newEncoding;

@end


@interface L4WriterAppender (L4OptionHandlerCategory) <L4OptionHandler>

- (void) activateOptions;

@end


@interface L4WriterAppender (L4AppenderCategory)

- (void) close; // synchronized ... make thread safe???
- (BOOL) requiresLayout;

@end


