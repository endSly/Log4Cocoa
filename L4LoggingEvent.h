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
#import "L4LoggerProtocols.h"
#import "L4Logger.h"
#import "L4Level.h"
#import "L4RendererMap.h"

// key component is that it is serializable
// there is something going on with NDC & MDC's that I don't understand

// message, timestamp, exception for locaion info.

//  implements java.io.Serializable

@class L4Logger;

@interface L4LoggingEvent : NSObject {
    NSNumber *lineNumber;
    NSString *fileName;
    NSString *methodName;
    L4Logger *logger;
    L4Level *level;
    id message;
    NSString *renderedMessage;
    NSException *exception;
    NSCalendarDate *timestamp;

    char *rawFileName;
    char *rawMethodName;
    int   rawLineNumber;
    
    // NOTE: ALSO FOR NOW I'VE SKIPPED ALL OF THE NDC & MDC STUFF
}

+ (void) initialize;

+ (NSCalendarDate *) startTime;

+ (L4LoggingEvent *) logger: (L4Logger *) aLogger
                      level: (L4Level *) aLevel
                    message: (id) aMessage;

+ (L4LoggingEvent *) logger: (L4Logger *) aLogger
                      level: (L4Level *) aLevel
                    message: (id) aMessage
                  exception: (NSException *) e;

+ (L4LoggingEvent *) logger: (L4Logger *) aLogger
                      level: (L4Level *) aLevel
                 lineNumber: (int) aLineNumber
                   fileName: (char *) aFileName
                 methodName: (char *) aMethodName
                    message: (id) aMessage
                  exception: (NSException *) e;

- (id) initWithLogger: (L4Logger *) aLogger
                level: (L4Level *) aLevel
           lineNumber: (int) aLineNumber
             fileName: (char *) aFileName
           methodName: (char *) aMethodName
              message: (id) aMessage
            exception: (NSException *) e
       eventTimestamp: (NSDate *) aDate;

- (L4Logger *) logger;
- (L4Level *) level;

- (NSNumber *) lineNumber;
- (NSString *) fileName;
- (NSString *) methodName;

- (NSCalendarDate *) timestamp;
- (NSException *) exception;
- (long) millisSinceStart;
- (id) message;
- (NSString *) renderedMessage;

// DO WE NEED ACCESSOR METHODS FOR THE OTHER ELEMENT OF THE EVENT?

// - (NSString *) ndc;
// - (id) mdc: (NSString *) aKey;
// - (void) mdcCopy;

// - (NSString *) threadName;

// - (L4LocationInfo *) locationInformation;
// - (L4ThrowableInfo *) throwableInformation;
// - (NSString *) throwableStrRep;

// -------------------------------------------------------
// ### TODO - THESE ARE ALL PRIVATE METHODS take a look at NSCoder stuff
// -------------------------------------------------------
/*
- (void) readLevel: (INPUT_STREAM) ois;
- (void) readObject: (INPUT_STREAM) ois;
- (void) writeLevel: (OUTPUT_STREAM) oos;
- (void) writeObject: (OUTPUT_STREAM) oos;
*/
@end
