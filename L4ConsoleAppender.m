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
+ (L4ConsoleAppender *) standardOutWithLayout:(L4Layout *)aLayout
{
	return [[[L4ConsoleAppender alloc] initTarget:YES withLayout:aLayout] autorelease];
}

+ (L4ConsoleAppender *) standardErrWithLayout:(L4Layout *)aLayout
{
	return [[[L4ConsoleAppender alloc] initTarget:NO withLayout:aLayout] autorelease];
}

/* ********************************************************************* */
#pragma mark Instance methods
/* ********************************************************************* */
- (id) init
{
	return [self initTarget:YES withLayout:[L4Layout simpleLayout]];
}

- (id) initTarget:(BOOL)standardOut withLayout:(L4Layout *)aLayout
{
	self = [super init];
	if( self != nil ) {
		if( standardOut ) {
			[self setStandardOut];
		} else {
			[self setStandardErr];
		}
		[self setLayout:aLayout];
	}
	return self;
}

- (BOOL) isStandardOut
{
	return isStandardOut;
}

/* ********************************************************************* */
#pragma mark L4Appender protocol methods
/* ********************************************************************* */
- (id) initWithProperties:(L4Properties *)initProperties
{    
    self = [super initWithProperties:initProperties];
    if ( self != nil ) {
        BOOL logToStandardOut = YES;
        
        // Support for appender.LogToStandardOut in properties configuration file
        if ( [initProperties stringForKey:@"LogToStandardOut"] != nil ) {
            NSString *buf = [[initProperties stringForKey:@"LogToStandardOut"] lowercaseString];
            logToStandardOut = [buf isEqualToString:@"true"];
        }
        
        if( logToStandardOut ) {
            [self setStandardOut];
        } else {
            [self setStandardErr];
        }
    }
    
    return self;
}


/* ********************************************************************* */
#pragma mark Private methods
/* ********************************************************************* */
- (void) setStandardOut
{
    @synchronized(self) {
        if(!isStandardOut || (fileHandle == nil)) {
            isStandardOut = YES;
            [fileHandle autorelease];
            fileHandle = [[NSFileHandle fileHandleWithStandardOutput] retain];
        }
    }
}

- (void) setStandardErr
{
    @synchronized(self) {
        if(isStandardOut || (fileHandle == nil)) {
            isStandardOut = NO;
            [fileHandle autorelease];
            fileHandle = [[NSFileHandle fileHandleWithStandardError] retain];
        }
    }
}


@end
