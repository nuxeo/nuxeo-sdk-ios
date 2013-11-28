//
//  NUXHierarchyTest.m
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 27/11/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import "NUXAbstractTestCase.h"
#import "NUXHierarchy.h"

@interface NUXHierarchyTest : NUXAbstractTestCase

@end

@implementation NUXHierarchyTest {
    NUXHierarchy *hierarchy;
}

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testDocumentSorter {
    NUXRequest *request = [session requestQuery:@"select * from Document where ecm:mixinType = 'Folderish'"];
    hierarchy = [[NUXHierarchy alloc] initWithRequest:request];
    [hierarchy waitUntilLoadingIsDone];
    
    XCTAssertTrue(hierarchy.isLoaded);
    XCTAssertTrue(hierarchy.childrenOfRoot.entries.count >= 3);
    
    // find default-domain
    NUXDocuments *entries = hierarchy.childrenOfRoot;
    NUXDocument *defaultDomain = [NUXHierarchyTest findDocumentInEntries:entries withCompareBlock:^bool(NUXDocument *doc) {
        return [doc.path isEqualToString:@"/default-domain"];
    }];
    XCTAssertNotNil(defaultDomain);
    
    entries = [hierarchy childrenOfDocument:defaultDomain];
    NUXDocument *workspaces = [NUXHierarchyTest findDocumentInEntries:entries withCompareBlock:^bool(NUXDocument *doc) {
        return [doc.path hasSuffix:@"workspaces"];
    }];
    XCTAssertNotNil(workspaces);
}

-(void)testOnlyOneDocHierarchy {
    NUXRequest *request = [session requestQuery:@"select * from Domain"];
    hierarchy = [[NUXHierarchy alloc] initWithRequest:request];
    [hierarchy waitUntilLoadingIsDone];

    XCTAssertTrue(hierarchy.isLoaded);
    XCTAssertTrue(hierarchy.childrenOfRoot.entries.count == 1);

    NUXDocuments *entries = hierarchy.childrenOfRoot;
    NUXDocument *domain = [NUXHierarchyTest findDocumentInEntries:entries withCompareBlock:^bool(NUXDocument *doc) {
        return [doc.path isEqualToString:@"/default-domain"];
    }];
    
    XCTAssertNil([hierarchy childrenOfDocument:domain]);
}

-(void)testHierarchyWithMoreResultsThanPageSize {
    NUXRequest *request = [session requestQuery:@"select * from Document where ecm:mixinType = 'Folderish'"];
    [request addParameterValue:@"3" forKey:@"pageSize"];
    
    hierarchy = [[NUXHierarchy alloc] initWithRequest:request];
    [hierarchy waitUntilLoadingIsDone];
    
    XCTAssertTrue(hierarchy.isLoaded);
    XCTAssertTrue(hierarchy.childrenOfRoot.entries.count >= 3);
}

-(void)testLeafBlock {
    NUXRequest *request = [session requestQuery:@"select * from Document where ecm:mixinType = 'Folderish'"];
    NSMutableArray *leaf = [NSMutableArray new];
    hierarchy = [[NUXHierarchy alloc] initWithRequest:request leafBlock:^NSArray *(NUXEntity *entity) {
        NUXDocument *doc = (NUXDocument *)entity;
        [leaf addObject:doc];
        
        NSMutableArray *children = [NSMutableArray new];
        [children addObject:[NUXDocument new]];
        [children addObject:[NUXDocument new]];
        
//        NSLog(@"BLOCK %@", doc);
        
        return children;
    }];
    [hierarchy waitUntilLoadingIsDone];
    
    XCTAssertTrue([leaf count] > 0);
    [leaf enumerateObjectsUsingBlock:^(NUXDocument *doc, NSUInteger idx, BOOL *stop) {
        NSLog(@"\nLeaf: %@\n%@", doc.uid, [hierarchy childrenOfDocument:doc].entries);
        XCTAssertEqualObjects(@2, @([hierarchy childrenOfDocument:doc].entries.count));
    }];
}

+(NUXDocument *)findDocumentInEntries:(NUXDocuments *)documents withCompareBlock:(bool (^)(NUXDocument *))compareBlock {
    NUXDocument *__block result;
    [documents.entries enumerateObjectsUsingBlock:^(NUXDocument *doc, NSUInteger idx, BOOL *stop) {
        if (compareBlock(doc)) {
            *stop = YES;
            result = doc;
        }
    }];
    return result;
}

@end
