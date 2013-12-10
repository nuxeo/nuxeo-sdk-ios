//
//  NUXHierarchyDB.m
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 03/12/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import "NUXHierarchyDB.h"
#import "NUXSQLiteDatabase.h"
#import "NUXHierarchy.h"
#import "NUXEntityCache.h"

#define kHierarchyTable @"hierarchyNode"
#define kContentTable @"hierarchyContent"

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
    [_db createTableIfNotExists:kHierarchyTable withField:@"'hierarchyName' TEXT, 'docId' TEXT, 'parentId' TEXT, 'parentPath' TEXT, 'depth' INTEGER, 'order' INTEGER"];
    [_db createTableIfNotExists:kContentTable withField:@"'hierarchyName' TEXT, 'docId' TEXT, 'parentId' TEXT, 'order' INTEGER"];
}

-(void)dropTable {
    [_db dropTableIfExists:kHierarchyTable];
    [_db dropTableIfExists:kContentTable];
}

-(void)deleteNodesFromHierarchy:(NSString *)hierarchyName {
    NSString *query = [NSString stringWithFormat:@"delete from %@ where hierarchyName = \"%@\"", kHierarchyTable, hierarchyName];
    [_db executeQuery:query];

    query = [NSString stringWithFormat:@"delete from %@ where hierarchyName = \"%@\"", kContentTable, hierarchyName];
    [_db executeQuery:query];
}

-(void)deleteContentForDocument:(NUXDocument *)document fromHierarchy:(NSString *)hierarchyName {
    NSString *query = [NSString stringWithFormat:@"delete from %@ where hierarchyName = \"%@\" and parentId = \"%@\"", kContentTable, hierarchyName, document.uid];
    [_db executeQuery:query];
}

-(void)insertNodes:(NSArray *)docs fromHierarchy:(NSString *)hierarchyName withParent:(NUXDocument *)parent andDepth:(NSInteger)depth {
    return [self insertInHierarchyNodes:docs fromHierarchy:hierarchyName withParent:parent andDepth:depth];
}

-(void)insertcontent:(NSArray *)docs fromHierarchy:(NSString *)hierarchyName forNode:(NSString *)nodeId {
    return [self insertInContentNodes:docs fromHierarchy:hierarchyName withParent:nodeId];
}

-(NSArray *)selectNodesFromParent:(NSString *)parentRef hierarchy:(NSString *)hierarchyName {
    return [self selectFromTable:kHierarchyTable parent:parentRef hierarchy:hierarchyName];
}

-(NSArray *)selectContentFromNode:(NSString *)nodeId hierarchy:(NSString *)hierarchyName {
    return [self selectFromTable:kContentTable parent:nodeId hierarchy:hierarchyName];
}

-(NSArray *)selectAllContentFromHierarchy:(NSString *)hierarchyName {
    return [self selectFromTable:kContentTable parent:nil hierarchy:hierarchyName];
}


-(NSInteger)selectDepthForDocument:(NSString *)documentId hierarchy:(NSString *)hierarchyName {
    NSString *query = [NSString stringWithFormat:@"Select depth from %@ where docId = \"%@\" and hierarchyName = \"%@\"", kHierarchyTable, documentId, hierarchyName];
    NSArray *ret = [_db arrayOfObjectsFromQuery:query block:^id(sqlite3_stmt *stmt) {
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
    NSString *columns = [NUXHierarchyDB sqlitize:@[@"hierarchyName", @"docId", @"parentId", @"order"]];
    NSString *bQuery = [NSString stringWithFormat:@"insert into %@ (%@) values (%@)", kContentTable, columns, @"%@"];
    
    [docs enumerateObjectsUsingBlock:^(NUXDocument *doc, NSUInteger idx, BOOL *stop) {
        // Save entity in cache
        [[NUXEntityCache instance] saveEntity:doc];
        
        NSString *values = [NUXHierarchyDB sqlitize:@[hierarchyName, doc.uid, parentId, @(idx)]];
        if (![_db executeQuery:[NSString stringWithFormat:bQuery, values]]) {
            // Handle error
            NUXDebug(@"%@", [_db sqlInformatiomFromCode:[_db lastReturnCode]]);
        }
    }];
}

-(void)insertInHierarchyNodes:(NSArray *)docs fromHierarchy:(NSString *)hierarchyName withParent:(NUXDocument *)parent andDepth:(NSInteger)depth {
    NSString *columns = [NUXHierarchyDB sqlitize:@[@"hierarchyName", @"docId", @"parentId", @"parentPath", @"order", @"depth"]];
    NSString *bQuery = [NSString stringWithFormat:@"insert into %@ (%@) values (%@)", kHierarchyTable, columns, @"%@"];
    
    [docs enumerateObjectsUsingBlock:^(NUXDocument *doc, NSUInteger idx, BOOL *stop) {
        // Save entity in cache
        [[NUXEntityCache instance] saveEntity:doc];
        
        NSString *parentUid = parent == nil ? kRootKey : parent.uid;
        NSString *parentPath = parent == nil ? @"" : parent.path;
        
        NSString *values = [NUXHierarchyDB sqlitize:@[hierarchyName, doc.uid, parentUid, parentPath, @(idx), @(depth)]];
        if (![_db executeQuery:[NSString stringWithFormat:bQuery, values]]) {
            // Handle error
            NUXDebug(@"%@", [_db sqlInformatiomFromCode:[_db lastReturnCode]]);
        }
    }];
}

-(NSArray *)selectFromTable:(NSString *)table parent:(NSString *)parentId hierarchy:(NSString *)hierarchyName {
    NSString *query;
    if (!parentId) {
        query = [NSString stringWithFormat:@"select docId from %@ where hierarchyName = '%@' order by 'order'", table, hierarchyName];
    } else {
        NSString *field = [self fieldForDocumentRef:parentId];
        query = [NSString stringWithFormat:@"select docId from %@ where %@ = '%@' and hierarchyName = '%@' order by 'order'", table, field, parentId, hierarchyName];
    }
    
    NSArray *ret = [_db arrayOfObjectsFromQuery:query block:^id(sqlite3_stmt *stmt) {
        NSString *docId = [NSString stringWithCString:(const char*)sqlite3_column_text(stmt, 0) encoding:NSUTF8StringEncoding];
        // Entities must be in cache.
        return [[NUXEntityCache instance] entityWithId:docId class:[NUXDocument class]];;
    }];
    return ret;
}

#pragma mark
#pragma shared accessor

-(NSString *)fieldForDocumentRef:(NSString *)docRef {
    return [docRef characterAtIndex:0] == '/' ? @"parentPath" : @"parentId";
}

+(NSString *)sqlitize:(NSArray *)values {
    NSMutableString *ret = [NSMutableString new];
    [values enumerateObjectsUsingBlock:^(id value, NSUInteger idx, BOOL *stop) {
        if (idx > 0) {
            [ret appendString:@", "];
        }
        
        if (![value isKindOfClass:[NSNumber class]]) {
            [ret appendString:[NSString stringWithFormat:@"\"%@\"", value]];
        } else {
            [ret appendString:[NSString stringWithFormat:@"%@", value]];
        }
    }];
    
    return ret;
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
