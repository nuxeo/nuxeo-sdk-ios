//
//  NUXJSONSerializer.h
//  Pods
//
//  Created by Matthias ROUBEROL on 15/11/13.
//
//

#import <Foundation/Foundation.h>

@interface NUXJSONSerializer : NSObject



/* Create a business object from JSON data. 
 If an error occurs during the parse, then the error parameter will be set and the result will be nil.
 The data must be in one of the 5 supported encodings listed in the JSON specification: UTF-8, UTF-16LE, UTF-16BE, UTF-32LE, UTF-32BE.
 The most efficient encoding to use for parsing is UTF-8, so if you have a choice in encoding the data passed to this method, use UTF-8.
 */
+ (id)entityWithData:(NSData *)data error:(NSError **)error;

/* Generate JSON data from a business object. 
 If the object will not produce valid JSON then an exception will be thrown. 
 If an error occurs, the error parameter will be set and the return value will be nil. 
 The resulting data is a encoded in UTF-8.
 */
+ (NSData *) dataWithEntity:(id)bObject error:(NSError **)error;


@end
