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

#import "L4FileAppender.h"


@implementation L4FileAppender

- (id) init
{
    return [self initWithLayout: nil fileName: nil append: NO bufferIO: NO bufferSize: 0];
}

- (id) initWithLayout: (L4Layout *) aLayout
             fileName: (NSString *) aName  // throws IOException
{
    return [self initWithLayout: aLayout fileName: aName append: NO bufferIO: NO bufferSize: 0];
}

- (id) initWithLayout: (L4Layout *) aLayout
             fileName: (NSString *) aName
               append: (BOOL) append   // throws IOException
{
    return [self initWithLayout: aLayout fileName: aName append: append bufferIO: NO bufferSize: 0];
}

- (id) initWithLayout: (L4Layout *) aLayout
             fileName: (NSString *) aName
               append: (BOOL) append
             bufferIO: (BOOL) bufferedIO
           bufferSize: (int) bufferSize  // throws IOException
{
    self = [super init];
	
	if (self != nil)
	{
		[self setLayout: aLayout];
		[self setFileName: aName];
		[self setAppend: append];
		[self activateOptions];
	}
	
	return self;
}

- (void)dealloc
{
	[_fileName release];
	_fileName = nil;
	
	[super dealloc];
}

- (void)activateOptions
{
	NSFileManager*	fm = nil;
	
    if (_fileName != nil)
	{
		[self setFile: _fileName append: _append bufferedIO: [self bufferedIO] bufferSize: [self bufferSize]];
	}

	if (_fileName == nil || [_fileName length] <= 0)
	{
		[self closeFile];
		[_fileName release];
		_fileName = nil;
		[self setFileHandle: nil];
		return;
	}
    
	fm = [NSFileManager defaultManager];

	// if file doesn't exist, try to create the file
	if (![fm fileExistsAtPath: _fileName])
	{
		// if the we cannot create the file, raise a FileNotFoundException
		if (![fm createFileAtPath: _fileName contents: nil attributes: nil])
		{
			[NSException raise: @"FileNotFoundException" format: @"Couldn't create a file at %@", _fileName];
		}
	}

	// if we had a previous file name, close it and release the file handle
	if (_fileName != nil)
	{
		[self closeFile];
	}

	// open a file handle to the file
	[self setFileHandle: [NSFileHandle fileHandleForWritingAtPath: _fileName]];

	// check the append option
	if (_append)
	{
		[fileHandle seekToEndOfFile];
	}
	else
	{
		[fileHandle truncateFileAtOffset: 0];
	}
}

- (NSString *) fileName
{
    return _fileName;
}

- (void) setFileName: (NSString *) fileName
{
	if (_fileName != fileName)
	{
		[_fileName release];
		_fileName = nil;
		_fileName = [fileName retain];
	}
}

- (void) setFile: (NSString *) fileName
          append: (BOOL) append
      bufferedIO: (BOOL) bufferedIO
      bufferSize: (int) size // synchronized ... make thread safe?? throws IOException
{
	[self setAppend: append];
    [self setFileName: fileName];
}

- (BOOL) append
{
    return _append;
}

- (void) setAppend: (BOOL) append
{
    _append = append;
}

- (BOOL) bufferedIO
{
    return NO;
}

- (void) setBufferedIO: (BOOL) buffer
{
    // do nothing, we don't allow the user to customize buffering
}

- (int) bufferSize
{
    return 0;
}

- (void) setBufferSize: (int) size
{
    // do nothing, we don't allow the user to customize buffering
}

@end

@implementation L4FileAppender (__ProtectedMethods)

- (void) closeFile
{
	[fileHandle closeFile];
	
	// Deallocate the file handle because trying to read from or write to a closed file raises exceptions.  Sending messages to nil objects are no-ops.
	[fileHandle release];
	fileHandle = nil;
}

@end