/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import "L4WriterAppender.h"
#import "L4Configurator.h"
#import "L4Layout.h"
#import "L4LoggingEvent.h"
#import "L4LogLog.h"

@implementation L4WriterAppender

- (id) init
{
    self = [super init];
    if( self != nil )
    {
        immediateFlush = YES;
    }
    return self;
}

- (id) initWithLayout: (L4Layout *) aLayout
           fileHandle: (NSFileHandle *) aFileHandle
{
    [self init]; // call designated initializer
    fileHandle= [aFileHandle retain];
    [self setLayout: aLayout];
    return self;
}

- (void) dealloc
{
    [fileHandle release];
    [super dealloc];
}

    /****************
- (id) initWithLayout: (L4Layout *) aLayout
          ouputStream: (OUTPUT_STREAM) os; /// coder???

- (id) initWithLayout: (L4Layout *) aLayout
               writer: (WRITER) aWriter; /// coder???
    */

/*******  NEED TO FIGURE OUT INITIALIZATION STRATAGEY  *********/ 

- (BOOL) immediateFlush
{
    return immediateFlush;
}

- (void) setImmediateFlush: (BOOL) flush
{
    immediateFlush = flush;
}

// Reminder: the nesting of calls is:
//
//    doAppend()
//      - check threshold
//      - filter
//      - append();
//        - checkEntryConditions();
//        - subAppend();
//
- (void) append: (L4LoggingEvent *) anEvent
{
    if([self checkEntryConditions])
    {
        [self subAppend: anEvent];
    }
}

/**
Actual writing occurs here.

<p>Most subclasses of <code>WriterAppender</code> will need to
override this method.*/
- (void) subAppend: (L4LoggingEvent *) anEvent
{
    [self write: [layout format: anEvent]];
}

/**
This method determines if there is a sense in attempting to append.

<p>It checks whether there is a set output target and also if
there is a set layout. If these checks fail, then the boolean
value <code>false</code> is returned. */
- (BOOL) checkEntryConditions
{
    if( closed )
    {
        [L4LogLog warn: @"Not allowed to write to a closed appender."];
        return NO;
    }

    if( fileHandle == nil )
    {
        [[self errorHandler] error: [@"No file handle for output stream set for the appender named: " stringByAppendingString: name]];
        return NO;
    }

    if( layout == nil )
    {
        [[self errorHandler] error: [@"No layout set for the appender named: " stringByAppendingString: name]];
        return NO;
    }
    
    return YES;
}

- (void) closeWriter
{
    NS_DURING
        [fileHandle closeFile];
    NS_HANDLER
        [L4LogLog error:
            [[@"Could not close file handle: " stringByAppendingString:
                [fileHandle description]] stringByAppendingString: [localException description]]];
    NS_ENDHANDLER
}

- (void)setFileHandle: (NSFileHandle*)fh
{
	if (fileHandle != fh)
	{
		[self closeWriter];
		[fileHandle release];
		fileHandle = nil;
		fileHandle = [fh retain];
	}
}

- (void) reset
{
    [self closeWriter];
}

/**
 * NOTE --- this method adds a lineBreakChar between log messages.
 * So layouts & log messages do not need to add a trailing line break.
 */
- (void) write: (NSString *) theString
{
    if( theString != nil )
    {
        NS_DURING
            // TODO ### -- NEED UNIX EXPERT IS THIS THE BEST WAY ??
            // TODO - ### - NEED TO WORK ON ENCODING ISSUES (& THEN LATER LOCALIZATION)
            //
            [fileHandle writeData:
                [theString dataUsingEncoding: NSASCIIStringEncoding
                        allowLossyConversion: YES]];
            [fileHandle writeData: [L4Configurator lineBreakChar]];
        NS_HANDLER
            [[self errorHandler] error:
                [[@"Appender failed to write string:" stringByAppendingString:
                    theString] stringByAppendingString: [localException description]]];
        NS_ENDHANDLER
    }
}

- (void) writeHeader
{
    [self write: [layout header]];
}

- (void) writeFooter
{
    [self write: [layout footer]];
}

- (NSStringEncoding) encoding
{
    return encoding;
}

- (void) setEncoding: (NSStringEncoding) newEncoding
{
    encoding = newEncoding;
}

@end


@implementation L4WriterAppender (L4OptionHandlerCategory)

- (void) activateOptions
{
    // does nothing in this class.
}

@end


@implementation L4WriterAppender (L4AppenderCategory)

- (void) close // synchronized ... make thread safe???
{
    if( !closed )
    {
        closed = YES;
        [self writeFooter];
        [self reset];
    }
}

- (BOOL) requiresLayout
{
    return YES;
}

@end
