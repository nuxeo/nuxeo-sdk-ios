//
//  NUXDatabaseTests.m
//  NuxeoSDK
//  Created by Arnaud Kervern on 2013-11-28.
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
    XCTAssertTrue([db executeQuery:query withParameters:nil], @"Error: %@ (%@)", [db sqlInformatiomFromCode:[db lastReturnCode]], query);
    
    query = [NSString stringWithFormat:@"create table '%@' ('id' varchar, 'position' integer);", tblNAme];
    XCTAssertTrue([db executeQuery:query withParameters:nil], @"Error: %@ (%@)", [db sqlInformatiomFromCode:[db lastReturnCode]], query);
    
    query = [NSString stringWithFormat:@"insert into '%@' ('wrongField', 'dsadsad') values (?,?);", tblNAme];
    NSArray *params = @[@"abc", @(123)];
    XCTAssertFalse([db executeQuery:query withParameters:params], @"Error: %@ (%@)", [db sqlInformatiomFromCode:[db lastReturnCode]], query);
    
    query = [NSString stringWithFormat:@"insert into '%@' ('id', 'position') values (?, ?);", tblNAme];
    XCTAssertTrue([db executeQuery:query withParameters:params], @"Error: %@ (%@)", [db sqlInformatiomFromCode:[db lastReturnCode]], query);
}

-(void)testHierarchyQuery
{
    NUXHierarchyDB *hDb = [NUXHierarchyDB shared];
    NSString *hName = @"test";
    NUXDocument *parent = [self dummyDocument];
    NSArray *root = @[[self dummyDocument], [self dummyDocument], [self dummyDocument]];
    
    NUXDocument *childParent = [root objectAtIndex:0];
    NSArray *child = @[[self dummyDocument], [self dummyDocument]];
    
    [hDb insertNodes:root fromHierarchy:hName withParent:parent andDepth:0];
    NSArray *docs = [hDb selectNodesFromParent:parent.path hierarchy:hName];
    XCTAssertTrue(3 == docs.count);
    
    
    
    [hDb insertNodes:child fromHierarchy:hName withParent:childParent andDepth:0];
    docs = [hDb selectNodesFromParent:childParent.uid hierarchy:hName];
    XCTAssertTrue(2 == docs.count);
}

@end
