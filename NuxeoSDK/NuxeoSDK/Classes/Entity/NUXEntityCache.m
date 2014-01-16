//
//  NUXEntityCache.m
//  NuxeoSDK
//  Created by Arnaud Kervern on 2013-12-05.
//
/* (C) Copyright 2013-2014 Nuxeo SA (http://nuxeo.com/) and contributors.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the GNU Lesser General Public License
 * (LGPL) version 2.1 which accompanies this distribution, and is available at
 * http://www.gnu.org/licenses/lgpl-2.1.html
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * Contributors:
 *     Arnaud Kervern
 */

#import "NUXEntityCache.h"
#import "NUXSQLiteDatabase.h"
#import "NUXJSONSerializer.h"

#define kEntitiesCacheName @"org.nuxeo.cache.entity"
#define kEntitiesListTableName @"entitiesListName"

#define kEntitiesInsertClassError @"entitiesClassError"
#define kEntitiesInsertQueryError @"queryError"
#define kEntitiesInsertWriteError @"writeError"

@implementation NUXEntityCache {
    NUXSQLiteDatabase *_db;
}

-(id)init {
    self = [super init];
    if (self) {
        _db = [NUXSQLiteDatabase shared];
        [self createTableIfNotExists];
    }
    return self;
}

-(void)createTableIfNotExists {
    [_db createTableIfNotExists:kEntitiesListTableName withField:[self entityListFields]];
}

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

-(NSArray *)entitiesFromList:(NSString *)aListName
{
    return [self readEntitiesFromList:aListName];
}

-(BOOL)saveEntities:(NSArray *)entities withListName:(NSString *)aListName error:(NSError **)error
{
    [self dropEntitiesListEntries:aListName];
    
    NSString *columns = [NUXSQLiteDatabase sqlitize:@[@"listName", @"entityId", @"entityPath", @"order"]];
    NSString *bQuery = [NSString stringWithFormat:@"insert into %@ (%@) values (%@)", kEntitiesListTableName, columns, @"%@"];
    
    NSMutableDictionary *errors = [NSMutableDictionary new];
    [entities enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (!([obj isKindOfClass:[NUXEntity class]] || [obj conformsToProtocol:@protocol(NUXEntityPersistable)])) {
            [errors setObject:kEntitiesInsertClassError forKey:[obj description]];
            return;
        }
        NUXEntity<NUXEntityPersistable> *entity = (NUXEntity<NUXEntityPersistable> *)obj;
        
        if (![self writeEntity:entity]) {
            [errors setObject:kEntitiesInsertWriteError forKey:[obj description]];
            return;
        }
        
        NSString *path = [self entityFilePathWithId:entity.entityId andType:entity.entityType];
        NSString *fields = [NUXSQLiteDatabase sqlitize:@[aListName, entity.entityId, path, [NSNumber numberWithInt:idx]]];
        if (![_db executeQuery:[NSString stringWithFormat:bQuery, fields]]) {
            [errors setObject:kEntitiesInsertQueryError forKey:[obj description]];
            return;
        }
    }];
    
    if (errors.count > 0) {
        if (error != nil) {
            // Fill nserror with errors info
        }
        return NO;
    }
    return YES;
}

-(BOOL)removeEntitiesList:(NSString *)aListName
{
    return [self dropEntitiesListEntries:aListName];
}

-(BOOL)hasEntityWithId:(NSString *)entityId class:(Class)entityClass
{
    NSString *entityPath = [self entityFilePathWithId:entityId andType:[self entityTypeFromClass:entityClass]];
    return [[NSFileManager defaultManager] fileExistsAtPath:entityPath];
}

-(BOOL)hasEntityList:(NSString *)aListName
{
    return [self countListEntries:aListName] > 0;
}

#pragma mark -
#pragma mark Internal methods

-(NSString *)entityTypeFromClass:(Class)aClass {
    if (![aClass isSubclassOfClass:[NUXEntity class]]) {
        [NUXException raise:@"Incompatible class" format:@"Provided class isn't a subclass of %@", [NUXEntity class]];
    }
    return ((NUXEntity *)[aClass new]).entityType;
}

-(NSString *)entityListFields
{
    return @"'listName' TEXT, 'entityId' TEXT, 'entityPath' TEXT, 'order' INTEGER";
}

-(NSArray *)readEntitiesFromList:(NSString *)aListName
{
    NSString *query = [NSString stringWithFormat:@"select entityPath from %@ where listName LIKE ? order by 'order'", kEntitiesListTableName];
    NSArray *res = [_db arrayOfObjectsFromQuery:query parameters:@[aListName] block:^id(sqlite3_stmt *stmt) {
        NSString *entityPath = [NSString stringWithCString:(const char*)sqlite3_column_text(stmt, 0) encoding:NSUTF8StringEncoding];
        return [self readEntityFromPath:entityPath];
    }];
    return res;
}

-(NSInteger)countListEntries:(NSString *)aListName
{
    NSString *query = [NSString stringWithFormat:@"Select count(rowId) from %@ where listName = ?", kEntitiesListTableName];
    NSArray *ret = [_db arrayOfObjectsFromQuery:query parameters:@[aListName] block:^id(sqlite3_stmt *stmt) {
        return @(sqlite3_column_int(stmt, 0));
    }];
    return [ret count] > 0 ? [[ret objectAtIndex:0] integerValue] : 0;
}

-(BOOL)dropEntitiesListEntries:(NSString *)aListName
{
    NSString *query = [NSString stringWithFormat:@"delete from %@ where listName = \"%@\"", kEntitiesListTableName, aListName];
    return [_db executeQuery:query];
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
    return [self readEntityFromPath:entityFilePath];
}

-(id)readEntityFromPath:(NSString *)entityFilePath
{
    NSFileManager *manager = [NSFileManager defaultManager];
    id entity = nil;
    if ([manager isReadableFileAtPath:entityFilePath]) {
        NSData *data = [manager contentsAtPath:entityFilePath];
        entity = [NUXJSONSerializer entityWithData:data error:nil];
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
            [NUXException raise:@"Can't create entity folder" format:@"Unable to create entity cache folder at path: %@. %@", entityPath, error];
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
