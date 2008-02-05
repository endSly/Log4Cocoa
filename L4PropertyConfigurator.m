/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import "L4PropertyConfigurator.h"
#import "L4AppenderProtocols.h"
#import "L4FactoryManager.h"
#import "L4Level.h"
#import "L4LogLog.h"
#import "L4Properties.h"
#import "L4RootLogger.h"

static NSString *DELIM_START = @"${";
static int DELIM_START_LEN = 2;
static NSString *DELIM_STOP = @"}";
static int DELIM_STOP_LEN = 1;

@interface L4PropertyConfigurator (Private)
- (void) configureAdditivity;
- (void) configureAppenders;
- (void) configureLoggers;
- (void) replaceEnvironemntVariables;
- (NSString *) substituteEnvironmentVariablesForString:(NSString *) aString;
@end


@implementation L4PropertyConfigurator
/* ********************************************************************* */
#pragma mark Class methods
/* ********************************************************************* */
+ (id) propertyConfiguratorWithFileName:(NSString *) aName
{
 	return [[[self alloc] initWithFileName: aName] autorelease];
}

+ (id) propertyConfiguratorWithProperties:(L4Properties *) aProperties
{
 	return [[(L4PropertyConfigurator *) [self alloc] initWithProperties: aProperties] autorelease];
}

/* ********************************************************************* */
#pragma mark Instance methods
/* ********************************************************************* */
- (void) configure
{
 	[self configureAppenders];
 	[self configureLoggers];
 	[self configureAdditivity];
	
 	// Erase the appenders to that we are not artificially retaining them.
 	[appenders removeAllObjects];
}

- (void) configureLogger:(L4Logger *) aLogger withProperty:(NSString *) aProperty
{
 	// Remove all whitespace characters from config
 	NSArray *components = [aProperty componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
 	NSEnumerator *componentEnum = [components objectEnumerator];
 	NSString *component = nil;
 	NSString *configString = @"";
 	while ( ( component = [componentEnum nextObject] ) != nil ) {
  		configString = [configString stringByAppendingString: component];
 	}
 	
 	// "Tokenize" configString
 	components = [configString componentsSeparatedByString: @","];
 	
 	if ( [components count] == 0 ) {
  		[L4LogLog error: [NSString stringWithFormat: @"Invalid config string(Logger = %@): \"%@\".", [aLogger name], aProperty]];
  		return;
 	}
 	
 	// Set the loglevel
 	componentEnum = [components objectEnumerator];
 	NSString *logLevel = [[componentEnum nextObject] uppercaseString];
 	if ( ![logLevel isEqualToString: @"INHERITED"] ) {
  		[aLogger setLevel: [L4Level levelWithName: logLevel]];
 	}

 	// Set the Appenders
 	while ( ( component = [componentEnum nextObject] ) != nil ) {
  		id <L4Appender> appender = [appenders objectForKey: component];
  		if ( appender == nil ) {
			[L4LogLog error: [NSString stringWithFormat: @"Invalid appender: \"%@\".", component]];
			continue;
  		}
  		[aLogger addAppender: appender];
 	}
}

- (void)dealloc
{
 	[fileName release];
 	fileName = nil;
	[properties release];
	properties = nil;
 	[appenders release];
 	appenders = nil;
 	
	[super dealloc];
}

- (id) initWithFileName:(NSString *) aName properties:(L4Properties *) aProperties
{
 	if ( self = [super init]) {
  		fileName = [aName retain];
  		properties = aProperties;
  		[self replaceEnvironemntVariables];
  		properties = [[properties subsetForPrefix: @"log4cocoa."] retain];
  		appenders = [[NSMutableDictionary alloc] init];
 	}
 	
 	return self;
}

- (id) init
{
	return nil; // never use this constructor
}

- (id) initWithFileName:(NSString *) aName
{
 	return [self initWithFileName: aName properties: [L4Properties propertiesWithFileName: aName]];
}

- (id) initWithProperties:(L4Properties *) aProperties
{
 	return [self initWithFileName: @"UNAVAILABLE" properties: aProperties];
}

/* ********************************************************************* */
#pragma mark Private methods
/* ********************************************************************* */
- (void) configureAdditivity
{
 	L4Properties *additivityProperties = [properties subsetForPrefix: @"additivity."];
 	
 	NSEnumerator *keyEnum = [[additivityProperties allKeys] objectEnumerator];
 	NSString *key = nil;
 	while ( ( key = [keyEnum nextObject] ) != nil ) {
  		L4Logger *logger = [L4Logger loggerForName: key];
  		NSString *actualValue = [additivityProperties stringForKey: key];
  		NSString *value = [actualValue lowercaseString];
  		if ( [value isEqualToString: @"true"] ) {
			[logger setAdditivity: YES];
  		} else if ( [value isEqualToString: @"false"] ) {
			[logger setAdditivity: NO];
  		} else {
			[L4LogLog error: [NSString stringWithFormat: @"Invalid additivity value for logger %@: \"%@\".", key, actualValue]];
  		}
 	}
}

- (void) configureAppenders
{
 	L4Properties *appendersProperties = [properties subsetForPrefix: @"appender."];
 	
 	NSEnumerator *keyEnum = [[appendersProperties allKeys] objectEnumerator];
 	NSString *key = nil;
 	while ( ( key = [keyEnum nextObject] ) != nil ) {
  		NSRange range = [key rangeOfString: @"." options: 0 range: NSMakeRange(0, [key length])];
  		if ( range.location == NSNotFound ) {
			id <L4Appender> newAppender = nil;
			NSString *className = [appendersProperties stringForKey: key];
			id <L4Factory> appenderFactory = [L4FactoryManager appenderFactory: className];
			
			if ( appenderFactory != nil ) {
				L4Properties *appenderProperties = [appendersProperties subsetForPrefix: [key stringByAppendingString: @"."]];
				newAppender = (id <L4Appender>) [appenderFactory factoryObjectWithProperties: appenderProperties];
			}
			
			if ( newAppender != nil ) {
				[newAppender setName: key];
				[appenders setObject: newAppender forKey: key];
			} else {
				[L4LogLog error: [NSString stringWithFormat: @"Error while creating appender \"%@\" with name \"%@\".", className, key]];
				continue;
			}
  		}
 	}
}

- (void) configureLoggers
{
 	NSString *rootLoggerProperty = [properties stringForKey: @"rootLogger"];
 	if ( [properties stringForKey: @"rootLogger"] != nil ) {
  		[self configureLogger: [L4Logger rootLogger] withProperty: rootLoggerProperty];
 	}
 	
 	L4Properties *loggerProperties = [properties subsetForPrefix: @"logger."];
 	NSEnumerator *keyEnum = [[loggerProperties allKeys] objectEnumerator];
 	NSString *key = nil;
 	while ( ( key = [keyEnum nextObject] ) != nil ) {
  		[self configureLogger: [L4Logger loggerForName: key] withProperty: [loggerProperties stringForKey: key]];
 	}
}

- (void) replaceEnvironemntVariables
{
 	NSEnumerator *keyEnum = [[properties allKeys] objectEnumerator];
 	NSString *key = nil;
 	while ( ( key = [keyEnum nextObject] ) != nil ) {
  		NSString *value = [properties stringForKey: key];
  		NSString *subKey = [self substituteEnvironmentVariablesForString: key];
  		if ( ![subKey isEqualToString: key] ) {
			[properties removeStringForKey: key];
			[properties setString: subKey forKey: value];
  		}
  		NSString *subVal = [self substituteEnvironmentVariablesForString: value];
  		if ( ![subVal isEqualToString: value] ) {
			[properties setString: subVal forKey: subKey];
  		}
 	}
}

- (NSString *) substEnvironVarsForString:(NSString *) aString
{
 	int len = [aString length];
 	NSMutableString *buf = [NSMutableString string];
 	NSRange i = NSMakeRange(0, len);
 	NSRange j, k;
 	while ( true ) {
  		j = [aString rangeOfString: DELIM_START options: 0 range: i];
  		if ( j.location == NSNotFound ) {
			if ( i.location == 0 ) {
				return aString;
			} else {
				[buf appendString: [aString substringFromIndex: i.location]];
				return buf;
			}
  		} else {
			[buf appendString: [aString substringWithRange: NSMakeRange(i.location, j.location - i.location)]];
			k = [aString rangeOfString: DELIM_STOP options: 0 range: NSMakeRange(j.location, len - j.location)];
			if ( k.location == NSNotFound ) {
				[L4LogLog error: 
				 [NSString stringWithFormat: @"\"%@\" has no closing brace. Opening brace at position %@.", 
				  aString, [NSNumber numberWithInt: j.location]]];
				return aString;
			} else {
				j.location += DELIM_START_LEN;
				j = NSMakeRange(j.location, k.location - j.location);
				NSString *key = [aString substringWithRange: j];
				char *replacement = getenv([key UTF8String]);
				if ( replacement != NULL ) {
					[buf appendString: [NSString stringWithUTF8String: replacement]];
				}
				i.location += (k.location + DELIM_STOP_LEN);
				i.length -= i.location;
			}
  		}
 	}
}


@end
