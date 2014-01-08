//
//  NUXBlobStoreTests.m
//  NuxeoSDK
//  Created by Arnaud Kervern on 2013-12-04.
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
#import "NUXBlobStore.h"

@interface NUXBlobStore (private)
-(NSString *)saveBlobFromPath:(NSString *)path withDigest:(NSString *)digest filename:(NSString *)filename error:(NSError **)error;
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
        [bs saveBlobFromPath:filePath withDigest:digest filename:@"file1" error:nil];
    }
    
    NSLog(@"Count1: %ld", (long)[bs count]);
    XCTAssertTrue(5 == [bs count], @"Count should be 5 but is %@", @([bs count]));
    
    NSString *filename = @"MyFileName";
    [bs saveBlobFromPath:filePath withDigest:[digests objectAtIndex:0] filename:filename error:nil];
    [bs saveBlobFromPath:filePath withDigest:[digests objectAtIndex:1] filename:@"file2" error:nil];
    [bs saveBlobFromPath:filePath withDigest:[digests objectAtIndex:2] filename:@"file3" error:nil];
    NSLog(@"Count2: %ld", (long)[bs count]);
    XCTAssertTrue(5 == [bs count], @"Count should be 5 but is %@", @([bs count]));
    
    XCTAssertEqualObjects(filename, [[bs blob:[digests objectAtIndex:0]] lastPathComponent]);
    XCTAssertNotEqualObjects(filename, [[bs blob:[digests objectAtIndex:1]] lastPathComponent]);
}

-(void)testThatLatestItemIsRemoved {
    NSInteger nbFiles = 6;
    NSString *digest = [self randomDigest];
    [bs saveBlobFromPath:filePath withDigest:digest filename:@"file1" error:nil];
    
    NSString *ndDigest = [self randomDigest];
    [bs saveBlobFromPath:filePath withDigest:ndDigest filename:@"file1" error:nil];
    
    // Loop 2 times, to change access order of the second inserted file to still have it in the cache
    for (int i = 0; i < nbFiles; i++) {
        [bs saveBlobFromPath:filePath withDigest:[self randomDigest] filename:@"file1" error:nil];
    }
    [bs blob:ndDigest];
    for (int i = 0; i < nbFiles; i++) {
        [bs saveBlobFromPath:filePath withDigest:[self randomDigest] filename:@"file1" error:nil];
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
        [bs saveBlobFromPath:filePath withDigest:[self randomDigest] filename:@"file1" error:nil];
    }
    
    XCTAssertTrue(5 == [bs count], @"Size limit count should be 6 but is %@", @([bs count]));
}

@end
