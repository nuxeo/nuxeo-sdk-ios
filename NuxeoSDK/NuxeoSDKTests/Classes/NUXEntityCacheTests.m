//
//  NUXEntityCache.m
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 05/12/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NUXAbstractTestCase.h"

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

@end
