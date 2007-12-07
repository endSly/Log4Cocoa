/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import "L4LogManager.h"
#import "L4RootLogger.h"
#import "L4Level.h"
#import "L4LoggerStore.h"
#import "L4LogLog.h"

static id guard = nil;
static id <L4RepositorySelector> repositorySelector = nil;
static id <L4LoggerRepository> _loggerRepository = nil;

@implementation L4LogManager

// ### TODO - Add all of the Log4J configuration stuff, right now just
//            putting in some sensible defaults.
//
+ (void) initialize
{
    id rootLogger = [[L4RootLogger alloc] initWithLevel: [L4Level debug]];
    repositorySelector = [[L4LoggerStore alloc] initWithRoot: rootLogger];
#ifndef USE_REPOSITORY_SELECTOR
    _loggerRepository = [[repositorySelector loggerRepository] retain];
#endif
    [rootLogger release];
}

+ (int) setRepositorySelector: (id <L4RepositorySelector>) aSelector
                        guard: (id) aGuard
{
    if(( guard != nil ) && ( guard != aGuard ))
    {
        [L4LogLog warn: @"Attempted to reset the LoggerFactory without possessing the guard."];
        return GUARD_ERROR_CODE;
    }

    if( aSelector == nil )
    {
        [L4LogLog warn: @"RepositorySelector must be non-null."];
        return NO_SELECTOR_ERROR_CODE;
    }

    guard = aGuard;
    [repositorySelector autorelease];
    repositorySelector = [aSelector retain];

#ifndef USE_REPOSITORY_SELECTOR
    [_loggerRepository autorelease];
    _loggerRepository = [[repositorySelector loggerRepository] retain];
#endif
    
    return NO_ERROR;
}

+ (id <L4LoggerRepository>) loggerRepository
{
#ifdef USE_REPOSITORY_SELECTOR
    return [repositorySelector loggerRepository];
#else
    return _loggerRepository;
#endif
}

+ (L4Logger *) rootLogger
{
#ifdef USE_REPOSITORY_SELECTOR
    return [[repositorySelector loggerRepository] rootLogger];
#else
    return [_loggerRepository rootLogger];
#endif
}

+ (L4Logger *) loggerForClass: (Class) aClass
{
#ifdef USE_REPOSITORY_SELECTOR
    return [[repositorySelector loggerRepository] loggerForClass: aClass];
#else
    return [_loggerRepository loggerForClass: aClass];
#endif
}

+ (L4Logger *) loggerForName: (NSString *) aName
{
#ifdef USE_REPOSITORY_SELECTOR
    return [[repositorySelector loggerRepository] loggerForName: aName];
#else
    return [_loggerRepository loggerForName: aName];
#endif
}

+ (L4Logger *) loggerForName: (NSString *) aName
                     factory: (id <L4LoggerFactory>) aFactory
{
#ifdef USE_REPOSITORY_SELECTOR
    return [[repositorySelector loggerRepository] loggerForName: aName
                                                        factory: aFactory];
#else
    return [_loggerRepository loggerForName: aName
                                    factory: aFactory];
#endif
}

+ (L4Logger *) exists: (id) loggerNameOrLoggerClass
{
#ifdef USE_REPOSITORY_SELECTOR
    return [[repositorySelector loggerRepository] exists: loggerNameOrLoggerClass];
#else
    return [_loggerRepository exists: loggerNameOrLoggerClass];
#endif
}

+ (NSArray *) currentLoggersArray
{
#ifdef USE_REPOSITORY_SELECTOR
    return [[repositorySelector loggerRepository] currentLoggersArray];
#else
    return [_loggerRepository currentLoggersArray];
#endif
}

+ (NSEnumerator *) currentLoggers
{
#ifdef USE_REPOSITORY_SELECTOR
    return [[repositorySelector loggerRepository] currentLoggers];
#else
    return [_loggerRepository currentLoggers];
#endif
}

+ (void) shutdown
{
#ifdef USE_REPOSITORY_SELECTOR
    return [[repositorySelector loggerRepository] shutdown];
#else
    return [_loggerRepository shutdown];
#endif
}

+ (void) resetConfiguration
{
#ifdef USE_REPOSITORY_SELECTOR
    return [[repositorySelector loggerRepository] resetConfiguration];
#else
    return [_loggerRepository resetConfiguration];
#endif
}


@end
