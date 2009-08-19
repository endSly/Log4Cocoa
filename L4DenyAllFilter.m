/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import "L4DenyAllFilter.h"


@implementation L4DenyAllFilter

- (L4FilterResult) decide:(L4LoggingEvent *) event
{
	return L4FilterDeny;
}

@end
