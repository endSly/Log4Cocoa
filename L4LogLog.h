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

#define       L4LogLog_PREFIX @"log4cocoa: "
#define  L4LogLog_WARN_PREFIX @"log4cocoa: WARN: "
#define L4LogLog_ERROR_PREFIX @"log4cocoa: ERROR: "

@interface L4LogLog : NSObject {
}

+ (BOOL) internalDebuggingEnabled;
+ (void) setInternalDebuggingEnabled: (BOOL) enabled;

+ (BOOL) quietModeEnabled;
+ (void) setQuietModeEnabled: (BOOL) enabled;

    /*****
    * If debuging & !quietMode, debug messages get
    * sent to standard out, because Log4Cocoa classes
    * can't use Log4Cocoa loggers.
    */
+ (void) debug: (NSString *) message;
+ (void) debug: (NSString *) message
     exception: (NSException *) e;

    /*****
    * If !quietMode, warn & error messages get
    * sent to standard error, because Log4Cocoa classes
    * can't use Log4Cocoa loggers.
    */
+ (void) warn: (NSString *) message;
+ (void) warn: (NSString *) message
    exception: (NSException *) e;

+ (void) error: (NSString *) message;
+ (void) error: (NSString *) message
     exception: (NSException *) e;

+ (void) writeMessage: (NSString *) message
           withPrefix: (NSString *) prefix
               toFile: (NSFileHandle *) fileHandle
            exception: (NSException *) e;

@end
