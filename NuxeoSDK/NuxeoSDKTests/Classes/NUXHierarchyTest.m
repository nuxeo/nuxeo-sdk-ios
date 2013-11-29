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
    XCTAssertTrue(hierarchy.childrenOfRoot.count >= 3);
    
    // find default-domain
    NSArray *entries = hierarchy.childrenOfRoot;
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
    XCTAssertTrue(hierarchy.childrenOfRoot.count == 1);

    NSArray *entries = hierarchy.childrenOfRoot;
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
    XCTAssertTrue(hierarchy.childrenOfRoot.count >= 3);
}

-(void)testLeafBlock {
    NUXRequest *request = [session requestQuery:@"select * from Document where ecm:mixinType = 'Folderish'"];
    NSMutableArray *leaf = [NSMutableArray new];
    BOOL __block workspacesChecked = NO;
    BOOL __block defaultDomainChecked = NO;
    hierarchy = [[NUXHierarchy alloc] initWithRequest:request nodeBlock:^NSArray *(NUXEntity *entity, NSUInteger depth) {
        NUXDocument *doc = (NUXDocument *)entity;
        if ([doc.path isEqualToString:@"/default-domain"]) {
            XCTAssertEqualObjects(@0, @(depth));
            defaultDomainChecked = YES;
        }
        if ([doc.path isEqualToString:@"/default-domain/workspaces"]) {
            XCTAssertEqualObjects(@1, @(depth));
            workspacesChecked = YES;
        }
        
        [leaf addObject:doc];
        
        NSMutableArray *children = [NSMutableArray new];
        [children addObject:[NUXDocument new]];
        [children addObject:[NUXDocument new]];
        
        return children;
    }];
    [hierarchy waitUntilLoadingIsDone];
    
    XCTAssertTrue([leaf count] > 0);
    [leaf enumerateObjectsUsingBlock:^(NUXDocument *doc, NSUInteger idx, BOOL *stop) {
        NSLog(@"\nLeaf: %@\n%lu", doc.uid, (unsigned long)[hierarchy contentOfDocument:doc].count);
        XCTAssertEqualObjects(@2, @([hierarchy contentOfDocument:doc].count));
    }];
    XCTAssertTrue(workspacesChecked && defaultDomainChecked);
}

+(NUXDocument *)findDocumentInEntries:(NSArray *)documents withCompareBlock:(bool (^)(NUXDocument *))compareBlock {
    NUXDocument *__block result;
    [documents enumerateObjectsUsingBlock:^(NUXDocument *doc, NSUInteger idx, BOOL *stop) {
        if (compareBlock(doc)) {
            *stop = YES;
            result = doc;
        }
    }];
    return result;
}

@end
