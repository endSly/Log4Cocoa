/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import "L4LogManager.h"
#import "L4RootLogger.h"
#import "L4Level.h"
#import "L4LoggerStore.h"
#import "L4LogLog.h"

static L4LoggerStore *_loggerRepository = nil;

@implementation L4LogManager

+ (void) initialize
{
	id rootLogger = [[L4RootLogger alloc] initWithLevel: [L4Level debug]];
	_loggerRepository = [[L4LoggerStore alloc] initWithRoot: rootLogger];
	[rootLogger release];
}

+ (id <L4LoggerRepository>) loggerRepository
{
	return _loggerRepository;
}

+ (L4Logger *) rootLogger
{
	return [_loggerRepository rootLogger];
}

+ (L4Logger *) loggerForClass: (Class) aClass
{
	return [_loggerRepository loggerForClass: aClass];
}

+ (L4Logger *) loggerForName: (NSString *) aName
{
	return [_loggerRepository loggerForName: aName];
}

+ (L4Logger *) loggerForName: (NSString *) aName factory: (id <L4LoggerFactory>) aFactory
{
	return [_loggerRepository loggerForName: aName factory: aFactory];
}

+ (NSArray *) currentLoggers
{
	return [_loggerRepository currentLoggers];
}

+ (void) shutdown
{
	return [_loggerRepository shutdown];
}

+ (void) resetConfiguration
{
	return [_loggerRepository resetConfiguration];
}


@end
