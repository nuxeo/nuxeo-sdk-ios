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
#import "NUXSession+requests.h"
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
    session = Nil;
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
    
    NUXRequest *__weak wReq = req;
    [req setCompletionBlock:^{
        NSDictionary *json = [wReq responseJSONWithError:Nil];
        XCTAssertEqualObjects(@"documents", [json valueForKey:@"entity-type"]);
    }];
    [req setFailureBlock:^{
        XCTFail(@"Request shouldn't fail!");
    }];
    [req startSynchronous];
    XCTAssertNotNil(req.responseData);
}

-(void)testQueryRequestMethod
{
    NUXRequest *request = [session requestQuery:@"Select * from Document"];
    [session startRequestSynchronous:request withCompletionBlock:^{
        XCTAssertEqual(200, request.responseStatusCode);
        NSDictionary *response = [request responseJSONWithError:nil];
        XCTAssertEqualObjects(@"documents", [response valueForKey:@"entity-type"]);
        XCTAssertTrue([[response valueForKey:@"entries"] count] > 3);
    } failureBlock:^{
        XCTFail(@"Request shouldn't fail!");
    }];
    XCTAssertTrue(request.responseData.length > 0);
}

-(void)testUpdateDocumentRequestMethod
{
    [session addDefaultSchemas:@[@"dublincore"]];
    
    // Fetch workspaces document
    NUXRequest *request = [session requestDocument:@"/default-domain/workspaces"];
    NSDictionary *__block workspaces;
    [session startRequestSynchronous:request withCompletionBlock:^{
        XCTAssertEqual(200, request.responseStatusCode);
        workspaces = [request responseJSONWithError:nil];
    } failureBlock:^{
        XCTFail(@"Request shouldn't fail!");
    }];
    
    // Update his title
    [[workspaces valueForKey:@"properties"] setValue:@"blablabla" forKey:@"dc:title"];
    request = [session requestUpdateDocument:workspaces];
    [session startRequestSynchronous:request withCompletionBlock:^{
        XCTAssertEqual(200, request.responseStatusCode);
    } failureBlock:^{
        XCTFail(@"Request shouldn't fail!");
    }];
    
    // Re-fetch workspaces to check new title
    NSString *docId = [workspaces valueForKey:@"uid"];
    request = [session requestDocument:docId];
    [session startRequestSynchronous:request withCompletionBlock:^{
        XCTAssertEqual(200, request.responseStatusCode);
        NSDictionary *json = [request responseJSONWithError:nil];
        XCTAssertEqualObjects(@"blablabla", [json valueForKey:@"title"]);
    } failureBlock:^{
        XCTFail(@"Request shouldn't fail!");
    }];
}

@end
