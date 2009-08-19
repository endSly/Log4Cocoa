/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import "L4AppenderSkeleton.h"
#import "L4Filter.h"
#import "L4Level.h"
#import "L4LoggingEvent.h"
#import "L4LogLog.h"
#import "L4Layout.h"
#import "L4Properties.h"

/**
 * Private methods.
 */
@interface L4AppenderSkeleton (Private)
/**
 * Returns a new subclass of L4Filter specified by the class name, configured with the supplied properties.
 * @param filterClassName the name of the L4Filter subclass to instantiate.
 * @param filterProperties the properties used to configure the new instance.
 */
- (L4Filter *) filterForClassName:(NSString *)filterClassName andProperties:(L4Properties *)filterProperties;
/**
 * Returns a new subclass of L4Layout specified by the class name, configured with the supplied properties.
 * @param layoutClassName the name of the L4Layout subclass to instantiate.
 * @param layoutProperties the properties used to configure the new instance.
 */
- (L4Layout *) layoutForClassName:(NSString *)layoutClassName andProperties:(L4Properties *)layoutProperties;
@end

@implementation L4AppenderSkeleton

- (id) initWithProperties:(L4Properties *) initProperties
{
    self = [super init];
    
    if ( self != nil ) {
        // Configure the layout
        if ( [initProperties stringForKey:@"layout"] != nil ) {
            L4Properties *layoutProperties = [initProperties subsetForPrefix:@"layout."];
            NSString *className = [initProperties stringForKey:@"layout"];
            L4Layout *newLayout = [self layoutForClassName:className andProperties:layoutProperties];
            
            if ( newLayout != nil ) {
                [self setLayout:newLayout];
            } else {
                [L4LogLog error:[NSString stringWithFormat:
                                  @"Error while creating layout \"%@\".", className]];
                [self release];
                return nil;
            }
        }
        
        // Support for appender.Threshold in properties configuration file
        if ( [initProperties stringForKey:@"Threshold"] != nil ) {
            NSString *newThreshold = [[initProperties stringForKey:@"Threshold"] uppercaseString];
            [self setThreshold:[L4Level levelWithName:newThreshold]];
        }
        
        // Configure the filters
        L4Properties *filtersProperties = [initProperties subsetForPrefix:@"filters."];
        int filterCount = 0;
        while ( [filtersProperties stringForKey:[[NSNumber numberWithInt:++filterCount] stringValue]] != nil ) {
            NSString *filterName = [[NSNumber numberWithInt:filterCount] stringValue];
            L4Properties *filterProperties = [filtersProperties subsetForPrefix:[filterName stringByAppendingString:@"."]];
            NSString *className = [filtersProperties stringForKey:filterName];
            L4Filter *newFilter = [self filterForClassName:className andProperties:filterProperties];
            
            if ( newFilter != nil ) {
				[self appendFilter:newFilter];
            } else {
                [L4LogLog error:[NSString stringWithFormat:
                                  @"Error while creating filter \"%@\".", className]];
                [self release];
                return nil;
            }
        }
    }
    
    return self;
}

- (void) dealloc
{
	[name release];
	[layout release];
	[threshold release];
	[headFilter release];
	[super dealloc];
}

- (void) append:(L4LoggingEvent *) anEvent
{
}

- (BOOL) isAsSevereAsThreshold:(L4Level *) aLevel
{
    BOOL isAsSevere = NO;
    @synchronized(self) {
    	isAsSevere = ((threshold == nil) || ([aLevel isGreaterOrEqual:threshold]));
    }
    return isAsSevere;
}

- (L4Level *) threshold
{
	return threshold;
}

- (void) setThreshold:(L4Level *) aLevel
{
    @synchronized(self) {
        if( threshold != aLevel ) {
            [threshold autorelease];
            threshold = [aLevel retain];
        }
    }
}

/* ********************************************************************* */
#pragma mark Private methods
/* ********************************************************************* */
- (L4Filter *) filterForClassName:(NSString *)filterClassName andProperties:(L4Properties *)filterProperties
{
	L4Filter *newFilter = nil;
	Class filterClass = NSClassFromString(filterClassName);
	
	if ( filterClass == nil ) {
	 	[L4LogLog error:[NSString stringWithFormat:@"Cannot find L4Filter class with name:\"%@\".", filterClassName]];
	} else {	  		
	 	if ( ![[[[filterClass alloc] init] autorelease] isKindOfClass:[L4Filter class]] ) {
	  		[L4LogLog error:
			 [NSString stringWithFormat:
			  @"Failed to create instance with name \"%@\" since it is not of kind L4Filter.", filterClass]];
	 	} else {
	  		newFilter = [[(L4Filter *)[filterClass alloc] initWithProperties:filterProperties] autorelease];
	 	}
	}
	return newFilter;
}

- (L4Layout *) layoutForClassName:(NSString *)layoutClassName andProperties:(L4Properties *)layoutProperties
{
	L4Layout *newLayout = nil;
	Class layoutClass = NSClassFromString(layoutClassName);
	
	if ( layoutClass == nil ) {
	 	[L4LogLog error:[NSString stringWithFormat:@"Cannot find L4Layout class with name:\"%@\".", layoutClassName]];
	} else {	  		
	 	if ( ![[[[layoutClass alloc] init] autorelease] isKindOfClass:[L4Layout class]] ) {
	  		[L4LogLog error:
			 [NSString stringWithFormat:
			  @"Failed to create instance with name \"%@\" since it is not of kind L4Layout.", layoutClass]];
	 	} else {
	  		newLayout = [[(L4Layout *)[layoutClass alloc] initWithProperties:layoutProperties] autorelease];
	 	}
	}
	return newLayout;
}

/* ********************************************************************* */
#pragma mark L4AppenderCategory methods
/* ********************************************************************* */
// calls [self append:anEvent] after doing threshold checks
- (void) doAppend:(L4LoggingEvent *) anEvent
{
    L4Filter *aFilter = [self headFilter];
    BOOL breakLoop = NO;
    
    if(![self isAsSevereAsThreshold:[anEvent level]]) {
        return;
    }

    BOOL isOkToAppend = YES;
    
    @synchronized(self) {

        if( closed ) {
            [L4LogLog error:[@"Attempted to append to closed appender named:" stringByAppendingString:name]];
            isOkToAppend = NO;
        }
        
        while((aFilter != nil) && !breakLoop) {
            switch([aFilter decide:anEvent]) {
                case L4FilterDeny:
                    isOkToAppend = NO;
                    breakLoop = YES;
                    break;
                case L4FilterAccept:
                    breakLoop = YES;
                    break;
                case L4FilterNeutral:
                default:
                    aFilter = [aFilter next];
                    break;
            }
        }
        
        if(isOkToAppend) {
            [self append:anEvent]; // passed all threshold checks, append event.
        }
    }
}

- (void) appendFilter:(L4Filter *) newFilter
{
    @synchronized(self) {
        if( headFilter == nil ) {
            headFilter = [newFilter retain];
            tailFilter = newFilter; // don't retain at the tail, just the head.
        } else {
            [tailFilter setNext:newFilter];
            tailFilter = newFilter;
        }
    }
}

- (L4Filter *) headFilter
{
	return headFilter;
}

- (void) clearFilters
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    @synchronized(self) {
        id aFilter;
        [headFilter autorelease];
        for( aFilter = headFilter; aFilter != nil; aFilter = [headFilter next] ) {
            [aFilter setNext:nil];
        }
        headFilter = nil;
        tailFilter = nil;
    }
    
    [pool release];
}

- (void) close
{
}

- (BOOL) requiresLayout
{
	return NO;
}

- (NSString *) name
{
	return name;
}

- (void) setName:(NSString *) aName
{
    @synchronized(self) {
        if( name != aName ) {
            [name autorelease];
            name = [aName copy];
        }
    }
}

- (L4Layout *) layout
{
	return layout;
}

- (void) setLayout:(L4Layout *) aLayout
{
    @synchronized(self) {
        if( layout != aLayout ) {
            [layout autorelease];
            layout = [aLayout retain];
        }
    }
}

@end
