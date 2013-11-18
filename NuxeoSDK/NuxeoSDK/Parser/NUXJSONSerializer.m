//
//  NUXJSONSerializer.m
//  Pods
//
//  Created by Matthias ROUBEROL on 15/11/13.
//
//

#import "NUXJSONSerializer.h"

#include <objc/runtime.h>

@interface NUXJSONSerializer (Private)

+ (NSDictionary *)dictionaryOfPropertiesForObject:(Class)classOfObject;
+ (NSString *) getPropertyType:(objc_property_t) property;

@end

@implementation NUXJSONSerializer (Private)

+ (NSDictionary *)dictionaryOfPropertiesForObject:(Class)classOfObject
{
    // somewhere to store the results
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    // we'll grab properties for this class and every superclass
    // other than NSObject
    while(![classOfObject isEqual:[NSObject class]])
    {
        // ask the runtime to give us a C array of the properties defined
        // for this class (which doesn't include those for the superclass)
        unsigned int numberOfProperties;
        objc_property_t  *properties =
        class_copyPropertyList(classOfObject, &numberOfProperties);
        
        // go through each property in turn...
        for(
            int propertyNumber = 0;
            propertyNumber < numberOfProperties;
            propertyNumber++)
        {
            // get the name and convert it to an NSString
            NSString *nameOfProperty = [NSString stringWithUTF8String:
                                        property_getName(properties[propertyNumber])];
            
            NSString * typeOfProperty = [self getPropertyType:properties[propertyNumber]];
            NSLog(@"Property : %@ , Type : %@", nameOfProperty, typeOfProperty);
            
            // add the property type to the dictionary
            [result
             setObject:typeOfProperty
             forKey:nameOfProperty];
            
        }
        
        // we took a copy of the property list, so...
        free(properties);
        
        // we'll want to consider the superclass too
        classOfObject = [classOfObject superclass];
    }
    
    // return the dictionary
    return result;
}

+ (NSString *) getPropertyType:(objc_property_t) property
{
    const char * name = property_getName(property);
    NSString *propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
    const char * type = property_getAttributes(property);
    NSString *attr = [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
    
    NSString * typeString = [NSString stringWithUTF8String:type];
    NSArray * attributes = [typeString componentsSeparatedByString:@","];
    NSString * typeAttribute = [attributes objectAtIndex:0];
    NSString * propertyType = [typeAttribute substringFromIndex:1];
    const char * rawPropertyType = [propertyType UTF8String];
    
    if (strcmp(rawPropertyType, @encode(float)) == 0) {
        //it's a float
        return @"float";
    } else if (strcmp(rawPropertyType, @encode(int)) == 0) {
        //it's an int
        return @"int";
    } else if (strcmp(rawPropertyType, @encode(id)) == 0) {
        //it's some sort of object
        return @"id";
    } else {
        // According to Apples Documentation you can determine the corresponding encoding values
    }
    
    if ([typeAttribute hasPrefix:@"T@"] && [typeAttribute length] > 1) {
        NSString * typeClassName = [typeAttribute substringWithRange:NSMakeRange(3, [typeAttribute length]-4)];  //turns @"NSDate" into NSDate
        Class typeClass = NSClassFromString(typeClassName);
        if (typeClass != nil) {
            // Here is the corresponding class even for nil values
            return typeClassName;
        }
    }
    
    return nil;
}

@end


@implementation NUXJSONSerializer

+ (id)businessObjectWithData:(NSData *)data error:(NSError **)error
{
    return nil;
}

+ (NSData *) dataWithBusinnesObject:(id)bObject error:(NSError **)error
{
    return nil;
}




@end
