/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import "L4Level.h"

@implementation L4Level

// L4_ALL < L4_DEBUG < L4_INFO < L4_WARN < L4_ERROR < L4_FATAL < L4_OFF

static L4Level *L4_OFF   = nil;
static L4Level *L4_FATAL = nil;
static L4Level *L4_ERROR = nil;
static L4Level *L4_WARN  = nil;
static L4Level *L4_INFO  = nil;
static L4Level *L4_DEBUG = nil;
static L4Level *L4_ALL   = nil;

/* ********************************************************************* */
#pragma mark Class methods
/* ********************************************************************* */
+ (void) initialize
{
	L4_OFF		= [[L4Level level:OFF_INT    withName:@"OFF"	syslogEquivalent:0 ] retain];
	L4_FATAL	= [[L4Level level:FATAL_INT	withName:@"FATAL"	syslogEquivalent:0 ] retain];
	L4_ERROR	= [[L4Level level:ERROR_INT	withName:@"ERROR"	syslogEquivalent:3 ] retain];
	L4_WARN		= [[L4Level level:WARN_INT	withName:@"WARN"	syslogEquivalent:4 ] retain];
	L4_INFO		= [[L4Level level:INFO_INT	withName:@"INFO"	syslogEquivalent:6 ] retain];
	L4_DEBUG	= [[L4Level level:DEBUG_INT	withName:@"DEBUG"	syslogEquivalent:7 ] retain];
	L4_ALL		= [[L4Level level:ALL_INT    withName:@"ALL"	syslogEquivalent:7 ] retain];
}

+ (L4Level *) level:(int)aLevel withName:(NSString *)aName syslogEquivalent:(int)sysLogLevel
{
	return [[[L4Level alloc] initLevel:aLevel withName:aName syslogEquivalent:sysLogLevel] autorelease];
}

+ (L4Level *) off
{
	return L4_OFF;
}

+ (L4Level *) fatal
{
	return L4_FATAL;
}

+ (L4Level *) error
{
	return L4_ERROR;
}

+ (L4Level *) warn
{
	return L4_WARN;
}

+ (L4Level *) info
{
	return L4_INFO;
}

+ (L4Level *) debug
{
	return L4_DEBUG;
}

+ (L4Level *) all
{
	return L4_ALL;
}

+ (L4Level *) levelWithName:(NSString *) aLevel
{
	return [L4Level levelWithName:aLevel defaultLevel:L4_DEBUG];
}

+ (L4Level *) levelWithName:(NSString *) aLevel defaultLevel:(L4Level *) defaultLevel
{
	NSString *theLevel;

	if( aLevel == nil ) { return defaultLevel; }

	theLevel = [aLevel uppercaseString];

	if( [theLevel isEqualToString:@"ALL"] )   { return L4_ALL; }
	if( [theLevel isEqualToString:@"DEBUG"] ) { return L4_DEBUG; }
	if( [theLevel isEqualToString:@"INFO"] )  { return L4_INFO; }
	if( [theLevel isEqualToString:@"WARN"] )  { return L4_WARN; }
	if( [theLevel isEqualToString:@"ERROR"] ) { return L4_ERROR; }
	if( [theLevel isEqualToString:@"FATAL"] ) { return L4_FATAL; }
	if( [theLevel isEqualToString:@"OFF"] )   { return L4_OFF; }

	return defaultLevel;
}


+ (L4Level *) levelWithInt:(int) aLevel
{
	return [L4Level levelWithInt:aLevel defaultLevel:L4_DEBUG];
}

+ (L4Level *) levelWithInt:(int) aLevel defaultLevel:(L4Level *) defaultLevel
{
	switch( aLevel ) {
		case ALL_INT:  return L4_ALL;
		case DEBUG_INT:return L4_DEBUG;
		case INFO_INT: return L4_INFO;
		case WARN_INT: return L4_WARN;
		case ERROR_INT:return L4_ERROR;
		case FATAL_INT:return L4_FATAL;
		case OFF_INT:  return L4_OFF;

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
	return [[L4Level debug] retain]; // ok since not mutable and no "set" methods exist.
}

- (id) initLevel:(int)aLevel withName:(NSString *)aName syslogEquivalent:(int)sysLogLevel
{
	self = [super init];
	if( self != nil ) {
		intValue = aLevel;
		syslogEquivalent = sysLogLevel;
		name = [aName copy];
	}
	return self;
}

- (BOOL) isEqual:(id)anotherObject
{
	BOOL isEqual = NO;
	if (anotherObject != nil || [anotherObject isKindOfClass:[L4Level class]]) {
		L4Level *otherLevel = (L4Level *)anotherObject;
		if ([otherLevel intValue] == [self intValue] && [[otherLevel stringValue] isEqualToString:[self stringValue]]) {
			isEqual = YES;
		}
	}
	return isEqual;
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

- (BOOL) isGreaterOrEqual:(L4Level *) aLevel
{
	return intValue >= aLevel->intValue;
}

// ### NOTE:I think this name is more apporopriate, but not changing it right now.
- (BOOL) isEnabledFor:(L4Level *) aLevel
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
