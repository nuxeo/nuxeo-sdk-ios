//
//  NUXEntityCache.m
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 05/12/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import "NUXEntityCache.h"
#import "NUXSQLiteDatabase.h"
#import "NUXJSONSerializer.h"

#define kEntitiesCacheName @"org.nuxeo.cache.entity"

@implementation NUXEntityCache

-(NUXEntity<NUXEntityPersistable> *)entityWithId:(NSString *)entityId class:(Class)entityClass
{
    return nil;
}

-(BOOL)removeEntityWithId:(NSString *)entityId class:(Class)entityClass
{
    return NO;
}

-(BOOL)saveEntity:(NUXEntity<NUXEntityPersistable> *)entity
{
    [[NUXSQLiteDatabase shared] createTableIfNotExists:entity.entityType withField:@""];
    
    return NO;
}

#pragma mark -
#pragma mark Internal methods

-(NSString *)entityPersistableFields
{
    return @"'id' INT, 'entityId' TEXT, 'modified' DATETIME, 'created' DATETIME";
}

-(BOOL)writeEntity:(NUXEntity<NUXEntityPersistable> *)entity {
    NSError *error;
    NSData *data = [NUXJSONSerializer dataWithEntity:entity error:&error];
    if (!data) {
        NUXDebug(@"Unable to get data from entity: %@", error);
        return NO;
    }
    
    NSString *entityFilePath = [self entityFilePathWithId:entity.entityId andType:entity.entityType];
    return [[NSFileManager defaultManager] createFileAtPath:entityFilePath contents:data attributes:nil];
}

-(id)readEntityWithId:(NSString *)entityId andType:(NSString *)entityType
{
    NSString *entityFilePath = [self entityFilePathWithId:entityId andType:entityType];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    id entity = nil;
    if ([manager isReadableFileAtPath:entityFilePath]) {
        NSError *error;
        NSData *data = [manager contentsAtPath:entityFilePath];
        entity = [NUXJSONSerializer entityWithData:data error:&error];
    }
    return entity;
}

-(NSString *)entityFilePathWithId:(NSString *)entityId andType:(NSString *)entityType {
    NSString *typePath = [self entityCachePathForType:entityType];
    return [typePath stringByAppendingPathComponent:entityId];
}

-(NSString *)entityCachePathForType:(NSString *)entityType {
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:kEntitiesCacheName];
    NSString *entityPath = [path stringByAppendingPathComponent:entityType];
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager isWritableFileAtPath:entityPath]) {
        NSError *error;
        if (![manager createDirectoryAtPath:entityPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            [NSException raise:@"Can't create entity folder" format:@"Unable to create entity cache folder at path: %@. %@", entityPath, error];
        }
        NUXDebug(@"Entity cache folder created at path %@", entityPath);
    }
    return path;
}

+ (NUXEntityCache *)instance {
    static dispatch_once_t pred = 0;
    static NUXEntityCache *__strong _instance = nil;
    
    dispatch_once(&pred, ^{
        _instance = [NUXEntityCache new];
    });
    
    return _instance;
}

@end
