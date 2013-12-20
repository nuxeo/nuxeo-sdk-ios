//
//  NUXBlobStoreTests.m
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 04/12/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import "NUXAbstractTestCase.h"
#import "NUXBlobStore.h"

@interface NUXBlobStore (private)
    -(NSString *)saveBlobFromPath:(NSString *)path withDigest:(NSString *)digest error:(NSError **)error;
@end

@interface NUXBlobStoreTests : NUXAbstractTestCase

@end

@implementation NUXBlobStoreTests {
    NUXBlobStore *bs;
    NUXDocument *doc;
    
    NSString *docDigest;
    NSString *filePath;
}

-(void)setUp {
    [super setUp];
    bs = [NUXBlobStore instance];
    bs.sizeLimit = @(-1);
    bs.countLimit = @(10);
    
    doc = [self dummyDocument];
    docDigest = [[doc.properties valueForKey:@"file:content"] valueForKey:@"digest"];
    filePath = [[NSBundle bundleForClass:[NUXSession class]] pathForResource:@"NUXSession-info" ofType:@"plist"];
}

-(void)tearDown {
    [super tearDown];
    [bs reset];
}

-(NSString *)randomDigest {
    return [NSString stringWithFormat:@"di%@", @(random())];
}

-(void)testSavedFileInBlobStore {
    XCTAssertFalse([bs hasBlobFromDocument:doc metadataXPath:@"file:content"]);
    XCTAssertFalse([bs hasBlob:docDigest]);
    
    NSString *storePath = [bs saveBlobFromPath:filePath withDocument:doc metadataXPath:@"file:content" error:nil];
    XCTAssertNotNil(storePath);
    
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:storePath]);
    XCTAssertTrue([bs hasBlob:docDigest]);
    XCTAssertTrue([bs hasBlobFromDocument:doc metadataXPath:@"file:content"]);
    
    XCTAssertEqualObjects(storePath, [bs blob:docDigest]);
    XCTAssertEqualObjects(storePath, [bs blobFromDocument:doc metadataXPath:@"file:content"]);
    
    XCTAssertTrue([bs removeBlob:docDigest]);
    XCTAssertFalse([bs hasBlob:docDigest]);
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:storePath]);
    
    NSString *ndStorePath = [bs saveBlobFromPath:filePath withDocument:doc metadataXPath:@"file:content" error:nil];
    XCTAssertEqualObjects(storePath, ndStorePath);
    XCTAssertTrue(1 == [bs count]);
    
    [bs reset];
    XCTAssertTrue(1 != [bs count]);
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:storePath]);
}

-(void)testMultipleFileInStore {
    NSInteger nbFiles = 5;
    NSMutableArray *digests = [NSMutableArray new];
    for (int i = 0; i < nbFiles; i++) {
        NSString *digest = [self randomDigest];
        
        [digests addObject:digest];
        [bs saveBlobFromPath:filePath withDigest:digest error:nil];
    }
    
    XCTAssertTrue(5 == [bs count], @"Count should be 5 but is %@", @([bs count]));
    
    [bs saveBlobFromPath:filePath withDigest:[digests objectAtIndex:0] error:nil];
    [bs saveBlobFromPath:filePath withDigest:[digests objectAtIndex:1] error:nil];
    [bs saveBlobFromPath:filePath withDigest:[digests objectAtIndex:2] error:nil];
    XCTAssertTrue(5 == [bs count], @"Count should be 5 but is %@", @([bs count]));
}

-(void)testThatLatestItemIsRemoved {
    NSInteger nbFiles = 6;
    NSString *digest = [self randomDigest];
    [bs saveBlobFromPath:filePath withDigest:digest error:nil];
    
    NSString *ndDigest = [self randomDigest];
    [bs saveBlobFromPath:filePath withDigest:ndDigest error:nil];
    
    // Loop 2 times, to change access order of the second inserted file to still have it in the cache
    for (int i = 0; i < nbFiles; i++) {
        [bs saveBlobFromPath:filePath withDigest:[self randomDigest] error:nil];
    }
    [bs blob:ndDigest];
    for (int i = 0; i < nbFiles; i++) {
        [bs saveBlobFromPath:filePath withDigest:[self randomDigest] error:nil];
    }
    
    XCTAssertTrue(10 == [bs count], @"Count should be 10 but is %@", @([bs count]));
    XCTAssertFalse([bs hasBlob:digest]);
    XCTAssertTrue([bs hasBlob:ndDigest]);
}

-(void)testThatSizeLimitWorks {
    long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
    // Should allow to store only 5 files
    bs.sizeLimit = @(fileSize * 5.5);

    for (int i = 0; i < 7; i++) {
        [bs saveBlobFromPath:filePath withDigest:[self randomDigest] error:nil];
    }
    
    XCTAssertTrue(5 == [bs count], @"Size limit count should be 6 but is %@", @([bs count]));
}

@end
