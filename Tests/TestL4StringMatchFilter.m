#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>
#import "L4StringMatchFilter.h"
#import "L4Level.h"
#import "L4LoggingEvent.h"
#import "L4Properties.h"

/**
 * Unit tests for the L4StringMatchFilter class.
 */
@interface TestL4StringMatchFilter : SenTestCase {	
}

@end


@implementation TestL4StringMatchFilter
- (void) testInitWithAcceptOnMatchStringToMatch
{
	NSLog(@"==================================================== TestL4StringMatchFilter:testInitWithAcceptOnMatchStringToMatch");
	
	L4StringMatchFilter *filter = nil;
	STAssertThrowsSpecificNamed(filter = [[L4StringMatchFilter alloc] initWithAcceptOnMatch:NO stringToMatch:nil],
							  NSException, NSInvalidArgumentException, @"An exception should not have been raised.");
	STAssertThrowsSpecificNamed(filter = [[L4StringMatchFilter alloc] initWithAcceptOnMatch:NO stringToMatch:@""],
								NSException, NSInvalidArgumentException, @"An exception should not have been raised.");
	STAssertNoThrow(filter = [[L4StringMatchFilter alloc] initWithAcceptOnMatch:NO stringToMatch:@"foo"],
					@"An exception should not have been raised.");
}

- (void) testInitWithProperties
{
	NSLog(@"==================================================== TestL4StringMatchFilter:testInitWithProperties");
	L4Properties *properties = [L4Properties propertiesWithProperties:[NSDictionary dictionary]];
	
	L4StringMatchFilter *filter = nil;
	[properties setString:@"NO" forKey:@"AcceptOnMatch"];
	
	STAssertThrowsSpecificNamed(filter = [(L4StringMatchFilter *)[L4StringMatchFilter alloc] initWithProperties:properties],
								NSException, L4PropertyMissingException, @"An exception should not have been raised.");

	[properties setString:@"foo" forKey:@"StringToMatch"];
	STAssertNoThrow(filter = [(L4StringMatchFilter *)[L4StringMatchFilter alloc] initWithProperties:properties],
					@"An exception should not have been raised.");
	STAssertEqualObjects(@"foo", [filter stringToMatch], @"stringToMatch was not what was expected.");
}

- (void) testDecide
{
	NSLog(@"==================================================== TestL4StringMatchFilter:testDecide");
	
	L4StringMatchFilter *filter = nil;
	STAssertNoThrow(filter = [[L4StringMatchFilter alloc] initWithAcceptOnMatch:NO stringToMatch:@"foo"],
					@"An exception should not have been raised.");
	
	OCMockObject *mockEvent = [OCMockObject mockForClass:[L4LoggingEvent class]];
	[[[mockEvent stub] andReturn:@"So much for foo bar."] message];
	STAssertEquals(L4FilterDeny, [filter decide:(L4LoggingEvent *)mockEvent], 
				   @"Logging event should not have been allowed.");
	
	mockEvent = [OCMockObject mockForClass:[L4LoggingEvent class]];
	[[[mockEvent stub] andReturn:@"This is a test."] message];
	STAssertEquals(L4FilterNeutral, [filter decide:(L4LoggingEvent *)mockEvent], 
				   @"Logging event should have been neutral.");
	
}

@end
