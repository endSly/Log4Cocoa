#import <Foundation/Foundation.h>
#import "L4Properties.h"

/**
 * Factory object class hierachies provide an alternate initializer chain for
 * all of the factory object subclasses in the form of an initWithProperties
 * initializer. It goes against Cocoa's standard single default initializer
 * chain model, but I couln't think of any way to invoke both the classes'
 * default initializers and their parent's initWithProperties method.
 *
 * Consequently, all factory object classes that have custom properties beyond
 * their parent's superclass should provide an initWithProperties method which
 * should invoke the superclass's initWithProperties method.
 *
 * The initWithProperties method should use any provided initalization
 * properties to configure the class's own custom properties.
 *
 * In case of error in the provided initialization properties, the corresponding
 * initWithProperties method should report appropriate error information via the
 * L4LogLog class. If an error is considered "fatal", such as configuring an
 * L4FileAppender with an invalid file path, then the corresponding init method
 * should release itself and return nil.
 */ 
@protocol L4FactoryObject <NSObject>

/**
 * Creates and returns a new factory object configured using the provided
 * properties.
 */
- (id) initWithProperties: (L4Properties *) aProperties;

@end

/**
 * Configured factories have the ability to create new instances of their
 * configured factory object type. Use the L4FactoryManager to create new
 * configured factories of a given factory object type.
 */
@protocol L4Factory <NSObject>

/**
 * Creates and returns a new factory object configured using the provided
 * properties.
 */
- (id <L4FactoryObject>) factoryObjectWithProperties: (L4Properties *) properties;

@end
