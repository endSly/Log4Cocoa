/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import "L4FileAppender.h"
#import "L4Layout.h"


@implementation L4FileAppender

- (id) init
{
	return [self initWithLayout: nil fileName: nil append: NO];
}

- (id) initWithLayout: (L4Layout *) aLayout fileName: (NSString *) aName
{
	return [self initWithLayout: aLayout fileName: aName append: NO];
}

- (id) initWithLayout: (L4Layout *) aLayout fileName: (NSString *) aName append: (BOOL) flag
{
	return [self initWithLayout: aLayout fileName: aName append: flag];
}

- (void)dealloc
{
	[fileName release];
	fileName = nil;
	
	[super dealloc];
}

- (void)activateOptions
{
	NSFileManager*	fm = nil;
	
	if (fileName != nil) {
		[self setFile: fileName append: append];
	}

	if (fileName == nil || [fileName length] <= 0) {
		[self closeFile];
		[fileName release];
		fileName = nil;
		[self setFileHandle: nil];
		return;
	}
	
	fm = [NSFileManager defaultManager];

	// if file doesn't exist, try to create the file
	if (![fm fileExistsAtPath: fileName]) {
		// if the we cannot create the file, raise a FileNotFoundException
		if (![fm createFileAtPath: fileName contents: nil attributes: nil]) {
			[NSException raise: @"FileNotFoundException" format: @"Couldn't create a file at %@", fileName];
		}
	}

	// if we had a previous file name, close it and release the file handle
	if (fileName != nil) {
		[self closeFile];
	}

	// open a file handle to the file
	[self setFileHandle: [NSFileHandle fileHandleForWritingAtPath: fileName]];

	// check the append option
	if (append) {
		[fileHandle seekToEndOfFile];
	} else {
		[fileHandle truncateFileAtOffset: 0];
	}
}

- (NSString *) fileName
{
	return fileName;
}

- (void) setFileName: (NSString *) aFileName
{
	if (fileName != aFileName) {
		[fileName release];
		fileName = nil;
		fileName = [aFileName retain];
	}
}

- (void) setFile: (NSString *) aFileName append: (BOOL) flag
{
	[self setAppend: flag];
	[self setFileName: aFileName];
}

- (BOOL) append
{
	return append;
}

- (void) setAppend: (BOOL) flag
{
	append = flag;
}

/* ********************************************************************* */
#pragma mark Protected methods
/* ********************************************************************* */
- (void) closeFile
{
	[fileHandle closeFile];
	
	// Deallocate the file handle because trying to read from or write to a closed file raises exceptions.  Sending messages to nil objects are no-ops.
	[fileHandle release];
	fileHandle = nil;
}
@end

