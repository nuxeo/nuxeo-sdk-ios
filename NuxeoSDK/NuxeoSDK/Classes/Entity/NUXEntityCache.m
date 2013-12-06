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

-(id)entityWithId:(NSString *)entityId class:(Class)entityClass
{
    return [self readEntityWithId:entityId andType:[self entityTypeFromClass:entityClass]];
}

-(BOOL)removeEntityWithId:(NSString *)entityId class:(Class)entityClass
{
    NSString *entityType = [self entityTypeFromClass:entityClass];
    if ([self isEntityExistsWithId:entityId andType:entityType]) {
        return [[NSFileManager defaultManager] removeItemAtPath:[self entityFilePathWithId:entityId andType:entityType] error:nil];
    }
    return NO;
}

-(BOOL)saveEntity:(NUXEntity<NUXEntityPersistable> *)entity
{
    return [self writeEntity:entity];
}

#pragma mark -
#pragma mark Internal methods

-(NSString *)entityTypeFromClass:(Class)aClass {
    if (![aClass isSubclassOfClass:[NUXEntity class]]) {
        [NSException raise:@"Incompatible class" format:@"Provided class isn't a subclass of %@", [NUXEntity class]];
    }
    return ((NUXEntity *)[aClass new]).entityType;
}

-(NSString *)entityPersistableFields
{
    return @"'entityId' TEXT, 'modified' DATETIME, PRIMARY KEY(entityId)";
}

-(NSString *)rowIdForEntityId:(NSString *)entityId andType:(NSString *)entityType {
    NSString *query = [NSString stringWithFormat:@"select rowid from %@ where entityId = '%@'", entityType, entityId];
    NSArray *res = [[NUXSQLiteDatabase shared] arrayOfObjectsFromQuery:query block:^id(sqlite3_stmt *stmt) {
        return [NSString stringWithCString:(const char*)sqlite3_column_text(stmt, 0) encoding:NSUTF8StringEncoding];
    }];
    return res.count > 0 ? [res objectAtIndex:0] : nil;
}

-(BOOL)isEntityExistsWithId:(NSString *)entityId andType:(NSString *)entityType {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self entityFilePathWithId:entityId andType:entityType]];
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
    return entityPath;
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
