/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import "L4FileAppender.h"
#import "L4Layout.h"


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