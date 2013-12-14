#import "L4WriterAppender.h"
#import "L4Layout.h"
#import "L4LogEvent.h"
#import "L4LogLog.h"
#import "L4Properties.h"

static NSData *lineBreakChar;

@implementation L4WriterAppender

+ (void)initialize
{
    lineBreakChar = [@"\n" dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
}

- (id) init
{
	self = [super init];
	if( self != nil ) {
		immediateFlush = YES;
	}
	return self;
}

- (id) initWithProperties:(L4Properties *) initProperties
{    
    self = [super initWithProperties:initProperties];
    
    if ( self != nil ) {
        BOOL newImmediateFlush = YES;
        
        // Support for appender.ImmediateFlush in properties configuration file
        if ( [initProperties stringForKey:@"ImmediateFlush"] != nil ) {
            NSString *buf = [[initProperties stringForKey:@"ImmediateFlush"] lowercaseString];
            newImmediateFlush = [buf isEqualToString:@"true"];
        }
        
        [self setImmediateFlush:newImmediateFlush];
    }
    
    return self;
}

- (id) initWithLayout:(L4Layout *)aLayout fileHandle:(NSFileHandle *)aFileHandle
{
	if (!(self = [self init])) return nil; // call designated initializer
	fileHandle= aFileHandle;
	[self set_layout:aLayout];
	return self;
}


- (BOOL) immediateFlush
{
	return immediateFlush;
}

- (void) setImmediateFlush:(BOOL) flush
{
	immediateFlush = flush;
}

- (void) append:(L4LogEvent *) anEvent
{
    @synchronized(self) {
        if([self checkEntryConditions]) {
            [self subAppend:anEvent];
        }
    }
}

- (void) subAppend:(L4LogEvent *) anEvent
{
	[self write:[_layout format:anEvent]];
}

- (BOOL) checkEntryConditions
{
	if( _closed ) {
		[L4LogLog warn:@"Not allowed to write to a closed appender."];
		return NO;
	}

	if( fileHandle == nil ) {
		[L4LogLog error:[@"No file handle for output stream set for the appender named:" stringByAppendingString:_name]];
		return NO;
	}

	if( _layout == nil ) {
		[L4LogLog error:[@"No layout set for the appender named:" stringByAppendingString:_name]];
		return NO;
	}
	
	return YES;
}

- (void) closeWriter
{
	@try {
		[fileHandle closeFile];
	}
	@catch (NSException *localException) {
		[L4LogLog error:[NSString stringWithFormat:@"Could not close file handle:%@\n%@", fileHandle,  localException]];
	}
}

- (void)setFileHandle:(NSFileHandle*)fh
{
    @synchronized(self) {
        if (fileHandle != fh) {
            [self closeWriter];
            fileHandle = nil;
            fileHandle = fh;
        }
    }
}

- (void) reset
{
	[self closeWriter];
}

- (void) write:(NSString *) theString
{
	if( theString != nil )
	{
		@try {
            @synchronized(self) {
                // TODO ### -- NEED UNIX EXPERT IS THIS THE BEST WAY ??
                // TODO - ### - NEED TO WORK ON ENCODING ISSUES (& THEN LATER LOCALIZATION)
                //
                [fileHandle writeData:[theString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
                [fileHandle writeData:lineBreakChar];
            }
		}
		@catch (NSException *localException) {
			[L4LogLog error:[NSString stringWithFormat:@"Appender failed to write string:%@\n%@", theString, localException]];
		}
	}
}

- (void) writeHeader
{
	[self write:[_layout header]];
}

- (void) writeFooter
{
	[self write:[_layout footer]];
}

- (NSStringEncoding) encoding
{
	return encoding;
}

- (void) setEncoding:(NSStringEncoding) newEncoding
{
	encoding = newEncoding;
}

/* ********************************************************************* */
#pragma mark L4AppenderCategory methods
/* ********************************************************************* */
- (void) close // synchronized ... make thread safe???
{
    @synchronized(self) {
        if( !_closed ) {
            _closed = YES;
            [self writeFooter];
            [self reset];
        }
    }
}

- (BOOL) requiresLayout
{
	return YES;
}

@end
// For copyright & license, see LICENSE.
