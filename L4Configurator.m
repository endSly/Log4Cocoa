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

+ (void) initialize
{
    // Making sure that we capture the startup time of
    // this application.  This sanity check is also in
    // +[L4Logger initialize] too.
    //
    [L4LoggingEvent startTime];
}

+ (void) basicConfiguration
{
    [[L4Logger rootLogger] setLevel: [L4Level debug]];
    [[L4Logger rootLogger] addAppender:
        [[L4ConsoleAppender alloc] initStandardOutWithLayout: [L4Layout simpleLayout]]];
}

+ (void) autoConfigure
{
    // [[NSFileManager defaultManager] currentDirectoryPath];
}

+ (id) propertyForKey: (NSString *) aKey
{
    return nil;
}

+ (void) resetLineBreakChar
{
    [lineBreakChar autorelease];
    lineBreakChar = nil;
}

+ (NSData *) lineBreakChar
{
    if( lineBreakChar == nil )
    {
        id breakChar = [self propertyForKey: LINE_BREAK_SEPERATOR_KEY];
        if( breakChar != nil )
        {
            lineBreakChar = [[breakChar dataUsingEncoding: NSASCIIStringEncoding
                                     allowLossyConversion: YES] retain];
        }
        else
        {
            // DEFAULT VALUE
            lineBreakChar = [[@"\n" dataUsingEncoding: NSASCIIStringEncoding
                                 allowLossyConversion: YES] retain];
        }
    }

    return lineBreakChar;
}

@end
