#import <SenTestingKit/SenTestingKit.h>
#import "L4PatternLayout.h"

@interface TestL4PatternLayout : SenTestCase {
	
}

@end


@implementation TestL4PatternLayout
- (void) testParseConversionPatternIntoArraySimple
{
	NSLog(@"==================================================== TestL4PatternLayout:testParseConversionPatternIntoArraySimple");
	
	L4PatternLayout *layout = nil;
	STAssertNoThrow(layout = [[L4PatternLayout alloc] init], @"An exception should not have been raised.");
	[layout setConversionPattern:@"%m%n"]; // The default
	// Ignore the warning; tokenArray is not in the interface, but is present.
	NSArray *actualTokens = [layout tokenArray];
	NSArray *expectedTokens = [NSArray arrayWithObjects:@"%m", @"%n", nil];

	STAssertNotNil(actualTokens, @"The token array should not be nill.");
	STAssertEquals([actualTokens count], [expectedTokens count], @"The token counts do not match.");
	
	STAssertEqualObjects(actualTokens, expectedTokens, @"The token arrays do not match.");
}

- (void) testParseConversionPatternIntoArrayComplex
{
	NSLog(@"==================================================== TestL4PatternLayout:testParseConversionPatternIntoArrayComplex");
	
	L4PatternLayout *layout = nil;
	STAssertNoThrow(layout = [[L4PatternLayout alloc] init], @"An exception should not have been raised.");
	[layout setConversionPattern:@"%-5p :%t%m%n"];
	// Ignore the warning; tokenArray is not in the interface, but is present.
	NSArray *actualTokens = [layout tokenArray];
	NSArray *expectedTokens = [NSArray arrayWithObjects:@"%-5p", @" :", @"%t", @"%m", @"%n", nil];

	STAssertNotNil(actualTokens, @"The token array should not be nill.");
	STAssertEquals([actualTokens count], [expectedTokens count], @"The token counts do not match.");
	
	STAssertEqualObjects(actualTokens, expectedTokens, @"The token arrays do not match.");
}

@end
