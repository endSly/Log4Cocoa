/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import "L4Properties.h"
#import "L4LogLog.h"

static NSString *L4PropertiesCommentChar = @"#";
static NSString *DELIM_START = @"${";
static int DELIM_START_LEN = 2;
static NSString *DELIM_STOP = @"}";
static int DELIM_STOP_LEN = 1;
NSString* const L4PropertyMissingException = @"L4PropertyMissingException";

/**
 * Private messages for the L4Properties class.
 */
@interface L4Properties (Private)
/**
 * A helper method that enumerates all the stored properties, and for each one,
 * invokes the substituteEnvironmentVariablesForString: helper method on both
 * its key and its value.
 */
- (void) replaceEnvironmentVariables;
/**
 * A helper method that takes a string that may contain any number of named
 * environment variable references, such as ${TEMP_DIR} and substitutes each
 * named environment variable reference with its actual value instead.
 *
 * @param aString a string that may contain zero or more named environment variable references
 * @return a copy of the input string, with all the named environment variable references
 *         having been replaced by their actual values.
 */
- (NSString *) substituteEnvironmentVariablesForString:(NSString *)aString;
@end

@implementation L4Properties
/* ********************************************************************* */
#pragma mark Class methods
/* ********************************************************************* */
+ (L4Properties *) properties
{
 	return [self propertiesWithProperties:[NSMutableDictionary dictionary]];
}

+ (L4Properties *) propertiesWithFileName:(NSString *)aName
{
 	return [[[L4Properties alloc] initWithFileName:aName] autorelease];
}

+ (L4Properties *) propertiesWithProperties:(NSDictionary *)aProperties
{
 	return [[[L4Properties alloc] initWithProperties:aProperties] autorelease];
}

/* ********************************************************************* */
#pragma mark Instance methods
/* ********************************************************************* */

- (NSArray *) allKeys
{
 	return [properties allKeys];
}

- (NSUInteger) count
{
 	return [properties count];
}

- (void)dealloc
{
	[properties release];
	properties = nil;
 	
	[super dealloc];
}

- (NSString *) description
{
 	return [properties description];
}

- (id) init
{
	return [self initWithFileName:nil];
}

- (id) initWithFileName:(NSString *)aName
{
    self = [super init];
	if ( self != nil ) {
		properties = [[NSMutableDictionary dictionary] retain];
  		
  		NSString *fileContents = [NSString stringWithContentsOfFile:aName encoding:NSUTF8StringEncoding error:nil];
  		
  		NSEnumerator *lineEnumerator = [[fileContents componentsSeparatedByString:@"\n"] objectEnumerator];
  		NSString *currentLine = nil;
  		while ( ( currentLine = [lineEnumerator nextObject] ) != nil ) {
			currentLine = [currentLine stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			
			if ( ![currentLine hasPrefix:L4PropertiesCommentChar] ) {
				NSRange range = [currentLine rangeOfString:@"="];
				
				if ( ( range.location != NSNotFound ) && ( [currentLine length] > range.location + 1 ) ) {
					[properties setObject:[currentLine substringFromIndex:range.location + 1]
								   forKey:[currentLine substringToIndex:range.location]];
				}
			}
  		}
  		[self replaceEnvironmentVariables];
	}
	
	return self;
}

- (id) initWithProperties:(NSDictionary *)aProperties
{
    self = [super init];
	if ( self != nil ) {
  		properties = [[NSMutableDictionary alloc] initWithDictionary:aProperties];
 	}
 	
 	return self;
}

- (void) removeStringForKey:(NSString *)aKey
{
 	[properties removeObjectForKey:aKey];
}

- (void) setString:(NSString *)aString forKey:(NSString *)aKey
{
 	[properties setObject:aString forKey:aKey];
    [self replaceEnvironmentVariables];
}

- (NSString *) stringForKey:(NSString *)aKey
{
 	return [self stringForKey:aKey withDefaultValue:nil];
}

- (NSString *) stringForKey:(NSString *)aKey withDefaultValue:(NSString *)aDefaultValue
{
 	NSString *string = [properties objectForKey:aKey];
 	
 	if ( string == nil ) {
  		return aDefaultValue;
 	} else {
  		return string;
 	}
}

- (L4Properties *) subsetForPrefix:(NSString *)aPrefix
{
 	NSMutableDictionary *subset = [NSMutableDictionary dictionaryWithCapacity:[properties count]];
 	
 	NSEnumerator *keyEnum = [[properties allKeys] objectEnumerator];
 	NSString *key = nil;
 	while ( ( key = [keyEnum nextObject] ) != nil ) {
  		NSRange range = [key rangeOfString:aPrefix options:0 range:NSMakeRange(0, [key length])];
  		if ( range.location != NSNotFound ) {
			NSString *subKey = [key substringFromIndex:range.length];
			[subset setObject:[properties objectForKey:key] forKey:subKey];
  		}
 	}
 	
 	return [L4Properties propertiesWithProperties:subset];
}

/* ********************************************************************* */
#pragma mark Private methods
/* ********************************************************************* */
- (void) replaceEnvironmentVariables
{
 	NSEnumerator *keyEnum = [[self allKeys] objectEnumerator];
 	NSString *key = nil;
 	while ( ( key = [keyEnum nextObject] ) != nil ) {
  		NSString *value = [self stringForKey:key];
  		NSString *subKey = [self substituteEnvironmentVariablesForString:key];
  		if ( ![subKey isEqualToString:key] ) {
			[self removeStringForKey:key];
			[self setString:subKey forKey:value];
  		}
  		NSString *subVal = [self substituteEnvironmentVariablesForString:value];
  		if ( ![subVal isEqualToString:value] ) {
			[self setString:subVal forKey:subKey];
  		}
 	}
}

- (NSString *) substituteEnvironmentVariablesForString:(NSString *)aString
{
 	int len = [aString length];
 	NSMutableString *buf = [NSMutableString string];
 	NSRange i = NSMakeRange(0, len);
 	NSRange j, k;
 	while ( true ) {
  		j = [aString rangeOfString:DELIM_START options:0 range:i];
  		if ( j.location == NSNotFound ) {
			if ( i.location == 0 ) {
				return aString;
			} else {
				[buf appendString:[aString substringFromIndex:i.location]];
				return buf;
			}
  		} else {
			[buf appendString:[aString substringWithRange:NSMakeRange(i.location, j.location - i.location)]];
			k = [aString rangeOfString:DELIM_STOP options:0 range:NSMakeRange(j.location, len - j.location)];
			if ( k.location == NSNotFound ) {
				[L4LogLog error:
				 [NSString stringWithFormat:@"\"%@\" has no closing brace. Opening brace at position %@.", 
				  aString, [NSNumber numberWithInt:j.location]]];
				return aString;
			} else {
				j.location += DELIM_START_LEN;
				j = NSMakeRange(j.location, k.location - j.location);
				NSString *key = [aString substringWithRange:j];
				char *replacement = getenv([key UTF8String]);
				if ( replacement != NULL ) {
					[buf appendString:[NSString stringWithUTF8String:replacement]];
				}
				i.location += (k.location + DELIM_STOP_LEN);
				i.length -= i.location;
			}
  		}
 	}
}

@end
