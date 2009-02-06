#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>
#import "L4LevelMatchFilter.h"
#import "L4Level.h"
#import "L4LoggingEvent.h"
#import "L4Properties.h"

@interface TestL4LevelMatchFilter : SenTestCase {
}

@end


@implementation TestL4LevelMatchFilter
- (void) testInitWithAcceptOnMatchAndLevelToMatch
{
	NSLog(@"==================================================== TestL4LevelMatchFilter:testInitWithAcceptOnMatchAndLevelToMatch");
	
	L4LevelMatchFilter *filter = nil;
	STAssertThrowsSpecificNamed(filter = [[L4LevelMatchFilter alloc] initWithAcceptOnMatch:NO andLevelToMatch:nil],
								NSException, NSInvalidArgumentException, 
								@"An NSInvalidArgumentException should have been raised.");
	STAssertNoThrow(filter = [[L4LevelMatchFilter alloc] initWithAcceptOnMatch:NO andLevelToMatch:[L4Level all]],
					@"An exception should not have been raised.");
}

- (void) testInitWithProperties
{
	NSLog(@"==================================================== TestL4LevelMatchFilter:testInitWithProperties");
	L4Properties *properties = [L4Properties propertiesWithProperties:[NSDictionary dictionary]];
	
	L4LevelMatchFilter *filter = nil;
	STAssertThrowsSpecificNamed(filter = [(L4LevelMatchFilter *)[L4LevelMatchFilter alloc] initWithProperties:properties],
								NSException, L4PropertyMissingException, 
								@"An L4PropertyMissingException should have been raised.");
	[properties setString:@"ALL" forKey:@"LevelToMatch"];
	[properties setString:@"NO" forKey:@"AcceptOnMatch"];
	STAssertNoThrow(filter = [(L4LevelMatchFilter *)[L4LevelMatchFilter alloc] initWithProperties:properties],
					@"An exception should not have been raised.");
	STAssertTrue([[L4Level all] isEqual:[filter levelToMatch]], @"The expected level is not what it should be.");
	STAssertFalse([filter acceptOnMatch], @"acceptOnMatch should have been NO");
}

- (void) testDecide
{
	NSLog(@"==================================================== TestL4LevelMatchFilter:testDecide");
	
	L4LevelMatchFilter *filter = nil;
	STAssertNoThrow(filter = [[L4LevelMatchFilter alloc] initWithAcceptOnMatch:NO andLevelToMatch:[L4Level info]],
					@"An exception should not have been raised.");
	
	OCMockObject *mockEvent = [OCMockObject mockForClass:[L4LoggingEvent class]];
	[[[mockEvent stub] andReturn:[L4Level info]] level];
	STAssertEquals(L4FilterDeny, [filter decide:(L4LoggingEvent *)mockEvent], 
				   @"Logging event should have been allowed.");
	
	mockEvent = [OCMockObject mockForClass:[L4LoggingEvent class]];
	[[[mockEvent stub] andReturn:[L4Level debug]] level];
	STAssertEquals(L4FilterNeutral, [filter decide:(L4LoggingEvent *)mockEvent], 
				   @"Logging event should have been allowed.");

	STAssertNoThrow(filter = [[L4LevelMatchFilter alloc] initWithAcceptOnMatch:YES andLevelToMatch:[L4Level all]],
					@"An exception should not have been raised.");	
	mockEvent = [OCMockObject mockForClass:[L4LoggingEvent class]];
	[[[mockEvent stub] andReturn:[L4Level debug]] level];
	STAssertEquals(L4FilterAccept, [filter decide:(L4LoggingEvent *)mockEvent], 
				   @"Logging event should have been allowed.");
}

@end
