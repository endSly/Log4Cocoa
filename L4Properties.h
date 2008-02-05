#import <Foundation/Foundation.h>

@interface L4Properties : NSObject {
    NSMutableDictionary* properties; /**< The internal dictionary in which individual properties are stored.*/
}

+ (id) propertiesWithFileName:(NSString *) aName;

+ (id) propertiesWithProperties:(NSDictionary *) aProperties;

/**
 * Returns all the keys in this property list.
 * @return an array of all the keys in this property list.
 */
- (NSArray *) allKeys;

/**
 * Accessor for the int value of the number of entries in this collection.
 * @return the int value of the number of entries in this collection.
 */
- (int) count;

/**
 * This method initializes a new instance of this class with the specified file path.
 * @param aName the file path of the properties file you want to read from.
 * @return An initialized instance of this class.
 */
- (id) initWithFileName:(NSString *) aName;

/**
 * This method initializes a new instance of this class with the specified dictionary.
 * @param aProperties an initialized dictionary that contains the properties you want.
 * @return An initialized instance of this class.
 */
- (id) initWithProperties:(NSDictionary *) aProperties;

/**
 * Removes the property indexed by <code>key</code> from this property list.
 * @param aKey the name of the property which is to be removed from the property list.
 */
- (void) removeStringForKey: (NSString *) aKey;

/**
 * Searches for the property with the specified key in this property
 * list. If the key is not found in this property list, the default
 * property list, and its defaults, recursively, are then checked. 
 * The method returns <code>nil</code> if the property is not found.
 * @param aKey the name of the property which is requested.
 * @return the value of the requested property or <code>nil</code> if the specified property was not found.
 */
- (NSString *) stringForKey: (NSString *) aKey;

/**
 * Searches for the property with the specified key in this property
 * list. If the key is not found in this property list, the default
 * property list, and its defaults, recursively, are then checked. 
 * The method returns the default value argument if the property is 
 * not found.
 * @param aKey the name of the property which is requested.
 * @param aDefaultValue the default value to be returned if the specified property was not found.
 * @return the value of the requested property or the default value argument if the specified property was not found.
 */
- (NSString *) stringForKey: (NSString *) aKey withDefaultValue: (NSString *) aDefaultVal;

/**
 * Inserts <code>aString</code> into this property list indexed by <code>aKey</code>.
 * @param aString the value for the property to be inserted.
 * @param aKey the name of the property which is to be inserted into the property list.
 */
- (void) setString: (NSString *) aString forKey: (NSString *) aKey;

/**
 * Returns a subset of the properties whose keys start with the specified prefix.
 * The returned properties have the specified prefix trimmed from their keys.
 * @param aPrefix the property name prefix to search for, and remove from the returned property list subset.
 * @return a subset of the original property list which contains all the properties whose keys started with the specified prefix, but have had the prefix trimmed from them.
 */
- (L4Properties *) subsetForPrefix: (NSString *) aPrefix;

@end
// For copyright & license, see COPYRIGHT.txt.
