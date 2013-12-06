//
//  NUXHierarchyDB.m
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 03/12/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import "NUXHierarchyDB.h"
#import "NUXSQLiteDatabase.h"
#import "NUXDocument.h"
#import "NUXHierarchy.h"
#import "NUXEntityCache.h"

#define kHierarchyTable @"hierarchyNode"

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
    [_db createTableIfNotExists:kHierarchyTable withField:@"'hierarchyName' TEXT, 'docId' TEXT, 'parentId' TEXT, 'content' TEXT, 'order' INTEGER"];
}

-(void)insertNodes:(NSArray *)docs fromHierarchy:(NSString *)hierarchyName withParent:(NSString *)parentId {
    NSString *columns = [NUXHierarchyDB sqlitize:@[@"hierarchyName", @"docId", @"parentId", @"content", @"order"]];
    NSString *bQuery = [NSString stringWithFormat:@"insert into %@ (%@) values (%@)", kHierarchyTable, columns, @"%@"];
    
    [docs enumerateObjectsUsingBlock:^(NUXDocument *doc, NSUInteger idx, BOOL *stop) {
        // Save entity in cache
        [[NUXEntityCache instance] saveEntity:doc];
        
        NSString *values = [NUXHierarchyDB sqlitize:@[hierarchyName, doc.uid, parentId, @"", @(idx)]];
        if (![_db executeQuery:[NSString stringWithFormat:bQuery, values]]) {
            // Handle error
            NUXDebug(@"%@", [_db sqlInformatiomFromCode:[_db lastReturnCode]]);
        }
    }];
}

-(NSArray *)selectNodesFromParent:(NSString *)parentId hierarchy:(NSString *)hierarchyName {
    NSString *query = [NSString stringWithFormat:@"select docId, content from %@ where parentId = '%@' and hierarchyName = '%@' order by 'order'", kHierarchyTable, parentId, hierarchyName];
    NSArray *ret = [_db arrayOfObjectsFromQuery:query block:^id(sqlite3_stmt *stmt) {
        NSString *docId = [NSString stringWithCString:(const char*)sqlite3_column_text(stmt, 0) encoding:NSUTF8StringEncoding];
        // Entities must be in cache.
        return [[NUXEntityCache instance] entityWithId:docId class:[NUXDocument class]];;
    }];
    return ret;
}

#pragma mark
#pragma shared accessor

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
