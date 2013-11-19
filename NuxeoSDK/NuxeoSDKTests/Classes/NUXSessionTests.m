//
//  NuxeoSDKTests.m
//  NuxeoSDKTests
//
//  Created by Arnaud Kervern on 08/11/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NUXSession.h"
#import "NUXSession+requests.h"

@interface NUXSessionTests : XCTestCase

@end

@implementation NUXSessionTests

NUXSession *session;

- (void)setUp {
    [super setUp];
    NSURL *url = [[NSURL alloc] initWithString:@"http://localhost:8080/nuxeo"];
    session = [[NUXSession alloc] initWithServerURL:url username:@"Administrator" password:@"Administrator"];
}

- (void)tearDown {
    [super tearDown];
    session = Nil;
}

- (void)testSessionInit {
    NUXSession *session = [NUXSession new];
    XCTAssertEqualObjects(@"default", session.repository);

    NSURL *url = [[NSURL alloc] initWithString:@"http://localhost:8080/nuxeo"];
    session = [[NUXSession alloc] initWithServerURL:url username:@"Administrator" password:@"Administrator"];
    XCTAssertEqualObjects(@"default", session.repository);
    XCTAssertEqualObjects(@"Administrator", session.username);
    XCTAssertEqualObjects(@"Administrator", session.password);
    XCTAssertEqualObjects(@"http://localhost:8080/nuxeo/api/v1", session.url.absoluteString);
}

- (void)testBasicRequestExecution {
    NUXRequest *request = [[NUXRequest alloc] initWithSession:session];
    [request addURLSegment:@"doc"];

    XCTAssertFalse(request.responseString.length > 0);
    [session startRequestSynchronous:request withCompletionBlock:^(NUXRequest *rRequest) {
        XCTAssertEqual(rRequest.responseStatusCode, 200);
    }                   failureBlock:^(NUXRequest *rRequest) {
        XCTFail(@"Failure with status: %d", rRequest.responseStatusCode);
    }];
    XCTAssertTrue(request.responseString.length > 0);
}

- (void)testBasicRequestUnauthorized {
    NUXRequest *request = [[NUXRequest alloc] initWithSession:session];
    session.username = @"Dummy";
    [session startRequestSynchronous:request withCompletionBlock:^(NUXRequest *rRequest) {
        XCTFail(@"Failure with status: %d", rRequest.responseStatusCode);
    }                   failureBlock:^(NUXRequest *rRequest) {
        XCTAssertEqual(rRequest.responseStatusCode, 401);
    }];
}

- (void)testHelperMethods {
    NUXRequest *req = [session requestDocument:@"76c69a54-0230-457a-b42c-e819d5ace862"];
    XCTAssertEqualObjects(@"http://localhost:8080/nuxeo/api/v1/id/76c69a54-0230-457a-b42c-e819d5ace862", req.URL.absoluteString);
    XCTAssertEqualObjects(@"GET", req.method);

    req = [session requestChildren:@"/default-domain"];
    XCTAssertEqualObjects(@"http://localhost:8080/nuxeo/api/v1/path/default-domain/@children", req.URL.absoluteString);
    XCTAssertEqualObjects(@"GET", req.method);

    [req setCompletionBlock:^(NUXRequest *rRequest) {
        NSDictionary *json = [rRequest responseJSONWithError:Nil];
        XCTAssertEqualObjects(@"documents", [json valueForKey:@"entity-type"]);
    }];
    [req setFailureBlock:^(NUXRequest *r) {
        XCTFail(@"Request shouldn't fail!");
    }];
    [req startSynchronous];
    XCTAssertNotNil(req.responseData);
}

- (void)testQueryRequestMethod {
    NUXRequest *request = [session requestQuery:@"Select * from Document"];
    [session startRequestSynchronous:request withCompletionBlock:^(NUXRequest *rRequest) {
        XCTAssertEqual(200, rRequest.responseStatusCode);
        NSDictionary *response = [rRequest responseJSONWithError:nil];
        XCTAssertEqualObjects(@"documents", [response valueForKey:@"entity-type"]);
        XCTAssertTrue([[response valueForKey:@"entries"] count] > 3);
    }                   failureBlock:^(NUXRequest *r) {
        XCTFail(@"Request shouldn't fail!");
    }];
    XCTAssertTrue(request.responseData.length > 0);
}

- (void)testUpdateDocumentRequestMethod {
    [session addDefaultSchemas:@[@"dublincore"]];

    // Fetch workspaces document
    NUXRequest *request = [session requestDocument:@"/default-domain/workspaces"];
    NSDictionary *__block workspaces;
    [session startRequestSynchronous:request withCompletionBlock:^(NUXRequest *rRequest) {
        XCTAssertEqual(200, rRequest.responseStatusCode);
        workspaces = [rRequest responseJSONWithError:nil];
    }                   failureBlock:^(NUXRequest *r) {
        XCTFail(@"Request shouldn't fail!");
    }];

    // Update his title
    [[workspaces valueForKey:@"properties"] setValue:@"blablabla" forKey:@"dc:title"];
    request = [session requestUpdateDocument:workspaces];
    [session startRequestSynchronous:request withCompletionBlock:^(NUXRequest *rRequest) {
        XCTAssertEqual(200, rRequest.responseStatusCode);
    }                   failureBlock:^(NUXRequest *r) {
        XCTFail(@"Request shouldn't fail!");
    }];

    // Re-fetch workspaces to check new title
    NSString *docId = [workspaces valueForKey:@"uid"];
    request = [session requestDocument:docId];
    [session startRequestSynchronous:request withCompletionBlock:^(NUXRequest *rRequest) {
        XCTAssertEqual(200, rRequest.responseStatusCode);
        NSDictionary *json = [rRequest responseJSONWithError:nil];
        XCTAssertEqualObjects(@"blablabla", [json valueForKey:@"title"]);
    }                   failureBlock:^(NUXRequest *rRequest) {
        XCTFail(@"Request shouldn't fail!");
    }];
}

- (void)testCreateDocumentRequestMethod {
    [session addDefaultSchemas:@[@"dublincore"]];

    NSString *title = @"My WonderFul Doc";
    NSString *parentPath = @"/default-domain/workspaces";
    NSDictionary *__block newDoc = @{@"entity-type" : @"document",
            @"name" : @"myNewDoc",
            @"type" : @"File",
            @"properties" : @{@"dc:title" : title,
                    @"dc:description" : @"Description is cool"}};
    XCTAssertNil([newDoc valueForKey:@"uid"]);
    NUXRequest *request = [session requestCreateDocument:newDoc withParent:parentPath];
    [session startRequestSynchronous:request withCompletionBlock:^(NUXRequest *rRequest) {
        XCTAssertEqual(201, rRequest.responseStatusCode);
        newDoc = [rRequest responseJSONWithError:nil];
    }                   failureBlock:^(NUXRequest *rRequest) {
        XCTFail(@"Request shouldn't fail!");
    }];

    XCTAssertNotNil([newDoc valueForKey:@"uid"]);
    XCTAssertEqualObjects(title, [newDoc valueForKey:@"title"]);
    XCTAssertTrue([[newDoc valueForKey:@"path"] rangeOfString:parentPath].location != NSNotFound);
}

- (void)testSharedSession {
    NUXSession *session = [NUXSession sharedSession];
    XCTAssertEqualObjects(@"http://localhost:8080/test", session.url.absoluteString);
    XCTAssertEqualObjects(@"adminShared", session.username);
    XCTAssertEqualObjects(@"adminSharedPass", session.password);
    XCTAssertEqualObjects(@"test", session.repository);

    session.username = @"another";
    NUXSession *sessionNd = [NUXSession sharedSession];
    XCTAssertEqualObjects(@"another", sessionNd.username);
}

@end
