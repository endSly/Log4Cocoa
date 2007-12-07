/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import <Foundation/Foundation.h>
#import "L4AppenderProtocols.h"
#import "L4AppenderSkeleton.h"

@interface L4WriterAppender : L4AppenderSkeleton
{
    BOOL immediateFlush;        // default is YES
    NSStringEncoding encoding;  // default is lossy ASCII
    BOOL lossyEncoding;         // default is YES
    NSFileHandle *fileHandle;
    // L4QuietWriter // actual writer ?!?
}

- (id) init;

/*
- (id) initWithLayout: (L4Layout *) aLayout
          ouputStream: (NSFileHandle *) os;

- (id) initWithLayout: (L4Layout *) aLayout
               writer: (NSFileHandle *) aWriter;
*/
- (id) initWithLayout: (L4Layout *) aLayout
           fileHandle: (NSFileHandle *) aFileHandle;

- (BOOL) immediateFlush;
- (void) setImmediateFlush: (BOOL) flush;

// Reminder: the nesting of calls is:
//
//    doAppend()
//      - check threshold
//      - filter
//      - append();
//        - checkEntryConditions();
//        - subAppend();
//
- (void) append: (L4LoggingEvent *) anEvent;
- (void) subAppend: (L4LoggingEvent *) anEvent;
- (void) write: (NSString *) theString; // does the actual writing

/*!
	@method setFileHandle:
	@abstract Sets the NSFileHandle where the log output will go
	@param fh The NSFileHandle where you want the log output to go
*/
- (void)setFileHandle: (NSFileHandle *) fh;

/**
This method determines if there is a sense in attempting to append.

<p>It checks whether there is a set output target and also if
there is a set layout. If these checks fail, then the boolean
value <code>false</code> is returned. */
- (BOOL) checkEntryConditions;

- (void) closeWriter;
- (void) reset;

/******************* ### TODO
- (OUTPUT_STREAM) createWriter: (OUTPUT_STREAM) os;
- (void) setWriter: (WRITER) aWriter; // synchronized ... make thread safe??
*/
- (void) writeHeader;
- (void) writeFooter;

- (NSStringEncoding) encoding;
- (void) setEncoding: (NSStringEncoding) newEncoding;

@end


@interface L4WriterAppender (L4OptionHandlerCategory) <L4OptionHandler>

- (void) activateOptions;

@end


@interface L4WriterAppender (L4AppenderCategory)

- (void) close; // synchronized ... make thread safe???
- (BOOL) requiresLayout;

@end


