//
//  NUXJSONMapper.h
//  Pods
//
//  Created by Matthias ROUBEROL on 15/11/13.
//
//

#import <Foundation/Foundation.h>

@interface NUXJSONMapper : NSObject

@property (nonatomic, retain, readonly) NSMutableDictionary * entityMapping;

+ (NUXJSONMapper *) sharedMapper;

- (void) registerEntityClass:(Class) bClass;

@end
