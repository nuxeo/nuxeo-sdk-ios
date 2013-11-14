//
//  NuxeoSDKTests.m
//  NuxeoSDKTests
//
//  Created by Arnaud Kervern on 08/11/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NUXSession.h"

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
    XCTAssertEqual(@"default", session.repository);
    
    NSURL *url = [[NSURL alloc] initWithString:@"http://localhost:8080/nuxeo"];
    session = [[NUXSession alloc] initWithServerURL:url username:@"Administrator" password:@"Administrator"];
    XCTAssertEqual(@"default", session.repository);
    XCTAssertEqual(@"Administrator", session.username);
    XCTAssertEqual(@"Administrator", session.password);
    XCTAssertEqual(@"http://localhost:8080/nuxeo", session.url.absoluteString);
}

- (void)testBasicRequestExecution
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8080/nuxeo/api/v1/path/default-domain"]];
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
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8080/nuxeo/api/v1/path/default-domain"]];
    session.username = @"Dummy";
    [session startRequestSynchronous:request withCompletionBlock:^{
        XCTFail(@"Failure with status: %d", request.responseStatusCode);
    } failureBlock:^{
        XCTAssertEqual(request.responseStatusCode, 401);
    }];
}

@end
