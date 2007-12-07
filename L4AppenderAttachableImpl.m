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

#import "L4AppenderAttachableImpl.h"


@implementation L4AppenderAttachableImpl

- (int) appendLoopOnAppenders: (L4LoggingEvent *) event
{
    int size = 0;

    if( appenderList != nil )
    {
        int i;
        size = [appenderList count];
        for( i = 0; i < size; i++ )
        {
            [[appenderList objectAtIndex: i] doAppend: event];
        }
    }
    return size;
}

@end


@implementation L4AppenderAttachableImpl (L4AppenderAttachableMethods)

- (void) addAppender: (id <L4Appender>) newAppender
{
    if( newAppender == nil )
    {
        return; // sanity check
    }

    if( appenderList == nil )
    {
        // only place appenderList array is recreated if its nil.
        appenderList = [[NSMutableArray alloc] init];
    }

    if(![appenderList containsObject: newAppender])
    {
        [appenderList addObject: newAppender];
        [[NSNotificationCenter defaultCenter] postNotificationName: APPENDER_ADDED_EVENT
                                                            object: newAppender];
    }
}

- (NSEnumerator *) allAppenders
{
    return [appenderList objectEnumerator];
}

- (NSArray *) allAppendersArray
{
    return appenderList;
}

- (id <L4Appender>) appenderWithName: (NSString *) aName
{
    NSEnumerator *enumerator = [appenderList objectEnumerator];
    id <L4Appender> anAppender;

    while ((anAppender = (id <L4Appender>)[enumerator nextObject]))
    {
        if( [[anAppender name] isEqualToString: aName ])
        {
            return anAppender;
        }
    }
    return nil;
}

- (BOOL) isAttached: (id <L4Appender>) appender
{
    if((appender == nil) || (appenderList == nil))
    {
        return NO; // short circuit the test
    }
    return [appenderList containsObject: appender]; 
}

- (void) removeAppenderWithName: (NSString *) aName
{
    [self removeAppender: [self appenderWithName: aName]];
}

- (void) removeAppender: (id <L4Appender>) appender
{
    [appenderList removeObject: appender];
    [[NSNotificationCenter defaultCenter] postNotificationName: APPENDER_REMOVED_EVENT
                                                        object: appender];
}

- (void) removeAllAppenders
{
    NSEnumerator *enumerator = [appenderList objectEnumerator];
    id <L4Appender> anAppender;

    while ((anAppender = (id <L4Appender>)[enumerator nextObject]))
    {
        // why only call close in removeAllAppenders & not removeAppender: ????
        // just doing it like they did it in Log4J ... will figure out later.
        //
        [anAppender close];
        [[NSNotificationCenter defaultCenter] postNotificationName: APPENDER_REMOVED_EVENT
                                                            object: anAppender];
    }
    [appenderList removeAllObjects];
    [appenderList release];
    appenderList = nil;
}

@end