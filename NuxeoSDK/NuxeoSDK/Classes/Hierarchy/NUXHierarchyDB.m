//
//  NUXHierarchyDB.m
//  NuxeoSDK
//  Created by Arnaud Kervern on 2013-12-03.
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

#import "NUXHierarchyDB.h"
#import "NUXSQLiteDatabase.h"
#import "NUXHierarchy.h"
#import "NUXEntityCache.h"

#define kHierarchyTable @"hierarchyNode"
#define kHierarchyLoadedTable @"hierarchyLoaded"

@implementation NUXHierarchyDB {
    NUXSQLiteDatabase* _db;
}

-(id)init {
    self = [super init];
    if (self) {
        _db = [NUXSQLiteDatabase shared];
    }
    return self;
}

-(void)dealloc {
    _db = nil;
}

#pragma mark
#pragma internal

-(void)createTableIfNeeded {
    [_db createTableIfNotExists:kHierarchyTable withField:@"'hierarchyName' TEXT, 'docId' TEXT, 'docPath' TEXT, 'parentId' TEXT, 'parentPath' TEXT, 'depth' INTEGER, 'order' INTEGER"];
    [_db createTableIfNotExists:kHierarchyLoadedTable withField:@"'hierarchyName' TEXT PRIMARY KEY, 'loaded' INTEGER"];
}

-(void)saveHierarchyLoaded:(NSString *)hierarchyName {
    NSString *query = [NSString stringWithFormat:@"delete from %@ where hierarchyName = \"%@\"", kHierarchyLoadedTable, hierarchyName];
    [_db executeQuery:query];
    
    NSString *columns = [NUXSQLiteDatabase sqlitize:@[@"hierarchyName", @"loaded"]];
    NSString *values = [NUXSQLiteDatabase sqlitize:@[hierarchyName, @(1)]];
    query = [NSString stringWithFormat:@"insert into %@ (%@) values (%@)", kHierarchyLoadedTable, columns, values];
    [_db executeQuery:query];
}

-(BOOL)isHierarchyLoaded:(NSString *)hierarchyName {
    NSString *query = [NSString stringWithFormat:@"select hierarchyName from %@ where hierarchyName = ?", kHierarchyLoadedTable];
    NSArray *ret = [_db arrayOfObjectsFromQuery:query parameters:@[hierarchyName] block:^id(sqlite3_stmt *stmt) {
        return [NSString stringWithCString:(const char*)sqlite3_column_text(stmt, 0) encoding:NSUTF8StringEncoding];
    }];
    return [ret count] > 0;
}

-(void)dropTable {
    [_db dropTableIfExists:kHierarchyTable];
    [_db dropTableIfExists:kHierarchyLoadedTable];
}

-(void)deleteNodesFromHierarchy:(NSString *)hierarchyName {
    NSString *query = [NSString stringWithFormat:@"delete from %@ where hierarchyName = \"%@\"", kHierarchyTable, hierarchyName];
    [_db executeQuery:query];
    query = [NSString stringWithFormat:@"delete from %@ where hierarchyName = \"%@\"", kHierarchyLoadedTable, hierarchyName];
    [_db executeQuery:query];
}

-(void)deleteContentForDocument:(NUXDocument *)document fromHierarchy:(NSString *)hierarchyName {
    [[NUXEntityCache instance] removeEntitiesList:[self contentListNameWithHierarchy:hierarchyName parentId:document.uid]];
}

-(void)insertNodes:(NSArray *)docs fromHierarchy:(NSString *)hierarchyName withParent:(NUXDocument *)parent andDepth:(NSInteger)depth {
    return [self insertInHierarchyNodes:docs fromHierarchy:hierarchyName withParent:parent andDepth:depth];
}

-(void)insertcontent:(NSArray *)docs fromHierarchy:(NSString *)hierarchyName forNode:(NSString *)nodeId {
    return [self insertInContentNodes:docs fromHierarchy:hierarchyName withParent:nodeId];
}

-(NUXDocument *)selectNode:(NSString *)nodeRef hierarchy:(NSString *)hierarchyName {
    NSString *field = [nodeRef characterAtIndex:0] == '/' ? @"docPath" : @"docId";
    NSString *query = [NSString stringWithFormat:@"select docId from %@ where hierarchyName = ? and %@ = ?", kHierarchyTable, field];
    
    NSArray *ret = [_db arrayOfObjectsFromQuery:query parameters:@[hierarchyName, nodeRef] block:^id(sqlite3_stmt *stmt) {
        NSString *docId = [NSString stringWithCString:(const char*)sqlite3_column_text(stmt, 0) encoding:NSUTF8StringEncoding];
        // Entities must be in cache.
        return [[NUXEntityCache instance] entityWithId:docId class:[NUXDocument class]];;
    }];
    
    return [ret count] > 0 ? [ret objectAtIndex:0] : nil;
}

-(BOOL)hasContentForNode:(NSString *)nodeId hierarchy:(NSString *)hierarchyName {
    return [[NUXEntityCache instance] hasEntityList:[self contentListNameWithHierarchy:hierarchyName parentId:nodeId]];
}

-(NSArray *)selectIdsFromParent:(NSString *)parentRef hierarchy:(NSString *)hierarchyName {
    NSString *field = [self fieldForDocumentRef:parentRef];
    NSString *query = [NSString stringWithFormat:@"select docId from %@ where %@ = ? and hierarchyName = ? order by 'order'", kHierarchyTable, field];
    
    NSArray *ret = [_db arrayOfObjectsFromQuery:query parameters:@[parentRef, hierarchyName] block:^id(sqlite3_stmt *stmt) {
        return [NSString stringWithCString:(const char*)sqlite3_column_text(stmt, 0) encoding:NSUTF8StringEncoding];
    }];
    return ret;
}

-(NSArray *)selectNodesFromParent:(NSString *)parentRef hierarchy:(NSString *)hierarchyName {
    return [self selectFromTable:kHierarchyTable parent:parentRef hierarchy:hierarchyName];
}

-(NSArray *)selectContentFromNode:(NSString *)nodeId hierarchy:(NSString *)hierarchyName {
    return [[NUXEntityCache instance] entitiesFromList:[self contentListNameWithHierarchy:hierarchyName parentId:nodeId]];
}

-(NSArray *)selectAllContentFromHierarchy:(NSString *)hierarchyName {
    return [[NUXEntityCache instance] entitiesFromList:[self contentListNameWithHierarchy:hierarchyName parentId:@"%"]];
}


-(NSInteger)selectDepthForDocument:(NSString *)documentId hierarchy:(NSString *)hierarchyName {
    NSString *query = [NSString stringWithFormat:@"Select depth from %@ where docId = ? and hierarchyName = ?", kHierarchyTable];
    NSArray *ret = [_db arrayOfObjectsFromQuery:query parameters:@[documentId, hierarchyName] block:^id(sqlite3_stmt *stmt) {
        return @(sqlite3_column_int(stmt, 0));
    }];
    if ([ret count] > 0) {
        return [[ret objectAtIndex:0] integerValue];
    } else {
        return -1;
    }
}

#pragma mark -

-(void)insertInContentNodes:(NSArray *)docs fromHierarchy:(NSString *)hierarchyName withParent:(NSString *)parentId {
    [[NUXEntityCache instance] saveEntities:docs withListName:[self contentListNameWithHierarchy:hierarchyName parentId:parentId] error:nil];
}

-(void)insertInHierarchyNodes:(NSArray *)docs fromHierarchy:(NSString *)hierarchyName withParent:(NUXDocument *)parent andDepth:(NSInteger)depth {
    NSString *columns = [NUXSQLiteDatabase sqlitize:@[@"hierarchyName", @"docId", @"docPath", @"parentId", @"parentPath", @"order", @"depth"]];
    NSString *bQuery = [NSString stringWithFormat:@"insert into %@ (%@) values (%@)", kHierarchyTable, columns, @"%@"];
    
    [docs enumerateObjectsUsingBlock:^(NUXDocument *doc, NSUInteger idx, BOOL *stop) {
        // Save entity in cache
        [[NUXEntityCache instance] saveEntity:doc];
        
        NSString *parentUid = parent == nil ? kRootKey : parent.uid;
        NSString *parentPath = parent == nil ? @"" : parent.path;
        
        NSString *values = [NUXSQLiteDatabase sqlitize:@[hierarchyName, doc.uid, doc.path, parentUid, parentPath, @(idx), @(depth)]];
        if (![_db executeQuery:[NSString stringWithFormat:bQuery, values]]) {
            // Handle error
            NUXDebug(@"%@", [_db sqlInformatiomFromCode:[_db lastReturnCode]]);
        }
    }];
}

-(NSArray *)selectFromTable:(NSString *)table parent:(NSString *)parentId hierarchy:(NSString *)hierarchyName {
    NSString *query;
    NSArray *params;
    if (!parentId) {
        query = [NSString stringWithFormat:@"select docId from %@ where hierarchyName = ? order by 'order'", table];
        params = @[hierarchyName];
    } else {
        NSString *field = [self fieldForDocumentRef:parentId];
        query = [NSString stringWithFormat:@"select docId from %@ where %@ = ? and hierarchyName = ? order by 'order'", table, field];
        params = @[parentId, hierarchyName];
    }
    
    NSArray *ret = [_db arrayOfObjectsFromQuery:query parameters:params block:^id(sqlite3_stmt *stmt) {
        NSString *docId = [NSString stringWithCString:(const char*)sqlite3_column_text(stmt, 0) encoding:NSUTF8StringEncoding];
        // Entities must be in cache.
        return [[NUXEntityCache instance] entityWithId:docId class:[NUXDocument class]];;
    }];
    return ret;
}

-(NSString *)contentListNameWithHierarchy:(NSString *)hierarchyName parentId:(NSString *)parentId
{
    return [NSString stringWithFormat:@"HIERARCHY_%@_%@", hierarchyName, parentId];
}

#pragma mark
#pragma shared accessor

-(NSString *)fieldForDocumentRef:(NSString *)docRef {
    return [docRef characterAtIndex:0] == '/' ? @"parentPath" : @"parentId";
}

+ (NUXHierarchyDB *)shared {
    static dispatch_once_t pred = 0;
    static NUXHierarchyDB *__strong _shared = nil;
    
    dispatch_once(&pred, ^{
        _shared = [NUXHierarchyDB new];
        [_shared createTableIfNeeded];
    });
    
    return _shared;
}

@end
