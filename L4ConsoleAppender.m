/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import "L4ConsoleAppender.h"
#import "L4Layout.h"

@interface L4ConsoleAppender (Private)
/**
 * Sets this appender up to use stdout.
 */
- (void) setStandardOut;
/**
 * Sets this appender up to use stderr.
 */
- (void) setStandardErr;
@end

@implementation L4ConsoleAppender

/* ********************************************************************* */
#pragma mark Class methods
/* ********************************************************************* */
+ (L4ConsoleAppender *) standardOutWithLayout: (L4Layout *) aLayout
{
	return [[[L4ConsoleAppender alloc] initTarget: YES withLayout: aLayout] autorelease];
}

+ (L4ConsoleAppender *) standardErrWithLayout: (L4Layout *) aLayout
{
	return [[[L4ConsoleAppender alloc] initTarget: NO withLayout: aLayout] autorelease];
}

/* ********************************************************************* */
#pragma mark Instance methods
/* ********************************************************************* */
- (id) init
{
	self = [super init];
	return self;
}

- (id) initTarget: (BOOL) standardOut withLayout: (L4Layout *) aLayout
{
	self = [super init];
	if( self != nil ) {
		if( standardOut ) {
			[self setStandardOut];
		} else {
			[self setStandardErr];
		}
		[self setLayout: aLayout];
	}
	return self;
}

- (BOOL) isStandardOut
{
	return isStandardOut;
}

/* ********************************************************************* */
#pragma mark Private methods
/* ********************************************************************* */
- (void) setStandardOut
{
	if(!isStandardOut || (fileHandle == nil)) {
		isStandardOut = YES;
		[fileHandle autorelease];
		fileHandle = [[NSFileHandle fileHandleWithStandardOutput] retain];
	}
}

- (void) setStandardErr
{
	if(isStandardOut || (fileHandle == nil)) {
		isStandardOut = NO;
		[fileHandle autorelease];
		fileHandle = [[NSFileHandle fileHandleWithStandardError] retain];
	}
}


@end
