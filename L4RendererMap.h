/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import <Foundation/Foundation.h>
#import "L4LoggerProtocols.h"

@interface L4RendererMap : NSObject <L4RendererSupport> {
    NSMutableDictionary *renderMap;
}

+ (void) initialize;

+ (void) addRenderer: (id <L4RendererSupport>) repository
     targetClassName: (NSString *) renderedClassName
   rendererClassName: (NSString *) renderingClassName;

+ (void) addRenderer: (id <L4RendererSupport>) repository
         targetClass: (Class) renderedClass
       rendererClass: (Class) renderingClass;

- (id) init;

- (L4RendererMap *) rendererMap;
- (void) setRenderer: (id <L4ObjectRenderer>) renderer
            forClass: (Class) aClass;

- (NSString *) findAndRender: (id) object;

- (id <L4ObjectRenderer>) rendererForObject: (id) object;
- (id <L4ObjectRenderer>) rendererForClass: (Class) aClass;
- (id <L4ObjectRenderer>) defaultRenderer;

- (void) clear;

@end
