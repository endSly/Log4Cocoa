/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import "L4Configurator.h"
#import "L4ConsoleAppender.h"
#import "L4Layout.h"
#import "L4Level.h"
#import "L4Logger.h"
#import "L4LoggingEvent.h"

static NSData *lineBreakChar;

@implementation L4Configurator

/* ********************************************************************* */
#pragma mark Class methods
/* ********************************************************************* */
+ (void) initialize
{
	[L4LoggingEvent startTime];
}

+ (void) basicConfiguration
{
	[[L4Logger rootLogger] setLevel: [L4Level debug]];
	[[L4Logger rootLogger] addAppender: [[L4ConsoleAppender alloc] initStandardOutWithLayout: [L4Layout simpleLayout]]];
}

+ (NSData *) lineBreakChar
{
	if( lineBreakChar == nil ) {
		lineBreakChar = [[@"\n" dataUsingEncoding: NSASCIIStringEncoding allowLossyConversion: YES] retain];

	}
	
	return lineBreakChar;
}

@end
