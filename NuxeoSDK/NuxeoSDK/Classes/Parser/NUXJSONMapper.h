//
//  NUXJSONMapper.h
//  Pods
//
//  Created by Matthias ROUBEROL on 15/11/13.
//
//

#import <Foundation/Foundation.h>

typedef enum _NUXEntityType
{
    NUXEntityDocument,
    NUXEntityDocuments,
    NUXEntityAutomation
    // Other type to be completed
} NUXEntityType;

@interface NUXJSONMapper : NSObject

@property (nonatomic, retain, readonly) NSMutableDictionary * entityMapping;

+ (NUXJSONMapper *) sharedMapper;

- (void) registerEntityClass:(Class) bClass forType:(NUXEntityType)entityType;

@end
