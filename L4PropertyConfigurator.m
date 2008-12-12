/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import "L4PropertyConfigurator.h"
#import "L4AppenderProtocols.h"
#import "L4Layout.h"
#import "L4Level.h"
#import "L4LogLog.h"
#import "L4Properties.h"
#import "L4RootLogger.h"

@interface L4PropertyConfigurator (Private)
- (id<L4Appender>) appenderForClassName:(NSString *)appenderClassName andProperties:(L4Properties *)appenderProperties;
- (void) configureAdditivity;

/**
 * Reads through the properties one at a time looking for  a named appender.  If one is found, the properties
 * for that appender are seperated out, and sent to the appender to initialize & configure the appender.
 */
- (void) configureAppenders;
- (void) configureLayoutForAppender:(id <L4Appender>)theAppender withProperties:(L4Properties *)theProperties;
- (void) configureLoggers;
- (L4Layout *) layoutForClassName:(NSString *)layoutClassName andProperties:(L4Properties *)layoutProperties;
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

- (void) configureLogger:(L4Logger *)aLogger withProperty:(NSString *)aProperty
{
 	// Remove all whitespace characters from config
 	NSArray *components = [aProperty componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
 	NSEnumerator *componentEnum = [components objectEnumerator];
 	NSString *component = nil;
 	NSString *configString = @"";
 	while ( ( component = [componentEnum nextObject] ) != nil ) {
  		configString = [configString stringByAppendingString:component];
 	}
 	
 	// "Tokenize" configString
 	components = [configString componentsSeparatedByString:@","];
 	
 	if ( [components count] == 0 ) {
  		[L4LogLog error:[NSString stringWithFormat:@"Invalid config string(Logger = %@): \"%@\".", [aLogger name], aProperty]];
  		return;
 	}
 	
 	// Set the loglevel
 	componentEnum = [components objectEnumerator];
 	NSString *logLevel = [[componentEnum nextObject] uppercaseString];
 	if ( ![logLevel isEqualToString:@"INHERITED"] ) {
  		[aLogger setLevel:[L4Level levelWithName:logLevel]];
 	}

 	// Set the Appenders
 	while ( ( component = [componentEnum nextObject] ) != nil ) {
  		id <L4Appender> appender = [appenders objectForKey:component];
  		if ( appender == nil ) {
			[L4LogLog error:[NSString stringWithFormat:@"Invalid appender: \"%@\".", component]];
			continue;
  		}
  		[aLogger addAppender:appender];
 	}
}

- (void)dealloc
{
	[properties release];
	properties = nil;
 	[appenders release];
 	appenders = nil;
 	
	[super dealloc];
}

- (id) init
{
	return nil; // never use this constructor
}

- (id) initWithFileName:(NSString *)aName
{
 	return [self initWithProperties:[L4Properties propertiesWithFileName:aName]];
}

- (id) initWithProperties:(L4Properties *)theProperties
{
 	if ( self = [super init]) {
  		properties = [[theProperties subsetForPrefix:@"log4cocoa."] retain];
  		appenders = [[NSMutableDictionary alloc] init];
 	}
 	
 	return self;
}

/* ********************************************************************* */
#pragma mark Private methods
/* ********************************************************************* */
- (id<L4Appender>) appenderForClassName:(NSString *)appenderClassName andProperties:(L4Properties *)appenderProperties
{
	id <L4Appender> newAppender = nil;
	Class appenderClass = NSClassFromString(appenderClassName);
	Protocol *appenderProtocol = @protocol(L4Appender);
	NSString *apenderProtocolName = NSStringFromProtocol(@protocol(L4Appender));
	
	if ( appenderClass == nil ) {
	 	[L4LogLog error:[NSString stringWithFormat:@"Cannot find %@ class with name: \"%@\".", 
						 apenderProtocolName, appenderClassName]];
	} else {	  		
	 	if ( ![appenderClass conformsToProtocol: appenderProtocol] ) {
	  		[L4LogLog error: 
			 [NSString stringWithFormat:
			  @"Failed to create instance with name \"%@\" since it does not conform to the %@ protocol.", 
			  apenderProtocolName, appenderProtocol]];
	 	} else {
	  		newAppender = [[(id <L4Appender>)[appenderClass alloc] initWithProperties:appenderProperties] autorelease];
			// Now we need to handle the layout
			[self configureLayoutForAppender:newAppender withProperties:appenderProperties];
	 	}
	}
	return newAppender;
}

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

- (void) configureLayoutForAppender:(id <L4Appender>)theAppender withProperties:(L4Properties *)theProperties
{
	for (NSString *key in [theProperties allKeys]) {
		if ([@"layout" isEqualToString:key]) {
			L4Properties *layoutProperties = [theProperties subsetForPrefix:[key stringByAppendingString:@"."]];
			NSString *className = [theProperties stringForKey:key];
			L4Layout *theLayout = [self layoutForClassName:className andProperties:layoutProperties];
			if (theLayout != nil) {
				[theAppender setLayout:theLayout];
			}
		}
	}
}

- (L4Layout *) layoutForClassName:(NSString *)layoutClassName andProperties:(L4Properties *)layoutProperties
{
	L4Layout *newLayout = nil;
	Class layoutClass = NSClassFromString(layoutClassName);
	
	if ( layoutClass == nil ) {
	 	[L4LogLog error:[NSString stringWithFormat:@"Cannot find L4Layout class with name: \"%@\".", layoutClassName]];
	} else {	  		
	 	if ( ![[[[layoutClass alloc] init] autorelease] isKindOfClass:[L4Layout class]] ) {
	  		[L4LogLog error: 
			 [NSString stringWithFormat:
			  @"Failed to create instance with name \"%@\" since it is not of kind L4Layout.", layoutClass]];
	 	} else {
	  		newLayout = [[[layoutClass alloc] initWithProperties:layoutProperties] autorelease];
	 	}
	}
	return newLayout;
}

- (void) configureAppenders
{
 	L4Properties *appendersProperties = [properties subsetForPrefix: @"appender."];
 	
 	NSEnumerator *keyEnum = [[appendersProperties allKeys] objectEnumerator];
 	NSString *key = nil;
 	while ( ( key = [keyEnum nextObject] ) != nil ) {
  		NSRange range = [key rangeOfString:@"." options:0 range:NSMakeRange(0, [key length])];
  		if ( range.location == NSNotFound ) {
			// NSNotFound indicates that the key is for a new appender (i.e A1 - where there is no dot after the 
			// appender name). We now need to get the subset of properties for the named appender.
			L4Properties *appenderProperties = [appendersProperties subsetForPrefix:[key stringByAppendingString:@"."]];
			
			NSString *className = [appendersProperties stringForKey:key];
			id <L4Appender> newAppender = [self appenderForClassName:className andProperties:appenderProperties];
			
			if ( newAppender != nil ) {
				[newAppender setName:key];
				[appenders setObject:newAppender forKey:key];
			} else {
				[L4LogLog error:
				 [NSString stringWithFormat: 
				  @"Error while creating appender \"%@\" with name \"%@\".", className, key]];
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

@end
