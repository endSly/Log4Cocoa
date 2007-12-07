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

#import "L4AppenderSkeleton.h"


@implementation L4AppenderSkeleton

- (void) dealloc
{
    [name release];
    [layout release];
    [threshold release];
    [headFilter release];
    [tailFilter release];
    [super dealloc];
}

- (void) append: (L4LoggingEvent *) anEvent
{
}

- (BOOL) isAsSevereAsThreshold: (L4Level *) aLevel
{
    return ((threshold == nil) || ([aLevel isGreaterOrEqual: threshold]));
}

- (L4Level *) threshold
{
    return threshold;
}

- (void) setThreshold: (L4Level *) aLevel
{
    if( threshold != aLevel )
    {
        [threshold autorelease];
        threshold = [aLevel retain];
    }
}

@end


@implementation L4AppenderSkeleton (L4OptionHandlerCategory)

- (void) activateOptions
{
}

@end


@implementation L4AppenderSkeleton (L4AppenderCategory)

// calls [self append: anEvent] after doing threshold checks
- (void) doAppend: (L4LoggingEvent *) anEvent
{
    L4Filter *aFilter = [self headFilter];
    BOOL breakLoop = NO;
    
    if( closed )
    {
        [L4LogLog error:
            [@"Attempted to append to closed appender named: " stringByAppendingString: name]];
        return;
    }

    if(![self isAsSevereAsThreshold: [anEvent level]])
    {
        return;
    }

    while((aFilter != nil) && !breakLoop)
    {
        switch([aFilter decide: anEvent])
        {
            case FILTER_DENY:
                return;
            case FILTER_ACCEPT:
                breakLoop = YES;
                break;
            case FILTER_NEUTRAL:
            default:
                aFilter = [aFilter next];
                break;
        }
    }
    [self append: anEvent]; // passed all threshold checks, append event.
}

- (void) addFilter: (L4Filter *) newFilter
{
    if( headFilter == nil )
    {
        headFilter = [newFilter retain];
        tailFilter = newFilter; // don't retain at the tail, just the head.
    }
    else
    {
        [tailFilter setNext: newFilter];
        tailFilter = newFilter;
    }
    
}

- (L4Filter *) headFilter
{
    return headFilter;
}

- (void) clearFilters
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    id aFilter = [headFilter next];
    [headFilter autorelease];
    for( aFilter = headFilter; aFilter != nil; aFilter = [headFilter next] )
    {
        [aFilter setNext: nil];
    }
    headFilter = nil;
    tailFilter = nil;

    [pool release];
}

- (void) close
{
}

- (BOOL) requiresLayout
{
    return NO;
}

- (NSString *) name
{
    return name;
}

- (void) setName: (NSString *) aName
{
    if( name != aName )
    {
        [name autorelease];
        name = [aName retain];
    }
}

- (L4Layout *) layout
{
    return layout;
}

- (void) setLayout: (L4Layout *) aLayout
{
    if( layout != aLayout )
    {
        [layout autorelease];
        layout = [aLayout retain];
    }
}

- (id <L4ErrorHandler>) errorHandler
{
    return errorHandler;
}

- (void) setErrorHandler: (id <L4ErrorHandler>) anErrorHandler
{
    if( anErrorHandler == nil )
    {
        [L4LogLog warn: @"You have tried to set a null error-handler."];
    }
    else if( errorHandler != (id) anErrorHandler )
    {
        [errorHandler autorelease];
        errorHandler = [anErrorHandler retain];
    }
}

@end
