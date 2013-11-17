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

@end
