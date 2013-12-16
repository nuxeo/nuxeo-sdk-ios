//
//  NUXHierarchyTest.m
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 27/11/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import "NUXAbstractTestCase.h"
#import "NUXHierarchy.h"
#import "NUXHierarchyDB.h"

@interface NUXHierarchyTest : NUXAbstractTestCase

@end

@implementation NUXHierarchyTest {
    NUXHierarchy *hierarchy;
}

- (void)setUp {
    [super setUp];
    hierarchy = [NUXHierarchy hierarchyWithName:[NSString stringWithFormat:@"hierarchy%d", arc4random()]];
    [[NUXHierarchyDB shared] createTableIfNeeded];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testDocumentSorter {
    NUXRequest *request = [session requestQuery:@"select * from Document where ecm:mixinType = 'Folderish'"];
    [hierarchy loadWithRequest:request];
    [hierarchy waitUntilLoadingIsDone];
    
    XCTAssertTrue(hierarchy.isLoaded);
    XCTAssertTrue(hierarchy.childrenOfRoot.count >= 3);
    
    // find default-domain
    NSArray *entries = hierarchy.childrenOfRoot;
    NUXDocument *defaultDomain = [NUXHierarchyTest findDocumentInEntries:entries withCompareBlock:^bool(NUXDocument *doc) {
        return [doc.path isEqualToString:@"/default-domain"];
    }];
    XCTAssertNotNil(defaultDomain);
    
    entries = [hierarchy childrenOfDocument:defaultDomain.path];
    NUXDocument *workspaces = [NUXHierarchyTest findDocumentInEntries:entries withCompareBlock:^bool(NUXDocument *doc) {
        return [doc.path hasSuffix:@"workspaces"];
    }];
    XCTAssertNotNil(workspaces);
    
    [hierarchy resetCache];
    XCTAssertTrue([hierarchy childrenOfDocument:defaultDomain.uid].count == 0, @"Current childs: %@", @([hierarchy childrenOfDocument:defaultDomain.path].count));
}

-(void)testOnlyOneDocHierarchy {
    NUXRequest *request = [session requestQuery:@"select * from Domain"];
    [hierarchy loadWithRequest:request];
    [hierarchy waitUntilLoadingIsDone];

    XCTAssertTrue(hierarchy.isLoaded);
    XCTAssertTrue(hierarchy.childrenOfRoot.count == 1);

    NSArray *entries = hierarchy.childrenOfRoot;
    NUXDocument *domain = [NUXHierarchyTest findDocumentInEntries:entries withCompareBlock:^bool(NUXDocument *doc) {
        return [doc.path isEqualToString:@"/default-domain"];
    }];
    
    XCTAssertTrue([hierarchy childrenOfDocument:domain.path].count == 0);
}

-(void)testHierarchyWithMoreResultsThanPageSize {
    NUXRequest *request = [session requestQuery:@"select * from Document where ecm:mixinType = 'Folderish'"];
    [request addParameterValue:@"3" forKey:@"pageSize"];
    
    [hierarchy loadWithRequest:request];
    [hierarchy waitUntilLoadingIsDone];
    
    XCTAssertTrue(hierarchy.isLoaded);
    XCTAssertTrue(hierarchy.childrenOfRoot.count >= 3);
}

-(void)testLeafBlock {
    NUXRequest *request = [session requestQuery:@"select * from Document where ecm:mixinType = 'Folderish'"];
    NSMutableArray *__strong leaf = [NSMutableArray new];
    BOOL __block workspacesChecked = NO;
    BOOL __block defaultDomainChecked = NO;
    hierarchy.nodeBlock = ^NSArray *(NUXEntity *entity, NSUInteger depth) {
        NUXDocument *doc = (NUXDocument *)entity;
        if ([doc.path isEqualToString:@"/default-domain"]) {
            XCTAssertEqualObjects(@0, @(depth));
            defaultDomainChecked = YES;
        }
        if ([doc.path isEqualToString:@"/default-domain/workspaces"]) {
            XCTAssertEqualObjects(@1, @(depth));
            workspacesChecked = YES;
        }
        
        if (![hierarchy isLoaded]) {
            [leaf addObject:doc];
        }
        
        NSMutableArray *children = [NSMutableArray new];
        [children addObject:[self dummyDocument]];
        [children addObject:[self dummyDocument]];
        
        return children;
    };
    [hierarchy loadWithRequest:request];
    [hierarchy waitUntilLoadingIsDone];
    
    XCTAssertTrue([leaf count] > 0);
    [leaf enumerateObjectsUsingBlock:^(NUXDocument *doc, NSUInteger idx, BOOL *stop) {
        //NUXDebug(@"\nLeaf: %@\n%lu", doc.uid, (unsigned long)[hierarchy contentOfDocument:doc].count);
        XCTAssertEqualObjects(@2, @([hierarchy contentOfDocument:doc].count));
    }];
    XCTAssertTrue(workspacesChecked && defaultDomainChecked);
    
    NUXDocument *dDomain = [hierarchy nodeWithRef:@"/default-domain"];
    XCTAssertNotNil(dDomain);
    XCTAssertEqualObjects(@"/default-domain", dDomain.path);
}

-(void)testMultipleHierarchies {
    NUXHierarchy *h1 = [NUXHierarchy hierarchyWithName:@"test1"];
    NUXHierarchy *h2 = [NUXHierarchy hierarchyWithName:@"test2"];
    NUXHierarchy *h3 = [NUXHierarchy hierarchyWithName:@"test1"];
    
    XCTAssertNotEqual(h1, h2);
    XCTAssertEqual(h1, h3);
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

-(void)testHasContent {
    NUXRequest *request = [session requestQuery:@"select * from Document where ecm:mixinType = 'SuperSpace'"];
    id __weak wSelf = self;
    hierarchy.nodeBlock = ^NSArray *(NUXEntity *entity, NSUInteger depth) {
        NUXDocument *doc = (NUXDocument *)entity;
        if ([doc.path isEqualToString:@"/default-domain/workspaces"]) {
            return @[[wSelf dummyDocument], [wSelf dummyDocument]];
        }
        return nil;
    };
    
    [hierarchy loadWithRequest:request];
    [hierarchy waitUntilLoadingIsDone];
    
    XCTAssertTrue([hierarchy hasContentUnderNode:@"/default-domain"]);
    XCTAssertTrue([hierarchy hasContentUnderNode:@"/default-domain/workspaces"]);
    
    [hierarchy resetCache];
    hierarchy.nodeBlock = nil;
    [hierarchy loadWithRequest:request];
    [hierarchy waitUntilLoadingIsDone];
    
    XCTAssertFalse([hierarchy hasContentUnderNode:@"/default-domain"]);
    XCTAssertFalse([hierarchy hasContentUnderNode:@"/default-domain/workspaces"]);
}

-(void)testHierarchyLoadedFlag
{
    NSString *name = [NSString stringWithFormat:@"hierar-%@", @(arc4random())];
    NUXHierarchyDB *db = [NUXHierarchyDB shared];
    XCTAssertFalse([db isHierarchyLoaded:name]);
    [db saveHierarchyLoaded:name];
    XCTAssertTrue([db isHierarchyLoaded:name]);
    // Override new loaded
    [db saveHierarchyLoaded:name];
    XCTAssertTrue([db isHierarchyLoaded:name]);
    
    [db deleteNodesFromHierarchy:name];
    XCTAssertFalse([db isHierarchyLoaded:name]);
}

@end
