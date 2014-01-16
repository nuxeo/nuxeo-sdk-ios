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

#import <Foundation/Foundation.h>
#import "NUXAbstractTestCase.h"

@interface NUXEntityCache (private)
-(void)createTableIfNotExists;
@end

@interface NUXEntityCacheTests : NUXAbstractTestCase

@end

@interface NUXEntityCache (internal)
-(BOOL)writeEntity:(NUXEntity<NUXEntityPersistable> *)entity;
-(id)readEntityWithId:(NSString *)entityId andType:(NSString *)entityType;
-(NSString *)entityFilePathWithId:(NSString *)entityId andType:(NSString *)entityType;
@end

@implementation NUXEntityCacheTests {
    NUXEntityCache *cache;
}

- (void)setUp {
    [super setUp];
    cache = [NUXEntityCache instance];
    [cache createTableIfNotExists];
}

- (void)tearDown {
    [super tearDown];
}

-(void)testReadWriteFile {
    NUXDocument *doc = [self dummyDocument];
    
    XCTAssertTrue([cache writeEntity:doc]);
    NUXDocument *read = [cache readEntityWithId:doc.entityId andType:doc.entityType];
    
    XCTAssertNotNil(read);
    XCTAssertEqualObjects(doc.uid, read.uid);
    
    NSString *path = [cache entityFilePathWithId:doc.entityId andType:doc.entityType];
    XCTAssertTrue([path rangeOfString:doc.entityType].location != NSNotFound);
}

-(void)testPublicMethod {
    NUXDocument *doc = [self dummyDocument];
    XCTAssertTrue([cache saveEntity:doc]);
    
    NUXDocument *read = [cache entityWithId:doc.uid class:[NUXDocument class]];
    XCTAssertEqualObjects(read.uid, doc.uid);
    
    XCTAssertTrue([cache removeEntityWithId:doc.uid class:[NUXDocument class]]);
    XCTAssertFalse([cache removeEntityWithId:doc.uid class:[NUXDocument class]]);
    XCTAssertNil([cache entityWithId:doc.uid class:[NUXDocument class]]);
}

-(void)testCustomExceptionRaising {
    XCTAssertThrowsSpecific([NUXException raise:@"Pouet" format:@"Error: dasdsad"], NUXException, @"should thow a NUXException");
    XCTAssertNoThrowSpecific([NSException raise:@"Pouet" format:@"Error: dasdsad"], NUXException, @"should thow a NUXException");
}

-(void)testInsertEntitiesList {
    NSArray *docs = @[[self dummyDocument], [self dummyDocument], [self dummyDocument], [self dummyDocument], [self dummyDocument], [self dummyDocument], [self dummyDocument]];
    NSString *listName = @"testList";
    XCTAssertTrue([cache saveEntities:docs withListName:listName error:nil]);
    
    XCTAssertTrue([cache hasEntityList:listName]);
    NSArray *cached = [cache entitiesFromList:listName];
    
    XCTAssertEqual([docs count], [cached count]);

    for (NSInteger idx = 0; idx < [docs count]; idx++) {
        XCTAssertEqualObjects([[docs objectAtIndex:idx] entityId], [[cached objectAtIndex:idx] entityId]);
    }
    
    [cache removeEntitiesList:listName];
    XCTAssertFalse([cache hasEntityList:listName]);
    cached = [cache entitiesFromList:listName];
    XCTAssertEqualObjects([NSNumber numberWithInt:0], [NSNumber numberWithInt:[cached count]]);
}

@end
