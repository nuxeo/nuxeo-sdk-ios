
//
//  NUXDatabaseTests.m
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 28/11/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import "NUXAbstractTestCase.h"
#import "NUXSQLiteDatabase.h"
#import "NUXHierarchyDB.h"

@interface NUXDatabaseTests : NUXAbstractTestCase

@end

@implementation NUXDatabaseTests {
    NUXSQLiteDatabase *db;
}

- (void)setUp {
    [super setUp];
    
    db = [NUXSQLiteDatabase shared];
}

- (void)tearDown {
    [super tearDown];
    
    [db deleteDatabase];
    db = nil;
}

-(void)testQueryExecution
{
    NSString *tblNAme = @"tmpTable";
    NSString *query = [NSString stringWithFormat:@"drop table if exists '%@';", tblNAme];
    XCTAssertTrue([db executeQuery:query], @"Error: %@ (%@)", [db sqlInformatiomFromCode:[db lastReturnCode]], query);
    
    query = [NSString stringWithFormat:@"create table '%@' ('id' varchar, 'position' integer);", tblNAme];
    XCTAssertTrue([db executeQuery:query], @"Error: %@ (%@)", [db sqlInformatiomFromCode:[db lastReturnCode]], query);
    
    query = [NSString stringWithFormat:@"insert into '%@' ('wrongField', 'dsadsad') values ('abc', 123);", tblNAme];
    XCTAssertFalse([db executeQuery:query], @"Error: %@ (%@)", [db sqlInformatiomFromCode:[db lastReturnCode]], query);
    
    query = [NSString stringWithFormat:@"insert into '%@' ('id', 'position') values ('abc', 123);", tblNAme];
    XCTAssertTrue([db executeQuery:query], @"Error: %@ (%@)", [db sqlInformatiomFromCode:[db lastReturnCode]], query);
}

-(void)testHierarchyQuery
{
    NUXHierarchyDB *hDb = [NUXHierarchyDB shared];
    NSString *hName = @"test";
    NSArray *root = @[[self dummyDocument], [self dummyDocument], [self dummyDocument]];
    
    NUXDocument *childParent = [root objectAtIndex:0];
    NSArray *child = @[[self dummyDocument], [self dummyDocument]];
    
    [hDb insertNodes:root fromHierarchy:hName withParent:@"/" andDepth:0];
    NSArray *docs = [hDb selectNodesFromParent:@"/" hierarchy:hName];
    XCTAssertTrue(3 == docs.count);
    
    
    
    [hDb insertNodes:child fromHierarchy:hName withParent:childParent.uid andDepth:0];
    docs = [hDb selectNodesFromParent:childParent.uid hierarchy:hName];
    XCTAssertTrue(2 == docs.count);
}

@end
