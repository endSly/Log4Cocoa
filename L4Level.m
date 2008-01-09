/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import "L4Level.h"

@implementation L4Level

// ALL < DEBUG < INFO < WARN < ERROR < FATAL < OFF

static L4Level *OFF   = nil;
static L4Level *FATAL = nil;
static L4Level *ERROR = nil;
static L4Level *WARN  = nil;
static L4Level *INFO  = nil;
static L4Level *DEBUG = nil;
static L4Level *ALL   = nil;

/* ********************************************************************* */
#pragma mark Class methods
/* ********************************************************************* */
+ (void) initialize
{
	OFF		= [L4Level withLevel:OFF_INT	withName:@"OFF"		syslogEquivalent:0 ];
	FATAL	= [L4Level withLevel:FATAL_INT	withName:@"FATAL"	syslogEquivalent:0 ];
	ERROR	= [L4Level withLevel:ERROR_INT	withName:@"ERROR"	syslogEquivalent:3 ];
	WARN	= [L4Level withLevel:WARN_INT	withName:@"WARN"	syslogEquivalent:4 ];
	INFO	= [L4Level withLevel:INFO_INT	withName:@"INFO"	syslogEquivalent:6 ];
	DEBUG	= [L4Level withLevel:DEBUG_INT	withName:@"DEBUG"	syslogEquivalent:7 ];
	ALL		= [L4Level withLevel:ALL_INT	withName:@"ALL"		syslogEquivalent:7 ];
}

+ (L4Level *) withLevel:(int)aLevel withName:(NSString *)aName syslogEquivalent:(int)sysLogLevel
{
	return [[L4Level alloc] initLevel: aLevel withName: aName syslogEquivalent: sysLogLevel];
}

+ (L4Level *) off
{
	return OFF;
}

+ (L4Level *) fatal
{
	return FATAL;
}

+ (L4Level *) error
{
	return ERROR;
}

+ (L4Level *) warn
{
	return WARN;
}

+ (L4Level *) info
{
	return INFO;
}

+ (L4Level *) debug
{
	return DEBUG;
}

+ (L4Level *) all
{
	return ALL;
}

+ (L4Level *) levelWithName:(NSString *) aLevel
{
	return [L4Level levelWithName: aLevel defaultLevel: DEBUG];
}

+ (L4Level *) levelWithName:(NSString *) aLevel defaultLevel:(L4Level *) defaultLevel
{
	NSString *theLevel;

	if( aLevel == nil ) { return defaultLevel; }

	theLevel = [aLevel uppercaseString];

	if( [theLevel isEqualToString: @"ALL"] )   { return ALL; }
	if( [theLevel isEqualToString: @"DEBUG"] ) { return DEBUG; }
	if( [theLevel isEqualToString: @"INFO"] )  { return INFO; }
	if( [theLevel isEqualToString: @"WARN"] )  { return WARN; }
	if( [theLevel isEqualToString: @"ERROR"] ) { return ERROR; }
	if( [theLevel isEqualToString: @"FATAL"] ) { return FATAL; }
	if( [theLevel isEqualToString: @"OFF"] )   { return OFF; }

	return defaultLevel;
}


+ (L4Level *) levelWithInt: (int) aLevel
{
	return [L4Level levelWithInt: aLevel defaultLevel: DEBUG];
}

+ (L4Level *) levelWithInt: (int) aLevel defaultLevel: (L4Level *) defaultLevel
{
	switch( aLevel ) {
		case ALL_INT:   return ALL;
		case DEBUG_INT: return DEBUG;
		case INFO_INT:  return INFO;
		case WARN_INT:  return WARN;
		case ERROR_INT: return ERROR;
		case FATAL_INT: return FATAL;
		case OFF_INT:   return OFF;

		default:
			return defaultLevel;
	}
}

/* ********************************************************************* */
#pragma mark Instance methods
/* ********************************************************************* */
- (id) init
{
	[self autorelease];
	return [L4Level debug]; // ok since not mutable and no "set" methods exist.
}

- (id) initLevel: (int) aLevel withName: (NSString *) aName syslogEquivalent: (int) sysLogLevel
{
	self = [super init];
	if( self != nil ) {
		intValue = aLevel;
		syslogEquivalent = sysLogLevel;
		name = [aName retain];
	}
	return self;
}

- (void) dealloc
{
	[name release];
	name = nil;
	[super dealloc];
}

- (NSString *) description
{
	return name;
}

- (int) intValue
{
	return intValue;
}

- (NSString *) stringValue
{
	return name;
}

- (int) syslogEquivalent
{
	return syslogEquivalent;
}

- (BOOL) isGreaterOrEqual: (L4Level *) aLevel
{
	return intValue >= aLevel->intValue;
}

// ### NOTE: I think this name is more apporopriate, but not changing it right now.
- (BOOL) isEnabledFor: (L4Level *) aLevel
{
	return intValue >= aLevel->intValue;
}

- (id) retain
{
	return self;
}

- (oneway void) release
{
	return;
}

@end
