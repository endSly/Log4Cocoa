/****************************
*
* Copyright (c) 2002, 2003, Bob Frank
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions
* are met:
*
*  - Redistributions of source code must retain the above copyright
*    notice, this list of conditions and the following disclaimer.
*
*  - Redistributions in binary form must reproduce the above copyright
*    notice, this list of conditions and the following disclaimer in the
*    documentation and/or other materials provided with the distribution.
*
*  - Neither the name of Log4Cocoa nor the names of its contributors or owners
*    may be used to endorse or promote products derived from this software
*    without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
* "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
* LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
* A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
* OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
* SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
* TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
* OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
* OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
* NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*
****************************/

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
