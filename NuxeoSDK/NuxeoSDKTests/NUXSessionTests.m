//
//  NuxeoSDKTests.m
//  NuxeoSDKTests
//
//  Created by Arnaud Kervern on 08/11/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <ASIHTTPRequest.h>
#import "NUXSession.h"
#import "NUXRequest.h"

@interface NUXSessionTests : XCTestCase

@end

@implementation NUXSessionTests

NUXSession *session;

- (void)setUp
{
    [super setUp];
    NSURL *url = [[NSURL alloc] initWithString:@"http://localhost:8080/nuxeo"];
    session = [[NUXSession alloc] initWithServerURL:url username:@"Administrator" password:@"Administrator"];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testSessionInit
{
    NUXSession *session = [NUXSession new];
    XCTAssertEqualObjects(@"default", session.repository);
    
    NSURL *url = [[NSURL alloc] initWithString:@"http://localhost:8080/nuxeo"];
    session = [[NUXSession alloc] initWithServerURL:url username:@"Administrator" password:@"Administrator"];
    XCTAssertEqualObjects(@"default", session.repository);
    XCTAssertEqualObjects(@"Administrator", session.username);
    XCTAssertEqualObjects(@"Administrator", session.password);
    XCTAssertEqualObjects(@"http://localhost:8080/nuxeo/api/v1", session.url.absoluteString);
}

- (void)testBasicRequestExecution
{
    NUXRequest *request = [[NUXRequest alloc] initWithSession:session];
    [request addURLSegment:@"doc"];
    
    XCTAssertFalse(request.responseString.length > 0);
    [session startRequestSynchronous:request withCompletionBlock:^{
        XCTAssertEqual(request.responseStatusCode, 200);
    } failureBlock:^{
        XCTFail(@"Failure with status: %d", request.responseStatusCode);
    }];
    XCTAssertTrue(request.responseString.length > 0);
}

-(void)testBasicRequestUnauthorized
{
    NUXRequest *request = [[NUXRequest alloc] initWithSession:session];
    session.username = @"Dummy";
    [session startRequestSynchronous:request withCompletionBlock:^{
        XCTFail(@"Failure with status: %d", request.responseStatusCode);
    } failureBlock:^{
        XCTAssertEqual(request.responseStatusCode, 401);
    }];
}

-(void)testHelperMethods
{
    NUXRequest *req = [session requestDocument:@"76c69a54-0230-457a-b42c-e819d5ace862"];
    XCTAssertEqualObjects(@"http://localhost:8080/nuxeo/api/v1/id/76c69a54-0230-457a-b42c-e819d5ace862", req.URL.absoluteString);
    XCTAssertEqualObjects(@"GET", req.method);
    
    req = [session requestChildren:@"/default-domain"];
    XCTAssertEqualObjects(@"http://localhost:8080/nuxeo/api/v1/path/default-domain/@children", req.URL.absoluteString);
    XCTAssertEqualObjects(@"GET", req.method);
    
    [req setCompletionBlock:^{
        NSDictionary *json = [req responseJSONWithError:Nil];
        XCTAssertEqualObjects(@"documents", [json valueForKey:@"entity-type"]);
    }];
    [req setFailureBlock:^{
        XCTFail(@"Request shouldn't fail!");
    }];
    [req startSynchronous];
    XCTAssertNotNil(req.responseData);
}

@end
