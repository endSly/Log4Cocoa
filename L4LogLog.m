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

#import "L4LogLog.h"

#import "L4Configurator.h"

static BOOL internalDebugging = NO;
static BOOL quietMode = NO;

@implementation L4LogLog

+ (BOOL) internalDebuggingEnabled
{
    return internalDebugging;
}

+ (void) setInternalDebuggingEnabled: (BOOL) enabled
{
    internalDebugging = enabled;
}

+ (BOOL) quietModeEnabled
{
    return quietMode;
}

+ (void) setQuietModeEnabled: (BOOL) enabled
{
    quietMode = enabled;
}

+ (void) debug: (NSString *) message
{
    [self debug: message
      exception: nil];
}

+ (void) debug: (NSString *) message
     exception: (NSException *) e
{
    if(internalDebugging && !quietMode)
    {
        [self writeMessage: message
                withPrefix: L4LogLog_PREFIX
                    toFile: [NSFileHandle fileHandleWithStandardOutput]
                 exception: e];
    }
}

+ (void) warn: (NSString *) message
{
    [self warn: message
     exception: nil];
}

+ (void) warn: (NSString *) message
    exception: (NSException *) e
{
    if(!quietMode)
    {
        [self writeMessage: message
                withPrefix: L4LogLog_WARN_PREFIX
                    toFile: [NSFileHandle fileHandleWithStandardError]
                 exception: e];
    }
}

+ (void) error: (NSString *) message
{
    [self error: message
      exception: nil];
}

+ (void) error: (NSString *) message
     exception: (NSException *) e
{
    if(!quietMode)
    {
        [self writeMessage: message
                withPrefix: L4LogLog_ERROR_PREFIX
                    toFile: [NSFileHandle fileHandleWithStandardError]
                 exception: e];
    }
}

// ### TODO *** HELP --- need a unix file expert.  Should I need to flush after printf?
// it doesn't work right otherwise.
//
// Ok, I changed and just used an NSFileHandle because its easier and it just works.
// What are the performance implications, if any?
// ### TODO -- must test under heavy load and talk to performance expert.
//
+ (void) writeMessage: (NSString *) message
           withPrefix: (NSString *) prefix
               toFile: (NSFileHandle *) fileHandle
            exception: (NSException *) e
{
    NS_DURING
    [fileHandle writeData:
        [[prefix stringByAppendingString: message] dataUsingEncoding: NSASCIIStringEncoding
                                                allowLossyConversion: YES]];
    [fileHandle writeData: [L4Configurator lineBreakChar]];

    if( e != nil )
    {
        [fileHandle writeData:
            [[prefix stringByAppendingString: [e description]] dataUsingEncoding: NSASCIIStringEncoding
                                                            allowLossyConversion: YES]];
        [fileHandle writeData: [L4Configurator lineBreakChar]];
    }
    NS_HANDLER
        // ### TODO WTF? WE'RE SCRWEDED HERE ... ABORT? EXIT? RAISE? Write Error Haiku?
    NS_ENDHANDLER
}

@end
