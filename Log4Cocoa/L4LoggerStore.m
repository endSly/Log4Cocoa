/**
 * For copyright & license, see LICENSE.
 */

#import "L4LoggerStore.h"
//#import <objc/objc-class.h>
#import "L4Logger.h"
#import "L4Level.h"
#import "L4LogLog.h"

/**
 * Private methods.
 */
@interface L4LoggerStore (Private)
/**
 * Generates a psuedo-fully qualified class name for the class using java-esque dot "." notation seperating classes from
 * their parents.  For example L4Logger results in the string - <code>NSObject.L4Logger</code>
 * NSObject.SubClass1.SubClass2.LeafClass is the format
 * @param aClass the class of interest.
 * @return the FQDN for the class of interest.
 */
- (NSString *) pseudoFqcnForClass:(Class) aClass;
/**
 * Update parents, starts at the end of the pseudo-fqcn string and looks for the first matching logger and sets that as
 * the parent.  Each element in the pseudo-fqcn key path that doesn't exist is created as an NSMutableArray.
 * In order to collect all the child loggers underneath that point in the hierarchy.  This is important when a node in
 * the middle of the tree is created.  All children of that node are set to have that new logger as their parent.
 * @param aLogger the logger who's parents we want to update.
 */
- (void) updateParentsOfLogger:(L4Logger *) aLogger;

/**
 * If the child already has a parent lower than this new logger leave it alone.  If the parent is above this new logger, 
 * then insert itself inbetween.
 * @param node the children to update.
 * @param parent the new parent of the children.
 */
- (void) updateChildren:(NSMutableArray *) node withParent:(L4Logger *) parent;
@end


@implementation L4LoggerStore

+ (void) initialize 
{
}

- (id) init
{
	// ### todo ??? [self autorelease];
	return nil; // don't use this method
}

- (id) initWithRoot:(id) rootLogger
{
	self = [super init];
	if( self != nil ) {
		root = [rootLogger retain];
		
		repository = [[NSMutableDictionary alloc] init];
		loggers = [[NSMutableArray alloc] init];

		[loggers addObject:root];
		[root setLoggerRepository:self];
		[self setThreshold:[L4Level all]];

		emittedNoAppenderWarning = NO;
		emittedNoResourceBundleWarning = NO;
	} else {
		[rootLogger release];  // ### todo - ???
	}
	return self;
}

- (void) dealloc
{
	[root release];
	[repository release];
	[loggers release];
	[threshold release];
	[super dealloc];
}

- (BOOL) isDisabled:(int) aLevel
{
	return thresholdInt > aLevel;
}

- (L4Level *) threshold
{
	return threshold;
}

- (void) setThreshold:(L4Level *) aLevel
{
    @synchronized(self) {
        [threshold autorelease];
        threshold = [aLevel retain];
        thresholdInt = [aLevel intValue];
    }
}

- (void) setThresholdByName:(NSString *) aLevelName
{
	[self setThreshold:[L4Level levelWithName:aLevelName defaultLevel:threshold]];
}

- (L4Logger *) rootLogger
{
	return root;
}

- (L4Logger *) loggerForClass:(Class) aClass
{
	id theLogger = nil;
	if( aClass != nil ) {
        
        @synchronized(self) {
            theLogger = [repository objectForKey:aClass];
            
            if( theLogger == nil ) {
                NSString *pseudoFqcn = [self pseudoFqcnForClass:aClass];
                theLogger = [self loggerForName:pseudoFqcn factory:self];
                [repository setObject:theLogger forKey:aClass];
            }
        }
    }

	return theLogger;
}

- (L4Logger *) loggerForName:(NSString *) aName
{
	return [self loggerForName:aName factory:self];
}

- (L4Logger *) loggerForName:(NSString *) aName factory:(id <L4LoggerFactory>) aFactory
{
	L4Logger *theLogger = nil;
	id theNode;
	
    @synchronized(self) {
        theNode = [repository objectForKey:aName];
        
        if( theNode == nil ) {
            //
            // if the node is nil, then its a new logger & therefore 
            // a new leaf node, since no placeholder node was found.
            //
            theLogger = [aFactory newLoggerInstance:aName];
            [theLogger setLoggerRepository:self];
            [repository setObject:theLogger forKey:aName];
            [self updateParentsOfLogger:theLogger];
            [loggers addObject:theLogger];
            
        } else if([theNode isKindOfClass:[L4Logger class]]) {
            theLogger =  (L4Logger *) theNode;
        } else if([theNode isKindOfClass:[NSMutableArray class]]) {
            //
            // this node is a placeholder middle node, since its an NSMutableArray.  It contains children and
            // a parent, so when we insert this logger, we need to update all of the children to point to this node
            // and to point to their parent.
            //
            theLogger = [aFactory newLoggerInstance:aName];
            [theLogger setLoggerRepository:self];
            [repository setObject:theLogger forKey:aName];
            [self updateChildren:theNode withParent:theLogger ];
            [self updateParentsOfLogger:theLogger];
            [loggers addObject:theLogger];
            
        } else {
            // We should hopefully never end up here.  ### TODO ??? - Internal Consistency Error
            //
            NSString *one = @"Logger not found & internal repository in returned unexpected node type:";
            NSString *twoDo = @"  ### TODO:Should we raise here, because we shouldn't be here.";
            [L4LogLog error:
             [[one stringByAppendingString:
               NSStringFromClass([theNode class])] stringByAppendingString:twoDo]];
        }
    }

	return (L4Logger *) theLogger;
}

- (NSArray *) currentLoggers
{
    NSArray *currentLoggers = nil;
    @synchronized(self) {
        currentLoggers = [[loggers copy] autorelease];
    }
    return currentLoggers;
}

- (void) emitNoAppenderWarning:(L4Logger *) aLogger
{
	if( !emittedNoAppenderWarning ) {
		[L4LogLog warn:[NSString stringWithFormat:@"No appenders could be found for logger(%@).", [aLogger name]]];
		[L4LogLog warn:@"Please initialize the Log4Cocoa system properly."];

		emittedNoAppenderWarning = YES;
	}
}

- (void) resetConfiguration
{
    @synchronized(self) {
        NSEnumerator *enumerator = [loggers objectEnumerator];
        L4Logger *logger;
        
        [root setLevel:[L4Level debug]];
        [self setThreshold:[L4Level all]];
        
        [self shutdown];
        
        while ((logger = (L4Logger *)[enumerator nextObject])) {
            [logger setLevel:nil];
            [logger setAdditivity:YES];
        }
    }
}

- (void) shutdown
{
    @synchronized(self) {
        NSEnumerator *enumerator = [loggers objectEnumerator];
        L4Logger *logger;
        
        [root closeNestedAppenders];
        
        while ((logger = (L4Logger *)[enumerator nextObject])) {
            [logger closeNestedAppenders];
        }
        
        [root removeAllAppenders];
        enumerator = [loggers objectEnumerator];
        
        while ((logger = (L4Logger *)[enumerator nextObject])) {
            [logger removeAllAppenders];
        }
    }
}

/* ********************************************************************* */
#pragma mark L4LoggerFactoryCategory methods
/* ********************************************************************* */

- (L4Logger *) newLoggerInstance:(NSString *) aName
{
	return [[L4Logger alloc] initWithName:aName];
}

/* ********************************************************************* */
#pragma mark Private methods
/* ********************************************************************* */
- (NSString *) pseudoFqcnForClass:(Class) aClass
{
	NSMutableString *pseudoFqcn = [[NSMutableString alloc] init];
	Class theClass = aClass;
	
	[pseudoFqcn insertString:NSStringFromClass(theClass) atIndex:0];
	
	for( theClass = [theClass superclass]; theClass != nil; theClass = [theClass superclass] ) {
		[pseudoFqcn insertString:@"." atIndex:0];
		[pseudoFqcn insertString:NSStringFromClass(theClass) atIndex:0];
	}
	return [pseudoFqcn autorelease];
}

- (void) updateParentsOfLogger:(L4Logger *) aLogger
{
	int i;
	id node;
	L4Logger *parent = root;
	NSString *keyPath;
	NSArray *keys = [[aLogger name] componentsSeparatedByString:@"."];
	NSRange theRange;
	
	theRange.location = 0;
	
	// the trick here is to build up the key paths in reverse order not including
	// the pseudo-fqcn (i.e the last node), to search for already existing parents
	//
	for( i = [keys count] - 1; i > 0; --i ) {
		theRange.length = i;
		keyPath = [[keys subarrayWithRange:theRange] componentsJoinedByString:@"."];
		node = [repository objectForKey:keyPath];
		
		if(node == nil) {
			// didn't find a parent or a placeholder, create a placeholder
			// node, i.e. a MutalbeArray, and add this logger as a child
			//
			[repository setObject:[NSMutableArray arrayWithObject:aLogger] forKey:keyPath];
		} else if([node isKindOfClass:[L4Logger class]]) {
			parent = node;
			break;
		} else if([node isKindOfClass:[NSMutableArray class]]) {
			[node addObject:aLogger]; // found a place holder node, add this logger as a child
		}
	}
	[aLogger setParent:parent];  // found a parent, set it for this logger
}

- (void) updateChildren:(NSMutableArray *) node withParent:(L4Logger *) newLogger
{
	int i;
	int last = [node count];
	L4Logger *child = nil;
	
	for( i = 0; i < last; i++ ) {
		child = (L4Logger *)[node objectAtIndex:i];
		
		// If the child's parent's name starts with the name of the new logger then its a child of the new logger leave the child alone, we'll get
		// to the child's parent in this list.  Otherwise the parent is higher & insert the new logger.  All children that go through this same
		// middle node, that don't have an already lower parent, should all point to the same higher parent.  If not, something is wrong.
		//
		if( ![[[child parent] name] hasPrefix:[newLogger name]] ) {
			[newLogger setParent:[child parent]];
			[child setParent:newLogger];
		}
	}
}

@end

