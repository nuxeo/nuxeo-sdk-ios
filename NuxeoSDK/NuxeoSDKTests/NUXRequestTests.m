//
//  NUXRequestTests.m
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 14/11/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NUXRequest.h"
#import "NUXSession.h"

@interface NUXRequestTests : XCTestCase

@end

@implementation NUXRequestTests

NUXSession *session;
NUXRequest *request;

- (void)setUp
{
    [super setUp];
    NSURL *url = [[NSURL alloc] initWithString:@"http://localhost:8080/nuxeo"];
    session = [[NUXSession alloc] initWithServerURL:url username:@"Administrator" password:@"Administrator"];
    request = [[NUXRequest alloc] initWithSession:session];
}

- (void)testRequestURLBuilder
{
    XCTAssertEqualObjects(@"http://localhost:8080/nuxeo/api/v1", request.URL.absoluteString);
    
    [[request addURLSegment:@"path/"] addURLSegment:@"default-domain"];
    XCTAssertEqualObjects(@"http://localhost:8080/nuxeo/api/v1/path/default-domain", request.URL.absoluteString);
    
    [request addAdaptor:@"child"];
    XCTAssertEqualObjects(@"http://localhost:8080/nuxeo/api/v1/path/default-domain/@child", request.URL.absoluteString);
    
    [request addAdaptor:@"blob" withValue:@"file:content"];
    XCTAssertEqualObjects(@"http://localhost:8080/nuxeo/api/v1/path/default-domain/@child/@blob/file:content", request.URL.absoluteString);
}

-(void)testRequestPropertiesRegistration
{
    [request addCategory:@"security"];
    [request addCategories:@[@"breadcrum", @"head"]];
    
    XCTAssertTrue([[request categories] containsObject:@"head"]);
    XCTAssertTrue(3 == [request categories].count);
    
    [request addSchema:@"dublincore"];
    [request addSchemas:@[@"file", @"uid"]];
    
    XCTAssertTrue([[request schemas] containsObject:@"uid"]);
    XCTAssertTrue(3 == [request schemas].count);
    
    [request addHeaderWithKey:@"X-MyHeader" value:@"myValue"];
    XCTAssertTrue(1 == [[request headers] count]);
    XCTAssertEqualObjects(@"myValue", [request.headers valueForKey:@"X-MyHeader"]);
}

-(void)testResponseData
{
    [[request addURLSegment:@"path"] addURLSegment:@"default-domain"];
    XCTAssertNil(request.responseData);
    [session startRequestSynchronous:request withCompletionBlock:^{
        XCTAssertNotNil(request.responseData);
        NSDictionary *json = [request responseJSONWithError:nil];
        XCTAssertEqualObjects(@"document", [json valueForKey:@"entity-type"]);
    } failureBlock:^{
        XCTFail(@"Request should not fail: %@", request.responseMessage);
    }];
}

-(void)testResponseForChild
{
    [[request addURLSegment:@"path/default-domain"] addAdaptor:@"children"];
    XCTAssertNil(request.responseData);
    [session startRequestSynchronous:request withCompletionBlock:^{
        NSDictionary *json = [request responseJSONWithError:nil];
        XCTAssertEqualObjects(@"documents", [json valueForKey:@"entity-type"]);
    } failureBlock:^{
        XCTFail(@"Request should not fail: %@", request.responseMessage);
    }];
}

-(void)testMultipleRequest
{
    NUXRequest *req = [[NUXRequest alloc] initWithSession:session];
    [req addURLSegment:@"path/default-domain"];
    [req addSchema:@"dublincore"];
    [request addURLSegment:@"path/default-domain/workspaces"];
    [request addSchema:@"file"];
    
    [session startRequestSynchronous:request withCompletionBlock:^{
        NSDictionary *json = [request responseJSONWithError:nil];
        XCTAssertEqualObjects(@"/default-domain/workspaces", [json valueForKey:@"path"]);
    } failureBlock:^{
        XCTFail(@"Request should not fail: %@", request.responseMessage);
    }];
    
    [session startRequestSynchronous:req withCompletionBlock:^{
        NSDictionary *json = [req responseJSONWithError:nil];
        XCTAssertEqualObjects(@"/default-domain", [json valueForKey:@"path"]);
    } failureBlock:^{
        XCTFail(@"Request should not fail: %@", req.responseMessage);
    }];
}

-(void)testSchemaHeader
{
    [[[request addURLSegment:@"path"] addURLSegment:@"default-domain"] addSchema:@"dublincore"];
    [session startRequestSynchronous:request withCompletionBlock:^{
        NSDictionary *properties = [[request responseJSONWithError:nil] objectForKey:@"properties"];
        XCTAssertNotNil([properties valueForKey:@"dc:title"]);
        XCTAssertNil([properties valueForKey:@"ms:metadata"]);
    } failureBlock:^{
        XCTFail(@"Request should not fail: %@", request.responseMessage);
    }];
}

@end
