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
}

@end
