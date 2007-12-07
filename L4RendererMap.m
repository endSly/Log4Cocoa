/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import "L4RendererMap.h"
#import <objc/objc-class.h>
#import "L4DefaultRenderer.h"

static id <L4ObjectRenderer> defaultRenderer = nil;

@implementation L4RendererMap

+ (void) initialize
{
    defaultRenderer = [[L4DefaultRenderer alloc] init];
}

// these are mostly usefull for config files
+ (void) addRenderer: (id <L4RendererSupport>) repository
     targetClassName: (NSString *) renderedClassName
   rendererClassName: (NSString *) renderingClassName
{
/* ### todo */
}

+ (void) addRenderer: (id <L4RendererSupport>) repository
         targetClass: (Class) renderedClass
       rendererClass: (Class) renderingClass
{
    /* ### todo */
}

- (id) init
{
    self = [super init];
    if( self != nil )
    {
        renderMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) dealloc
{
    [renderMap release];
    [super dealloc];
}

- (L4RendererMap *) rendererMap
{
    return self;
}

- (void) setRenderer: (id <L4ObjectRenderer>) renderer
            forClass: (Class) aClass
{
    [renderMap setObject: renderer
                  forKey: aClass];
}

- (NSString *) findAndRender: (id) object
{
    return [[self rendererForClass: [object class]] render: object];
}

- (id <L4ObjectRenderer>) rendererForObject: (id) object
{
    return [renderMap objectForKey: [object class]];
}

- (id <L4ObjectRenderer>) rendererForClass: (Class) aClass
{
    id renderer = nil;
    Class target = aClass;

    while((target != nil) && (renderer == nil))
    {
        renderer = [renderMap objectForKey: target];
        target = [target superclass];
    }

    if( renderer != nil )
    {
        return renderer;
    }
    else
    {
        return defaultRenderer;
    }
    
}

- (id <L4ObjectRenderer>) defaultRenderer
{
    return defaultRenderer;
}

- (void) clear
{
    [renderMap removeAllObjects];
}

@end
