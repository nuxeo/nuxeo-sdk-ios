//
//  NUXJSONMapper.m
//  Pods
//
//  Created by Matthias ROUBEROL on 15/11/13.
//
//

#import "NUXJSONMapper.h"

#import "NUXDocument.h"
#import "NUXDocuments.h"

#define kNUXEntityTypeParam @"entity-type"


@implementation NUXJSONMapper

+ (NUXJSONMapper *) sharedMapper
{
    static dispatch_once_t pred = 0;
    __strong static NUXJSONMapper * _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
        // or some other init method
        [_sharedObject setup];
    });
    return _sharedObject;
}

- (void) setup
{
    // can override and let the children singleton process their first init there
    
    // default mapping map
    _entityMapping = [NSMutableDictionary dictionary];
    [self registerEntityClass:[NUXDocument class] forType:NUXEntityDocument];
    [self registerEntityClass:[NUXDocuments class] forType:NUXEntityDocuments];
}


- (void) registerEntityClass:(Class) bClass forType:(NUXEntityType)entityType
{
    [self.entityMapping setValue:bClass forKey:[NSString stringWithFormat:@"%d", entityType]];
}

- (void)dealloc
{
    _entityMapping = nil;
}

@end
