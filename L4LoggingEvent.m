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

#import "L4LoggingEvent.h"
#import "L4Logger.h"
#import "L4PreprocessorStatics.h"

static NSCalendarDate *startTime = nil;

@implementation L4LoggingEvent

+ (void) initialize
{
    startTime = [[NSCalendarDate calendarDate] retain];
}

+ (NSCalendarDate *) startTime
{
    return startTime;
}

+ (L4LoggingEvent *) logger: (L4Logger *) aLogger
                      level: (L4Level *) aLevel
                    message: (id) aMessage
{
    return [self logger: aLogger
                  level: aLevel
             lineNumber: NO_LINE_NUMBER
               fileName: NO_FILE_NAME
             methodName: NO_METHOD_NAME
                message: aMessage
              exception: nil];
}

+ (L4LoggingEvent *) logger: (L4Logger *) aLogger
                      level: (L4Level *) aLevel
                    message: (id) aMessage
                  exception: (NSException *) e;
{
    return [self logger: aLogger
                  level: aLevel
             lineNumber: NO_LINE_NUMBER
               fileName: NO_FILE_NAME
             methodName: NO_METHOD_NAME
                message: aMessage
              exception: e];
}

+ (L4LoggingEvent *) logger: (L4Logger *) aLogger
                      level: (L4Level *) aLevel
                 lineNumber: (int) aLineNumber
                   fileName: (char *) aFileName
                 methodName: (char *) aMethodName
                    message: (id) aMessage
                  exception: (NSException *) e
{
    return [[[L4LoggingEvent alloc] initWithLogger: aLogger
                                             level: aLevel
                                        lineNumber: aLineNumber
                                          fileName: aFileName
                                        methodName: aMethodName
                                           message: aMessage
                                         exception: e
                                    eventTimestamp: [NSCalendarDate calendarDate]] autorelease];
}

- (id) init
{
    [self autorelease];
    return nil;
}

- (id) initWithLogger: (L4Logger *) aLogger
                level: (L4Level *) aLevel
           lineNumber: (int) aLineNumber
             fileName: (char *) aFileName
           methodName: (char *) aMethodName
              message: (id) aMessage
            exception: (NSException *) e
       eventTimestamp: (NSDate *) aDate
{
    self = [super init];
    if( self != nil )
    {
        rawFileName = aFileName;
        rawMethodName = aMethodName;
        rawLineNumber = aLineNumber;
		
		lineNumber = nil;
		fileName = nil;
		methodName = nil;
		
        logger = [aLogger retain];
        level = [aLevel retain];
        message = [aMessage retain];
        exception = [e retain];
        timestamp = [aDate retain];
    }
    return self;
}

- (void) dealloc
{
    [logger release];
    [level release];
    [message release];
    [exception release];
    [timestamp release];
    if( lineNumber != nil ) [lineNumber release];
    if( fileName != nil )   [fileName release];
    if( methodName != nil ) [methodName release];
    [super dealloc];
}

- (L4Logger *) logger
{
    return logger;
}

- (L4Level *) level
{
    return level;
}

- (NSNumber *) lineNumber
{
    if((lineNumber == nil) && (rawLineNumber != NO_LINE_NUMBER))
    {
        lineNumber = [[NSNumber numberWithInt: rawLineNumber] retain];
    }
	else if (rawLineNumber == NO_LINE_NUMBER)
	{
		lineNumber = [[NSNumber numberWithInt: NO_LINE_NUMBER] retain];
	}
    return lineNumber;
}

- (NSString *) fileName
{
    if((fileName == nil) && (rawFileName != NO_FILE_NAME))
    {
        fileName = [[NSString stringWithCString: rawFileName] retain];
    }
	else if (rawFileName == NO_FILE_NAME)
	{
		fileName = [[NSString stringWithString: @"No file name!"] retain];
	}
    return fileName;
}

- (NSString *) methodName
{
    if((methodName == nil) && (rawMethodName != NO_METHOD_NAME))
    {
        methodName = [[NSString stringWithCString: rawMethodName] retain];
    }
	else if (rawMethodName == NO_METHOD_NAME)
	{
		methodName = [[NSString stringWithString: @"No method name!"] retain];
	}
    return methodName;
}

- (NSCalendarDate *) timestamp
{
    return timestamp;
}

- (NSException *) exception
{
    return exception;
}

- (long) millisSinceStart
{
    // its a double in seconds
    NSTimeInterval time = [timestamp timeIntervalSinceDate: startTime];
    return (long) (time * 1000);
}

- (id) message
{
    return message;
}

- (NSString *) renderedMessage	
{
    if( renderedMessage == nil && message != nil )
    {
        if([message isKindOfClass: [NSString class]])
        {
            renderedMessage = message;  // if its a string return it.
        }
        else
        {
            id <L4LoggerRepository> repository = [logger loggerRepository];
            if([repository conformsToProtocol: @protocol(L4RendererSupport)])
            {
                // try to find a renderer for the message
                //
                id <L4RendererSupport> rs = (id <L4RendererSupport>) repository;
                renderedMessage = [[rs rendererMap] findAndRender: message];
            }
            else
            {
                // when in doubt, call description
                //
                renderedMessage = [message description];
            }
        }
    }
    
    return renderedMessage;
}
    
@end
