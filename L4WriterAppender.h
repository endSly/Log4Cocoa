#import <Foundation/Foundation.h>
#import "L4AppenderProtocols.h"
#import "L4AppenderSkeleton.h"

/**
 * An extension of L4Appender that knows how to append by writing to a filehandle.
 */
@interface L4WriterAppender : L4AppenderSkeleton
{
	BOOL immediateFlush; /**< Flush after write; default is YES. */
	NSStringEncoding encoding; /**< The string encoding to use; default is lossy ASCII.*/
	BOOL lossyEncoding;	/**< Whether to allow lossy string encoding; default is YES.*/
	NSFileHandle *fileHandle; /**< The file we are writing to.*/
}

/**
 * Default init method.
 * @return the new instance.
 */
- (id) init;

/**
 * Creates a new appneder with the provided info.
 * @param aLayout the layout to use for this appender.
 * @param aFileHandle an exisiting file handle to write to.
 * @return the new instance.
 */
- (id) initWithLayout:(L4Layout *)aLayout fileHandle:(NSFileHandle *)aFileHandle;

/**
 * Initializes an instance from properties.  The properties supported are:
 * - <c>ImmediateFlush:</c> see setImmediateFlush:
 * If the values are being set in a file, this is how they could look:
 *	<code>log4cocoa.appender.A2.ImmediateFlush=false</code>
 * @param initProperties the proterties to use.
 */
- (id) initWithProperties:(L4Properties *)initProperties;

/**
 * Mutator for immediateFlush attribute.
 * @param flush YES to flush immediatly, NO to not do so.
 */
- (void) setImmediateFlush:(BOOL)flush;

/**
 *  Reminder: the nesting of calls is:
 * 
 * 	doAppend()
 * 	  - check threshold
 * 	  - filter
 * 	  - append();
 * 		- checkEntryConditions();
 * 		- subAppend();
 */
- (void) append:(L4LoggingEvent *)anEvent;

/**
 * Actual writing occurs here.
 *  
 * <p>Most subclasses of <code>WriterAppender</code> will need to
 * override this method.
 */
- (void) subAppend:(L4LoggingEvent *)anEvent;

/**
 * NOTE --- this method adds a lineBreakChar between log messages.
 * So layouts & log messages do not need to add a trailing line break.
 */
- (void) write:(NSString *)theString;

/**
 * Sets the NSFileHandle where the log output will go.
 * @param fh The NSFileHandle where you want the log output to go.
 */
- (void)setFileHandle:(NSFileHandle *)fh;

/**
 * This method determines if there is a sense in attempting to append.
 * 
 * <p>It checks whether there is a set output target and also if
 * there is a set layout. If these checks fail, then the boolean
 * value <code>false</code> is returned. 
 */
- (BOOL) checkEntryConditions;

/**
 * Close the writer.
 * This method will close the file handle associated with this appender. Any further
 * use of the appender will cause an error.
 */
- (void) closeWriter;
/**
 * Close the writer.
 * This method will close the file handle associated with this appender. Any further
 * use of the appender will cause an error.
 */
- (void) reset;

/**
 * Write the header.
 * This method causes the header of the associated layout to be written to the log file.
 */
- (void) writeHeader;

/**
 * Write the footer.
 * This method causes the footer of the associated layout to be written to the log file.
 */
- (void) writeFooter;

/**
 * Accessor for the encoding attribute.
 * @return the current string encoding.
 */
- (NSStringEncoding) encoding;

/**
 * Mutator for the encoding attribute.
 * @param newEncoding the new string encoding to use.
 */
- (void) setEncoding:(NSStringEncoding) newEncoding;

@end

/**
 * The methods needed to conform to the L4AppenderCategory catagory.
 */
@interface L4WriterAppender (L4AppenderCategory)
/**
 * Causes this writer to close.
 */
- (void) close;

/**
 * Determines if this appender requires a layout.
 */
- (BOOL) requiresLayout;

@end
// For copyright & license, see COPYRIGHT.txt.
