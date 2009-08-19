#import "L4WriterAppender.h"
#import "L4Layout.h"
#import "L4LoggingEvent.h"
#import "L4LogLog.h"

static NSData *lineBreakChar;

@implementation L4WriterAppender

+ (void) initialize
{
    lineBreakChar = [[@"\n" dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES] retain];
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
	[self init]; // call designated initializer
	fileHandle= [aFileHandle retain];
	[self setLayout:aLayout];
	return self;
}

- (void) dealloc
{
	[fileHandle release];
	[super dealloc];
}

- (BOOL) immediateFlush
{
	return immediateFlush;
}

- (void) setImmediateFlush:(BOOL) flush
{
	immediateFlush = flush;
}

- (void) append:(L4LoggingEvent *) anEvent
{
    @synchronized(self) {
        if([self checkEntryConditions]) {
            [self subAppend:anEvent];
        }
    }
}

- (void) subAppend:(L4LoggingEvent *) anEvent
{
	[self write:[layout format:anEvent]];
}

- (BOOL) checkEntryConditions
{
	if( closed ) {
		[L4LogLog warn:@"Not allowed to write to a closed appender."];
		return NO;
	}

	if( fileHandle == nil ) {
		[L4LogLog error:[@"No file handle for output stream set for the appender named:" stringByAppendingString:name]];
		return NO;
	}

	if( layout == nil ) {
		[L4LogLog error:[@"No layout set for the appender named:" stringByAppendingString:name]];
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
            [fileHandle release];
            fileHandle = nil;
            fileHandle = [fh retain];
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
	[self write:[layout header]];
}

- (void) writeFooter
{
	[self write:[layout footer]];
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
        if( !closed ) {
            closed = YES;
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
// For copyright & license, see COPYRIGHT.txt.
