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

#import "L4RollingFileAppender.h"
#import "L4Layout.h"
#import "L4LoggingEvent.h"

const unsigned long long kL4RollingFileAppenderDefaultMaxFileSize = (1024 * 1024 * 10);

@interface L4RollingFileAppender (__PrivateMethods)

- (void)_renameLogFile: (unsigned int)backupIndex;

@end


@implementation L4RollingFileAppender

- (id) init
{
    return [self initWithLayout: nil fileName: nil append: YES];
}

- (id) initWithLayout: (L4Layout *) aLayout
             fileName: (NSString *) aName // throws IOException
{
    return [self initWithLayout: aLayout fileName: aName append: YES];
}

- (id) initWithLayout: (L4Layout *) aLayout
             fileName: (NSString *) aName
               append: (BOOL) append // throws IOException
{
    self = [super initWithLayout: aLayout fileName: aName append: append bufferIO: NO bufferSize: 0];
	
	if (self != nil)
	{
		[self setMaxBackupIndex: 1];
		[self setMaximumFileSize: kL4RollingFileAppenderDefaultMaxFileSize];
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (unsigned int)maxBackupIndex
{
    return _maxBackupIndex;
}

- (void)setMaxBackupIndex: (unsigned int)mbi
{
	_maxBackupIndex = mbi;
}

- (unsigned long long)maximumFileSize
{
    return _maxFileSize;
}

- (void)setMaximumFileSize: (unsigned long long)mfs
{
	_maxFileSize = mfs;
}

- (void)rollOver
{
	// if maxBackupIndex is 0, truncate file and create no backups
	if ([self maxBackupIndex] <= 0)
	{
		[fileHandle truncateFileAtOffset: 0];
	}
	else
	{
		// close the current file first
		[self closeFile];
		
		// rename the appropriate files, starting with the current file (whose backup index = 0)
		[self _renameLogFile: 0];
		
		// log file name should be the same, so just call the activeOptions method defined in L4FileAppender
		[self activateOptions];
	}
}

@end

@implementation L4RollingFileAppender (__ProtectedMethods)

- (void)subAppend: (L4LoggingEvent*)event
{
	// if the file's size has exceeded maximumFileSize, roll the file over
	if ([fileHandle offsetInFile] >= [self maximumFileSize])
	{
		[self rollOver];
	}
	
	// use the superclass's subAppend
	[super subAppend: event];
}

@end

@implementation L4RollingFileAppender (__PrivateMethods)

- (void)_renameLogFile: (unsigned int)backupIndex
{
	NSFileManager*	fm = nil;
	NSString*		tempOldFileName = nil;
	NSString*		tempNewFileName = nil;
	NSString*		tempPathExtension = nil;
	
	fm = [NSFileManager defaultManager];
	
	tempPathExtension = [[self fileName] pathExtension];
	
	// if we are trying to rename a backup file > maxBackupIndex
	if (backupIndex >= [self maxBackupIndex])
	{
		if ([tempPathExtension length] <= 0)
		{
			tempOldFileName = [NSString stringWithFormat: @"%@.%d", [[self fileName] stringByDeletingPathExtension], [self maxBackupIndex]];
		}
		else
		{
			tempOldFileName = [NSString stringWithFormat: @"%@.%d.%@", [[[self fileName] stringByDeletingPathExtension] stringByDeletingPathExtension], [self maxBackupIndex], tempPathExtension];
		}
		
		// try to delete the oldest backup file
		if (![fm removeFileAtPath: tempOldFileName handler: nil])
		{
			// if we couldn't delete the file, raise an exception
			[NSException raise: @"CantDeleteFileException" format: @"Unable to delete the file %@", tempOldFileName];
		}
	}
	else
	{
		// if the backupIndex = 0, we haven't renamed this file before
		if (backupIndex == 0)
		{
			tempOldFileName = [self fileName];
		}
		else
		{
			if ([tempPathExtension length] <= 0)
			{
				// create the old name of the file
				tempOldFileName = [NSString stringWithFormat: @"%@.%d", [[self fileName] stringByDeletingPathExtension], backupIndex];
			}
			else
			{
				// create the old name of the file
				tempOldFileName = [NSString stringWithFormat: @"%@.%d.%@", [[[self fileName] stringByDeletingPathExtension] stringByDeletingPathExtension], backupIndex, tempPathExtension];
			}
		}

		// create the new name of the file
		if ([tempPathExtension length] <= 0)
		{
			tempNewFileName = [NSString stringWithFormat: @"%@.%d", [[self fileName] stringByDeletingPathExtension], (backupIndex + 1)];
		}
		else
		{
			tempNewFileName = [NSString stringWithFormat: @"%@.%d.%@", [[[self fileName] stringByDeletingPathExtension] stringByDeletingPathExtension], (backupIndex + 1), tempPathExtension];
		}
		
		// if the new file name already exists, recursively call this method with the new file name's backup index
		if ([fm fileExistsAtPath: tempNewFileName])
		{
			[self _renameLogFile: (backupIndex + 1)];
		}
		
		// rename the old file
		if (![fm movePath: tempOldFileName toPath: tempNewFileName handler: nil])
		{
			[NSException raise: @"CantMoveFileException" format: @"Unable to move file %@ to %@!", tempOldFileName, tempNewFileName];
		}
	}
}

@end