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

#import "L4WriterAppender.h"
#import "L4Configurator.h"

@implementation L4WriterAppender

- (id) init
{
    self = [super init];
    if( self != nil )
    {
        immediateFlush = YES;
    }
    return self;
}

- (id) initWithLayout: (L4Layout *) aLayout
           fileHandle: (NSFileHandle *) aFileHandle
{
    [self init]; // call designated initializer
    fileHandle= [aFileHandle retain];
    [self setLayout: aLayout];
    return self;
}

- (void) dealloc
{
    [fileHandle release];
    [super dealloc];
}

    /****************
- (id) initWithLayout: (L4Layout *) aLayout
          ouputStream: (OUTPUT_STREAM) os; /// coder???

- (id) initWithLayout: (L4Layout *) aLayout
               writer: (WRITER) aWriter; /// coder???
    */

/*******  NEED TO FIGURE OUT INITIALIZATION STRATAGEY  *********/ 

- (BOOL) immediateFlush
{
    return immediateFlush;
}

- (void) setImmediateFlush: (BOOL) flush
{
    immediateFlush = flush;
}

// Reminder: the nesting of calls is:
//
//    doAppend()
//      - check threshold
//      - filter
//      - append();
//        - checkEntryConditions();
//        - subAppend();
//
- (void) append: (L4LoggingEvent *) anEvent
{
    if([self checkEntryConditions])
    {
        [self subAppend: anEvent];
    }
}

/**
Actual writing occurs here.

<p>Most subclasses of <code>WriterAppender</code> will need to
override this method.*/
- (void) subAppend: (L4LoggingEvent *) anEvent
{
    [self write: [layout format: anEvent]];
}

/**
This method determines if there is a sense in attempting to append.

<p>It checks whether there is a set output target and also if
there is a set layout. If these checks fail, then the boolean
value <code>false</code> is returned. */
- (BOOL) checkEntryConditions
{
    if( closed )
    {
        [L4LogLog warn: @"Not allowed to write to a closed appender."];
        return NO;
    }

    if( fileHandle == nil )
    {
        [[self errorHandler] error: [@"No file handle for output stream set for the appender named: " stringByAppendingString: name]];
        return NO;
    }

    if( layout == nil )
    {
        [[self errorHandler] error: [@"No layout set for the appender named: " stringByAppendingString: name]];
        return NO;
    }
    
    return YES;
}

- (void) closeWriter
{
    NS_DURING
        [fileHandle closeFile];
    NS_HANDLER
        [L4LogLog error:
            [[@"Could not close file handle: " stringByAppendingString:
                [fileHandle description]] stringByAppendingString: [localException description]]];
    NS_ENDHANDLER
}

- (void)setFileHandle: (NSFileHandle*)fh
{
	if (fileHandle != fh)
	{
		[self closeWriter];
		[fileHandle release];
		fileHandle = nil;
		fileHandle = [fh retain];
	}
}

- (void) reset
{
    [self closeWriter];
}

/**
 * NOTE --- this method adds a lineBreakChar between log messages.
 * So layouts & log messages do not need to add a trailing line break.
 */
- (void) write: (NSString *) theString
{
    if( theString != nil )
    {
        NS_DURING
            // TODO ### -- NEED UNIX EXPERT IS THIS THE BEST WAY ??
            // TODO - ### - NEED TO WORK ON ENCODING ISSUES (& THEN LATER LOCALIZATION)
            //
            [fileHandle writeData:
                [theString dataUsingEncoding: NSASCIIStringEncoding
                        allowLossyConversion: YES]];
            [fileHandle writeData: [L4Configurator lineBreakChar]];
        NS_HANDLER
            [[self errorHandler] error:
                [[@"Appender failed to write string:" stringByAppendingString:
                    theString] stringByAppendingString: [localException description]]];
        NS_ENDHANDLER
    }
}

- (void) writeHeader
{
    [self write: [layout header]];
}

- (void) writeFooter
{
    [self write: [layout footer]];
}

- (NSStringEncoding) encoding
{
    return encoding;
}

- (void) setEncoding: (NSStringEncoding) newEncoding
{
    encoding = newEncoding;
}

@end


@implementation L4WriterAppender (L4OptionHandlerCategory)

- (void) activateOptions
{
    // does nothing in this class.
}

@end


@implementation L4WriterAppender (L4AppenderCategory)

- (void) close // synchronized ... make thread safe???
{
    if( !closed )
    {
        closed = YES;
        [self writeFooter];
        [self reset];
    }
}

- (BOOL) requiresLayout
{
    return YES;
}

@end
