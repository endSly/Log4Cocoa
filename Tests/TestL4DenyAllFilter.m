#import <SenTestingKit/SenTestingKit.h>

#import "L4DenyAllFilter.h"
#import "L4Filter.h"

@interface TestL4DenyAllFilter : SenTestCase {	
}

@end

@implementation TestL4DenyAllFilter
- (void) testDecide
{
	NSLog(@"==================================================== TestL4DenyAllFilter:testDecide");
	
	L4DenyAllFilter *filter = nil;
	STAssertNoThrow(filter = [[L4DenyAllFilter alloc] init], @"An excedption should not have been raised.");
	STAssertEquals([filter decide:nil], L4FilterDeny, @"L4FilterDeny should have been returned.");
}


@end
