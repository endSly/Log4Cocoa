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

/*!
	@header L4FileAppender
	@discussion The L4FileAppender does not support buffering configuration.  Any methods or arguments that refer to buffering are ignored.
*/

// #import "Log4Cocoa.h"
#import <Foundation/Foundation.h>
#import "L4WriterAppender.h"
#import "L4Layout.h"

/*!
	@class L4FileAppender
	@discussion This appender appends logging messages to a file whose path you specify.  This class is a subclass of L4WriterAppender.
*/
@interface L4FileAppender : L4WriterAppender
{
	BOOL			_append;
	//BOOL			_bufferedIO; // always NO because NSFileHandle automatically handles buffering, and we don't want to give users the illusion that they can control buffering
	//unsigned int	_bufferSize; // always 0 because NSFileHandle automatically handles buffering, and we don't want to give users the illusion that they can control buffering
	NSString*		_fileName;
}

/*!
	@method init
	@abstract A basic initializer.
	@discussion This method calls <code>initWithLayout:fileName:append:bufferIO:bufferSize:</code> with layout and file name set to nil, append is NO, bufferIO is NO, bufferSize is 0
	@result An initialized L4FileAppender object
*/
- (id) init;

/*!
	@method initWithLayout:fileName:
	@abstract Initializes an L4FileAppender instance with the specified layout and file path name.
	@discussion This method calls <code>initWithLayout:fileName:append:bufferIO:bufferSize:</code> with the specified layout and file name, append is NO, bufferIO is NO, bufferSize is 0
	@param aLayout The layout that this appender should use
	@param aName The file path of the file you want log output to be written to.  If the file does not exist, it will be created if possible.  If the file cannot be created for some reason, a FileNotFoundException will be raised.
	@result An initialized L4FileAppender object
*/
- (id) initWithLayout: (L4Layout *) aLayout
             fileName: (NSString *) aName;  // throws IOException

/*!
	@method initWithLayout:fileName:append:
	@abstract Initializes an L4FileAppender instance with the specified layout, file path name, and append option.
	@discussion This method calls <code>initWithLayout:fileName:append:bufferIO:bufferSize:</code> with the specified layout, file name, and append option, bufferIO is NO, bufferSize is 0
	@param aLayout The layout that this appender should use
	@param aName The file path of the file you want log output to be written to.  If the file does not exist, it will be created if possible.  If the file cannot be created for some reason, a FileNotFoundException will be raised.
	@param append YES = log output should be appended to the file.  NO = the file's previous contents should be overwritten
	@result An initialized L4FileAppender object
*/
- (id) initWithLayout: (L4Layout *) aLayout
             fileName: (NSString *) aName
               append: (BOOL) append;   // throws IOException

/*!
	@method initWithLayout:fileName:append:bufferIO:bufferSize:
	@abstract Initializes an L4FileAppender instance with the specified layout, file path name, append option, and buffering options.
	@discussion This is the class's designated initializer.  The bufferIO and bufferSize arguments are ignored.
	@param aLayout The layout that this appender should use
	@param aName The file path of the file you want log output to be written to.  If the file does not exist, it will be created if possible.  If the file cannot be created for some reason, a FileNotFoundException will be raised.
	@param append YES = log output should be appended to the file.  NO = the file's previous contents should be overwritten.
	@param bufferedIO This argument is ignored.
	@param bufferSize This argument is ignored.
	@result An initialized L4FileAppender object
*/
- (id) initWithLayout: (L4Layout *) aLayout
             fileName: (NSString *) aName
               append: (BOOL) append
             bufferIO: (BOOL) bufferedIO
           bufferSize: (int) buffereSize;  // throws IOException

/*!
	@method activateOptions
	@discussion Activate the options that were previously set with calls to option setters.
	
		This allows to defer activiation of the options until all options have been set. This is required for objects which have related options that remain ambigous until all are set.

		For example, the L4FileAppender has the fileName and append options both of which are ambigous until the other is also set.  So if you call <code>setFileName:</code> or <code>setAppend:</code> in your code, you have to call this method to have your changes take effect.
*/
- (void) activateOptions;

/*!
	@method fileName
	@abstract Returns the path to the file to which log output should be written.
	@result The path to the file to which log output should be written.
*/
- (NSString *) fileName;

/*!
	@method setFileName:
	@abstract Sets the path to the file to which you want log output written.
	@discussion If you use this method, make sure you call <code>activateOptions</code> to have it take effect.
	@param fileName The path to the file to which you want log output written.
*/
- (void) setFileName: (NSString *) fileName;

/*!
	@method setFile:append:bufferedIO:bufferSize:
	@abstract Sets the file name and append options simultaneously.
	@discussion If you use this method, make sure you call <code>activateOptions</code> to have it take effect.
	@param fileName The path to the file to which you want log output written
	@param append YES = append output to the end of the file, NO = overwrite the previous contents of the file when the file is opened for logging output
	@param bufferedIO This argument is ignored
	@param bufferSize This argument is ignored
*/
- (void) setFile: (NSString *) fileName
          append: (BOOL) append
      bufferedIO: (BOOL) bufferedIO
      bufferSize: (int) size; // synchronized ... make thread safe?? throws IOException

/*!
	@method append
	@abstract Returns the append option of this object.
	@result YES = output will be appended to the end of the file, NO = output will overwrite the previous contents of the file
*/
- (BOOL) append;

/*!
	@method setAppend:
	@abstract Sets the append option for this object
	@discussion If you use this method, make sure you call <code>activateOptions</code> to have it take effect.
	@param append YES = append output to the end of the file, NO = overwrite the previous contents of the file when the file is opened for logging output
*/
- (void) setAppend: (BOOL) append;

/*!
	@method bufferedIO
	@abstract This method always returns NO, since buffering configuration is ignored
	@result This method always returns NO
*/
- (BOOL) bufferedIO;

/*!
	@method setBufferedIO:
	@abstract This method does nothing.
	@param buffer This argument is ignored
*/
- (void) setBufferedIO: (BOOL) buffer;

/*!
	@method bufferSize
	@abstract This method always returns 0, since buffering configuration is ignored
	@result This method always returns 0
*/
- (int) bufferSize;

/*!
	@method setBufferSize:
	@abstract This method does nothing.
	@param size This argument is ignored
*/
- (void) setBufferSize: (int) size;

/*********************8
- (void) setQWForFiles: (WRITER) aWriter; // NSFileHandle??
*/
@end

/*!
	@category L4FileAppender (__ProtectedMethods)
	@discussion These methods are "protected" methods and should not be called except by subclasses.
*/
@interface L4FileAppender (__ProtectedMethods)

/*!
	@method closeFile
	@abstract This method closes and releases the underlying file handle.
*/
- (void) closeFile;

@end