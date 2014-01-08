//
//  NUXRequestTests.m
//  NuxeoSDK
//  Created by Arnaud Kervern on 2013-11-14.
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
#import "ASIFormDataRequest.h"

@interface NUXRequestTests : NUXAbstractTestCase

@end

@implementation NUXRequestTests {
    NUXRequest *request;
}

- (void)setUp {
    [super setUp];
    
    request = [[NUXRequest alloc] initWithSession:session];
}

- (void)testRequestURLBuilder {
    XCTAssertEqualObjects(@"http://localhost:8080/nuxeo/api/v1", request.URL.absoluteString);

    [[request addURLSegment:@"path/"] addURLSegment:@"default-domain"];
    XCTAssertEqualObjects(@"http://localhost:8080/nuxeo/api/v1/path/default-domain", request.URL.absoluteString);

    [request addAdaptor:@"child"];
    XCTAssertEqualObjects(@"http://localhost:8080/nuxeo/api/v1/path/default-domain/@child", request.URL.absoluteString);

    [request addAdaptor:@"blob" withValue:@"file:content"];
    XCTAssertEqualObjects(@"http://localhost:8080/nuxeo/api/v1/path/default-domain/@child/@blob/file:content", request.URL.absoluteString);
}

- (void)testRequestPropertiesRegistration {
    [request addCategory:@"security"];
    [request addCategories:@[@"breadcrum", @"head"]];

    XCTAssertTrue([[request categories] containsObject:@"head"]);
    XCTAssertTrue(3 == [request categories].count);

    [request addSchema:@"dublincore"];
    [request addSchemas:@[@"file", @"uid"]];

    XCTAssertTrue([[request schemas] containsObject:@"uid"]);
    XCTAssertTrue(3 == [request schemas].count);

    [request addHeaderValue:@"myValue" forKey:@"X-MyHeader"];
    XCTAssertTrue(1 == [[request headers] count]);
    XCTAssertEqualObjects(@"myValue", [request.headers valueForKey:@"X-MyHeader"]);
}

- (void)testResponseData {
    [[request addURLSegment:@"path"] addURLSegment:@"default-domain"];
    XCTAssertNil(request.responseData);
    [session startRequestSynchronous:request withCompletionBlock:^{
        XCTAssertNotNil(request.responseData);
        NSDictionary *json = [request responseJSONWithError:nil];
        XCTAssertEqualObjects(@"document", [json valueForKey:@"entity-type"]);
    }                   failureBlock:^{
        XCTFail(@"Request should not fail: %@", request.responseMessage);
    }];
}

- (void)testResponseForChild {
    [[request addURLSegment:@"path/default-domain"] addAdaptor:@"children"];
    XCTAssertNil(request.responseData);
    [session startRequestSynchronous:request withCompletionBlock:^{
        NSDictionary *json = [request responseJSONWithError:nil];
        XCTAssertEqualObjects(@"documents", [json valueForKey:@"entity-type"]);
    }                   failureBlock:^{
        XCTFail(@"Request should not fail: %@", request.responseMessage);
    }];
}

- (void)testMultipleRequest {
    NUXRequest *req = [[NUXRequest alloc] initWithSession:session];
    [req addURLSegment:@"path/default-domain"];
    [req addSchema:@"dublincore"];
    [request addURLSegment:@"path/default-domain/workspaces"];
    [request addSchema:@"file"];

    [session startRequestSynchronous:request withCompletionBlock:^{
        NSDictionary *json = [request responseJSONWithError:nil];
        XCTAssertEqualObjects(@"/default-domain/workspaces", [json valueForKey:@"path"]);
    }                   failureBlock:^{
        XCTFail(@"Request should not fail: %@", request.responseMessage);
    }];

    [session startRequestSynchronous:req withCompletionBlock:^{
        NSDictionary *json = [req responseJSONWithError:nil];
        XCTAssertEqualObjects(@"/default-domain", [json valueForKey:@"path"]);
    }                   failureBlock:^{
        XCTFail(@"Request should not fail: %@", request.responseMessage);
    }];
}

- (void)testSchemaHeader {
    [[[request addURLSegment:@"path"] addURLSegment:@"default-domain"] addSchema:@"dublincore"];
    [session startRequestSynchronous:request withCompletionBlock:^{
        NSDictionary *properties = [[request responseJSONWithError:nil] objectForKey:@"properties"];
        XCTAssertNotNil([properties valueForKey:@"dc:title"]);
        XCTAssertNil([properties valueForKey:@"ms:metadata"]);
    }                   failureBlock:^{
        XCTFail(@"Request should not fail: %@", request.responseMessage);
    }];
}

- (void)testUploadNuxeoWithASI {
    NSURL *url = [NSURL URLWithString:@"http://localhost:8080/nuxeo/api/v1/path/default-domain/@op/FileManager.Import"];
    ASIFormDataRequest *iRequest = [[ASIFormDataRequest alloc] initWithURL:url];
    [iRequest setRequestMethod:@"post"];
    [iRequest addRequestHeader:@"Content-type" value:@"application/json+nxrequest"];

    NSString *file = [[NSBundle bundleForClass:[NUXSession class]] pathForResource:@"NUXSession-info" ofType:@"plist"];
    id json = [NSJSONSerialization dataWithJSONObject:@{@"context" : @{@"currentDocument" : @"/management"}} options:0 error:nil];

    [iRequest addData:json forKey:@"params"];
    [iRequest addFile:file forKey:@"input"];

    ASIFormDataRequest *__weak wReq = iRequest;
    [iRequest setCompletionBlock:^{
        XCTAssertEqual(200, wReq.responseStatusCode);
    }];
    [iRequest setFailedBlock:^{
        XCTFail(@"Fail.");
    }];
    [iRequest startSynchronous];
}

@end
