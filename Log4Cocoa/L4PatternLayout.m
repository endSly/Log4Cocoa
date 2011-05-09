/**
 * For copyright & license, see LICENSE.
 */

#import <math.h>
#import "L4PatternLayout.h"
#import "L4Layout.h"
#import "L4LogEvent.h"
#import "L4Properties.h"
#import "L4LogLog.h"

NSString* const L4PatternLayoutDefaultConversionPattern	= @"%m%n";
NSString* const L4InvalidSpecifierException = @"L4InvalidSpecifierException";
NSString* const L4NoConversionPatternException = @"L4NoConversionPatternException";
NSString* const L4InvalidBraceClauseException = @"L4InvalidBraceClauseException";

@implementation L4PatternLayout

- (id)init
{
	return [self initWithConversionPattern:L4PatternLayoutDefaultConversionPattern];
}

- (id) initWithProperties:(L4Properties *) initProperties
{
    self = [super initWithProperties:initProperties];
    
    if ( self != nil ) {
        // Support for layout.ConversionPattern in properties configuration file
        NSString *buf = [initProperties stringForKey:@"ConversionPattern"];
        if ( buf == nil ) {
            [L4LogLog warn:@"ConversionPattern not specified in properties, will use default."];
			buf = L4PatternLayoutDefaultConversionPattern;
        }
		[self setConversionPattern:buf];
		tokenArray = [[NSMutableArray alloc] initWithCapacity:3];
    }
    
    return self;
}

- (id)initWithConversionPattern:(NSString*)aConversionPattern
{
	L4Properties *properties = [L4Properties properties];
	[properties setString:aConversionPattern forKey:@"ConversionPattern"];
	return [self initWithProperties:properties];
}

- (void)dealloc
{
	[conversionPattern release];
	conversionPattern = nil;
	
	[tokenArray release];
	tokenArray = nil;
	
	[super dealloc];
}

- (NSString*)conversionPattern
{
	return conversionPattern;
}

- (void)setConversionPattern:(NSString*)cp
{
    @synchronized(self) {
        if (![conversionPattern isEqualToString:cp]) {
            [conversionPattern release];
            conversionPattern = nil;
            conversionPattern = [cp copy];
            
            // since conversion pattern changed, reset _tokenArray
            [tokenArray removeAllObjects];
        }
    }
}

- (id)parserDelegate
{
	return parserDelegate;
}

- (void)setParserDelegate:(id)pd
{
	// delegates are not retained by the objects that they are delegates for
	parserDelegate = pd;
}

- (id)converterDelegate
{
	return converterDelegate;
}

- (void)setConverterDelegate:(id)cd
{
	// delegates are not retained by the objects that they are delegates for
	converterDelegate = cd;
}

- (NSString *)format:(L4LogEvent *)event
{
	BOOL				handled = NO;
	NSMutableString*	formattedString = nil;
	int					index = -1;
	NSString*			convertedString = nil;

    @synchronized(self) {
        
        // check the conversion pattern to make sure it has been set, if not, throw an L4NoConversionPatternException
        if ([self conversionPattern] == nil) {
            [NSException raise:L4NoConversionPatternException 
						format:@"L4PatternLayout's conversion pattern is nil and must be set first using either initWithConversionPattern: or setConversionPattern:"];
        }	
        
        formattedString = [NSMutableString stringWithCapacity:10];
        
        // let delegate handle it first
        if (parserDelegate != nil && [parserDelegate respondsToSelector:@selector(parseConversionPattern:intoArray:)]) {
            if ([tokenArray count] <= 0) {
                [parserDelegate parseConversionPattern:conversionPattern intoArray:&tokenArray];
            }
            
            for (index = 0; index < [tokenArray count]; index++) {
                // reset converted string state to make sure we don't use an old value
                convertedString = [NSString string];
                
                // let delegate handle it first
                if (converterDelegate != nil && 
					[converterDelegate respondsToSelector:@selector(convertTokenString:withLoggingEvent:intoString:)]) {
                    handled = [converterDelegate convertTokenString:[tokenArray objectAtIndex:index] 
												   withLoggingEvent:event 
														 intoString:&convertedString];
                    if (!handled) {
                        [self convertTokenString:[tokenArray objectAtIndex:index] 
								withLoggingEvent:event 
									  intoString:&convertedString];
                    }
                } else {
                    [self convertTokenString:[tokenArray objectAtIndex:index] 
							withLoggingEvent:event 
								  intoString:&convertedString];
                }
                
                // only append string if it isn't nil
                if (convertedString != nil) {
                    [formattedString appendString:convertedString];
                }
            }
        } else {
            if ([tokenArray count] <= 0) {
                [self parseConversionPattern:conversionPattern intoArray:&tokenArray];
            }
            
            for (index = 0; index < [tokenArray count]; index++) {
                // reset converted string state to make sure we don't use an old value
                convertedString = nil;
                
                // let delegate handle it first
                if (converterDelegate != nil && 
					[converterDelegate respondsToSelector:@selector(convertTokenString:withLoggingEvent:intoString:)]) {
                    handled = [converterDelegate convertTokenString:[tokenArray objectAtIndex:index] 
												   withLoggingEvent:event 
														 intoString:&convertedString];
                    if (!handled) {
                        [self convertTokenString:[tokenArray objectAtIndex:index] 
								withLoggingEvent:event 
									  intoString:&convertedString];
                    }
                } else {
                    [self convertTokenString:[tokenArray objectAtIndex:index] 
							withLoggingEvent:event 
								  intoString:&convertedString];
                }
                
                // only append string if it isn't nil
                if (convertedString != nil) {
                    [formattedString appendString:convertedString];
                }
            }
        }
	}
	return formattedString;
}

- (void)parseConversionPattern:(NSString*)cp intoArray:(NSMutableArray**)tokenStringArray
{
	NSScanner*				scanner = nil;
	NSCharacterSet*			percentCharacterSet = nil;
	NSMutableCharacterSet*	specifiersAndSpaceCharacterSet = nil;
	NSMutableDictionary*	locale = nil;
	NSMutableString*		token = nil, *tempString = nil;
	
	percentCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"%"];
	
	specifiersAndSpaceCharacterSet = (NSMutableCharacterSet*)[NSCharacterSet characterSetWithCharactersInString:@" "];
	[specifiersAndSpaceCharacterSet formUnionWithCharacterSet:L4PatternLayoutDefaultSpecifiers];
	
	// Get a copy of the user's default locale settings and set the NSDecimalSeparator key of the locale dictionary to 
	// the string ".".  This way we can make sure that minimum and maximum length specifiers are scanned correctly by 
	// the scanner.
	locale = [NSMutableDictionary 
			  dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];
	[locale setObject:@"." forKey:NSLocaleDecimalSeparator];
	
	scanner = [NSScanner scannerWithString:cp];
	[scanner setLocale:locale];
	
	// don't skip any characters when parsing the string
	[scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@""]];
	
	while (![scanner isAtEnd]) {
		token = [NSMutableString stringWithCapacity:10];
		tempString = [NSMutableString stringWithCapacity:10];
		
		// scan until % is found or end of string is reached
		[scanner scanUpToCharactersFromSet:percentCharacterSet intoString:&token];
		
		// if end of string reached
		if ([scanner isAtEnd]) {
			// do nothing, this will force the execution to the end of the while loop where the token string is added to
			// the token string array
		} else if ([percentCharacterSet characterIsMember:[[scanner string] characterAtIndex:[scanner scanLocation]]]) {
			// if characters were scanned
			if ([token length] > 0) {
				// it should be a literal string and we are done for this iteration of the while loop
			} else {
				[token appendFormat:@"%C", [[scanner string] characterAtIndex:[scanner scanLocation]]];
				[scanner setScanLocation:([scanner scanLocation] + 1)];
				[scanner scanUpToCharactersFromSet:specifiersAndSpaceCharacterSet intoString:&tempString];
				
				if ([scanner isAtEnd]) {
					[NSException raise:L4InvalidSpecifierException 
								format:@"Expected a valid specifier character at position %d in the string '%@'", 
					 [scanner scanLocation], [scanner string]];
				} else if ([[scanner string] characterAtIndex:[scanner scanLocation]] == (unichar)' ') {
					[NSException raise:L4InvalidSpecifierException 
								format:@"Expected a valid specifier character at position %d in the string '%@'", 
					 [scanner scanLocation], [scanner string]];
				} else {
					[token appendString:tempString];
					[token appendFormat:@"%C", [[scanner string] characterAtIndex:[scanner scanLocation]]];
					[scanner setScanLocation:([scanner scanLocation] + 1)];
					
					if ([L4PatternLayoutTrailingBracesSpecifiers 
						 characterIsMember:[[scanner string] characterAtIndex:([scanner scanLocation] - 1)]]) {
						if ([scanner isAtEnd]) {
							// do nothing, this will force the execution to the end of the while loop where the token 
							// string is added to the token string array
						} else if ([[scanner string] characterAtIndex:[scanner scanLocation]] == (unichar)'{') {
							[scanner scanUpToString:@"}" intoString:&tempString];
							
							if ([scanner isAtEnd]) {
								[NSException raise:L4InvalidBraceClauseException 
											format:@"Expected a closing brace '}' character at position %d in the string '%@'", 
								 [scanner scanLocation], [scanner string]];
							} else if ([[scanner string] characterAtIndex:[scanner scanLocation]] == (unichar)'}') {
								[token appendString:tempString];
								[token appendFormat:@"%C", [[scanner string] characterAtIndex:[scanner scanLocation]]];
								[scanner setScanLocation:([scanner scanLocation] + 1)];
							}
						}
					} // if specifier character can be followed by brace clause
				} // else
			} // else
		} // else if %  found
		
		// add final token string to the token string array
		[*tokenStringArray addObject:token];
	} // while
	
	// return YES;
}

- (BOOL)convertTokenString:(NSString*)token 
		  withLoggingEvent:(L4LogEvent*)logEvent 
				intoString:(NSString**)convertedString
{
	NSScanner*			scanner = nil;
	NSCharacterSet*		percentCharSet = nil, *specifiersCharSet = nil;
	NSMutableString*	finalResultString = nil;
	NSString*			tempString = nil, *tempString2 = nil;
	unichar				specifierChar;
	unsigned int		charsToSkip = 0;
	int					componentLength;
	BOOL				leftJustify = NO;
	int					minLength = -1;
	int					maxLength = -1;
	NSRange				componentRange;
	NSArray*			fieldLengthArray = nil;
	
	if ([token length] > 0 && [token characterAtIndex:0] != (unichar)'%') {
		*convertedString = [NSString stringWithString:token];
	} else {
		percentCharSet = [NSCharacterSet characterSetWithCharactersInString:@"%"];
		specifiersCharSet = L4PatternLayoutDefaultSpecifiers;

		scanner = [NSScanner scannerWithString:token];

		// don't skip any characters
		[scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@""]];

		finalResultString = [NSMutableString stringWithCapacity:10];

		while (![scanner isAtEnd]) {
			// reset parser state variables
			tempString = @"";
			tempString2 = @"";
			charsToSkip = 0;
			minLength = -1;
			maxLength = -1;
			leftJustify = NO;

			// check for specifier escape sequence (a percent (%))
			//NSLog(@"Checking for a percent at index %d", [scanner scanLocation]);
			if ([percentCharSet characterIsMember:[[scanner string] characterAtIndex:[scanner scanLocation]]]) {
				// found a percent sign
				charsToSkip++;

				// we will read the specifier justification and length as a string, so update scan location first
				[scanner setScanLocation:([scanner scanLocation] + charsToSkip)];
				charsToSkip = 0;

				if ([scanner scanUpToCharactersFromSet:specifiersCharSet intoString:&tempString2]) {
					fieldLengthArray = [tempString2 componentsSeparatedByString:@"."];

					// check for left justification character (-)
					if ([[fieldLengthArray objectAtIndex:0] rangeOfString:@"-"].location != NSNotFound) {
						leftJustify = YES;
					} else {
						leftJustify = NO;
					}

					// check for minimum field width
					minLength = abs([[fieldLengthArray objectAtIndex:0] intValue]);
					if (minLength == 0) {
						minLength = -1;
					}

					if ([fieldLengthArray count] > 1) {
						maxLength = abs([[fieldLengthArray objectAtIndex:([fieldLengthArray count] - 1)] intValue]);
						if (maxLength == 0) {
							maxLength = -1;
						}
					}
				}

				// get the specifier character, if we are at the end of the string but haven't read a specifier
				// character yet, throw an L4InvalidSpecifierException
				//NSLog(@"Checking for the specifier character at index %d", ([scanner scanLocation] + charsToSkip));
				if ([scanner isAtEnd]) {
					[NSException raise:L4InvalidSpecifierException 
								format:@"Expected a valid specifier character at position %d in the string '%@'", 
					 [scanner scanLocation], [scanner string]];
				}
				specifierChar = [[scanner string] characterAtIndex:([scanner scanLocation] + charsToSkip)];

				if ([specifiersCharSet characterIsMember:specifierChar]) {
					switch (specifierChar) {
						case 'C':
						{
							tempString = [[logEvent logger] name];

							// skip the 'C'
							charsToSkip++;

							//NSLog(@"Checking for { after a C at index %d", ([scanner scanLocation] + charsToSkip));

							// if skipping number of characters equal to value of charsToSkip doesn't put us at the end 
							// of the string and the next character (if we skipped charsToSkip characters) would be {
							if (([scanner scanLocation] + charsToSkip) < [[scanner string] length] && 
								[[scanner string] characterAtIndex:([scanner scanLocation] + charsToSkip)] == (unichar)'{') {
								// there's an {, skip it and read the integer that follows
								charsToSkip++;

								// update the scanner's scan location because the following scan operation will advance 
								// the scan location, also reset the charsToSkip
								[scanner setScanLocation:([scanner scanLocation] + charsToSkip)];
								charsToSkip = 0;

								if ([scanner scanUpToString:@"}" intoString:&tempString2]) {
									componentLength = [tempString2 intValue];

									if (componentLength > 0) {
										componentRange =
											NSMakeRange([[tempString componentsSeparatedByString:@"."] count] - componentLength, 
														componentLength);
										tempString = 
											[[[tempString componentsSeparatedByString:@"."] subarrayWithRange:componentRange] componentsJoinedByString:@"."];
									} else {
										[NSException raise:L4InvalidBraceClauseException 
													format:@"Expected a nonzero positive integer at position %d in conversion specifier %@.", 
										 ([scanner scanLocation] - [tempString2 length]), [scanner string]];
									}

									// skip closing }
									charsToSkip++;
								}
							}
						}
						break;
						
						case 'd':
						{
							// skip the 'd'
							charsToSkip++;

							// if skipping number of characters equal to value of charsToSkip doesn't put us at the end 
							// of the string and the next character (if we skipped charsToSkip characters) would be {
							if (([scanner scanLocation] + charsToSkip) < [[scanner string] length] && 
								[[scanner string] characterAtIndex:([scanner scanLocation] + charsToSkip)] == (unichar)'{') {
								// there's an {, skip it and read the string that follows
								charsToSkip++;

								// update the scanner's scan location because the following scan operation will advance 
								// the scan location, also reset the charsToSkip
								[scanner setScanLocation:([scanner scanLocation] + charsToSkip)];
								charsToSkip = 0;

								// if there's anything between the braces, get string description of the logging event's 
								// timestamp with the format we just found
								if ([scanner scanUpToString:@"}" intoString:&tempString2]) {
									tempString = [[logEvent timestamp] descriptionWithCalendarFormat:tempString2];
									
									// skip closing brace
									charsToSkip++;
								}
							} else {
								tempString = [[logEvent timestamp] description];
							}
						}
						break;
						
						case 'F':
							// skip the 'F'
							charsToSkip++;
							tempString = [logEvent fileName];
							break;
						
						case 'l':
							// skip the 'l'
							charsToSkip++;
							tempString = [NSString stringWithFormat:@"%@'s %@ (%@:%d)", [[logEvent logger] name], 
										  [logEvent methodName], [logEvent fileName], 
										  [[logEvent lineNumber] intValue] ];
							break;
						
						case 'L':
							// skip the 'L'
							charsToSkip++;
							tempString = [NSString stringWithFormat:@"%d", [[logEvent lineNumber] intValue]];
							break;
						
						case 'm':
							// skip the 'm'
							charsToSkip++;
							tempString = [logEvent renderedMessage];
							if (tempString == nil) {
								tempString = @"No message!";
							}
							break;
						
						case 'M':
							// skip the 'M'
							charsToSkip++;
							tempString = [logEvent methodName];
							break;
						
						case 'n':
							// skip the 'n'
							charsToSkip++;
							tempString = @"\n";
							break;
						
						case 'p':
							// skip the 'p'
							charsToSkip++;
							tempString = [[logEvent level] description];
							break;
						
						case 'r':
							// skip the 'r'
							charsToSkip++;
							tempString = [NSString stringWithFormat:@"%d", [logEvent millisSinceStart]];
							break;
						
						case 't':
							// skip the 't'
							charsToSkip++;
							tempString = [[NSThread currentThread] name];
							if (tempString == nil) {
								tempString = [NSString stringWithFormat:@"%p", [NSThread currentThread]];
							}
							break;
							
						case '%':
							// skip the '%'
							charsToSkip++;
							tempString = @"%";
							break;
					}

					if (leftJustify && minLength > 0 && maxLength > 0) {
						tempString2 = [NSString stringWithFormat:@"%-*@", minLength, tempString];

						if ([tempString2 length] > maxLength) {
							tempString2 = [tempString2 substringFromIndex:([tempString2 length] - maxLength)];
							[finalResultString appendFormat:@"%-*.*@", minLength, maxLength, tempString2];
						} else {
							[finalResultString appendFormat:@"%-*.*@", minLength, maxLength, tempString];
						}
					} else if (!leftJustify && minLength > 0 && maxLength > 0) {
						tempString2 = [NSString stringWithFormat:@"%*@", minLength, tempString];

						if ([tempString2 length] > maxLength) {
							tempString2 = [tempString2 substringFromIndex:([tempString2 length] - maxLength)];
							[finalResultString appendFormat:@"%*.*@", minLength, maxLength, tempString2];
						} else {
							[finalResultString appendFormat:@"%*.*@", minLength, maxLength, tempString];
						}
					} else if (leftJustify && minLength <= 0 && maxLength > 0) {
						if ([tempString length] > maxLength) {
							tempString2 = [tempString substringFromIndex:([tempString length] - maxLength)];
							[finalResultString appendFormat:@"%-.*@", maxLength, tempString2];
						} else {
							[finalResultString appendFormat:@"%-.*@", maxLength, tempString];
						}
					} else if (!leftJustify && minLength <= 0 && maxLength > 0) {
						if ([tempString length] > maxLength) {
							tempString2 = [tempString substringFromIndex:([tempString length] - maxLength)];
							[finalResultString appendFormat:@"%.*@", maxLength, tempString2];
						} else {
							[finalResultString appendFormat:@"%.*@", maxLength, tempString];
						}
					} else if (leftJustify && minLength > 0 && maxLength <= 0) {
						[finalResultString appendFormat:@"%-*@", minLength, tempString];
					} else if (!leftJustify && minLength > 0 && maxLength <= 0) {
						[finalResultString appendFormat:@"%*@", minLength, tempString];
					} else {
						[finalResultString appendString:tempString];
					}
				}

				[scanner setScanLocation:([scanner scanLocation] + charsToSkip)];
				continue;
			}
			
			if ([scanner scanUpToCharactersFromSet:percentCharSet intoString:&tempString]) {
				[finalResultString appendString:tempString];
				continue;
			} else {
				[NSException raise:L4InvalidSpecifierException 
							format:@"Expected a valid specifier character at position %d in the string '%@'", 
				 [scanner scanLocation], [scanner string]];
			}
		}
		
		*convertedString = (NSString*)finalResultString;
	}
	
	return YES;
}

/*
 * This is here for testing purposes.  Otherwise, the conversion pattern does not get parsed until a log event happens.
 */
- (NSArray *)tokenArray
{
	[self parseConversionPattern:conversionPattern intoArray:&tokenArray];
	return tokenArray;
}

@end
