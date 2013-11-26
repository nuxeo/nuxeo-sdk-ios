//
//  NUXJSONMapper.m
//  Pods
//
//  Created by Matthias ROUBEROL on 15/11/13.
//
//

#import "NUXJSONMapper.h"

#import "NUXEntity.h"
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
    // default mapping map
    _entityMapping = [NSMutableDictionary dictionary];
    
    [self registerEntityClass:[NUXDocument class]];
    [self registerEntityClass:[NUXDocuments class]];
}


- (void) registerEntityClass:(Class) bClass
{
    // Create empty instance to get entity-type
    id obj = [[bClass alloc] init];
    if (![obj isKindOfClass:[NUXEntity class]]) {
        [NSException raise:@"Class error" format:@"Trying to register class %@ without inherite %@ class.", bClass, [NUXEntity class]];
    }
    [self.entityMapping setValue:bClass forKey:[obj valueForKey:@"entityType"]];
}

- (void)dealloc
{
    _entityMapping = nil;
}

@end
