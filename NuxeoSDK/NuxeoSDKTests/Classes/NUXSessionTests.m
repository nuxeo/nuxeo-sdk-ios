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
    [session startRequestSynchronous:request withCompletionBlock:^{
        XCTAssertEqual(request.responseStatusCode, 200);
    }                   failureBlock:^{
        XCTFail(@"Failure with status: %d", request.responseStatusCode);
    }];
    XCTAssertTrue(request.responseString.length > 0);
}

- (void)testBasicRequestUnauthorized {
    NUXRequest *request = [[NUXRequest alloc] initWithSession:session];
    session.username = @"Dummy";
    [session startRequestSynchronous:request withCompletionBlock:^{
        XCTFail(@"Failure with status: %d", request.responseStatusCode);
    }                   failureBlock:^{
        XCTAssertEqual(request.responseStatusCode, 401);
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
    XCTAssertEqualObjects(@"application/json+nxrequest", request.contentType);
    [session startRequestSynchronous:request withCompletionBlock:^{
        XCTAssertEqual(200, request.responseStatusCode);
        NSDictionary *response = [request responseJSONWithError:nil];
        XCTAssertEqualObjects(@"documents", [response valueForKey:@"entity-type"]);
        XCTAssertTrue([[response valueForKey:@"entries"] count] > 3);
    }                   failureBlock:^{
        XCTFail(@"Request shouldn't fail!");
    }];
    XCTAssertTrue(request.responseData.length > 0);
}

- (void)testUpdateDocumentRequestMethod {
    [session addDefaultSchemas:@[@"dublincore"]];

    // Fetch workspaces document
    NUXRequest *request = [session requestDocument:@"/default-domain/workspaces"];
    NSDictionary *__block workspaces;
    [session startRequestSynchronous:request withCompletionBlock:^{
        XCTAssertEqual(200, request.responseStatusCode);
        workspaces = [request responseJSONWithError:nil];
    }                   failureBlock:^{
        XCTFail(@"Request shouldn't fail!");
    }];

    // Update his title
    [[workspaces valueForKey:@"properties"] setValue:@"blablabla" forKey:@"dc:title"];
    request = [session requestUpdateDocument:workspaces];
    [session startRequestSynchronous:request withCompletionBlock:^{
        XCTAssertEqual(200, request.responseStatusCode);
    }                   failureBlock:^{
        XCTFail(@"Request shouldn't fail!");
    }];

    // Re-fetch workspaces to check new title
    NSString *docId = [workspaces valueForKey:@"uid"];
    request = [session requestDocument:docId];
    [session startRequestSynchronous:request withCompletionBlock:^{
        XCTAssertEqual(200, request.responseStatusCode);
        NSDictionary *json = [request responseJSONWithError:nil];
        XCTAssertEqualObjects(@"blablabla", [json valueForKey:@"title"]);
    }                   failureBlock:^{
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
    [session startRequestSynchronous:request withCompletionBlock:^{
        XCTAssertEqual(201, request.responseStatusCode);
        newDoc = [request responseJSONWithError:nil];
    }                   failureBlock:^{
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

-(void)testDeleteDocumentRequest {
    NSDictionary *__block newDoc = @{@"entity-type" : @"document",
            @"name" : @"myNewDoc",
            @"type" : @"File",
            @"properties" : @{@"dc:title" : @"title",
                    @"dc:description" : @"Description is cool"}};
    NUXRequest *request = [session requestCreateDocument:newDoc withParent:@"/default-domain"];
    [request setCompletionBlock:^(NUXRequest *request) {
        newDoc = [request responseJSONWithError:nil];
    }];
    [request startSynchronous];

    NSString *docId = [newDoc valueForKey:@"uid"];
    XCTAssertNotNil(docId);

    request = [session requestDocument:docId];
    [request setCompletionBlock:^(NUXRequest *request) {
        XCTAssertEqual(200, request.responseStatusCode);
    }];
    [request startSynchronous];

    request = [session requestDeleteDocument:docId];
    [request setCompletionBlock:^(NUXRequest *request) {
        XCTAssertEqual(204, request.responseStatusCode);
    }];
    [request startSynchronous];

    request = [session requestDocument:docId];
    [request setCompletionBlock:^(NUXRequest *request) {
        XCTAssertEqual(404, request.responseStatusCode);
    }];
    [request startSynchronous];
}

-(void)testUploadBlobWithAutomation {
    NSString *file = [[NSBundle bundleForClass:[NUXSession class]] pathForResource:@"NUXSession-info" ofType:@"plist"];
    NUXRequest *request = [session requestImportFile:file withParent:@"/management"];
    [request addSchema:@"file"];
    
    [request setCompletionBlock:^(NUXRequest *request) {
        XCTAssertEqual(200, request.responseStatusCode);
        NSDictionary *doc = [request responseJSONWithError:nil];
        XCTAssertNotNil([doc valueForKey:@"uid"]);
        NSDictionary *fileContent = [[doc valueForKey:@"properties"] valueForKey:@"file:content"];
        XCTAssertNotNil(fileContent);
        XCTAssertEqualObjects(@"NUXSession-info.plist", [fileContent valueForKey:@"name"]);
    }];

    [request setFailureBlock:^(NUXRequest *request) {
        XCTFail(@"upload fail.");
    }];

    [request startSynchronous];
}

-(void)testDownloadBlob {
    NSString *__block uid;
    
    // upload file first
    NSString *file = [[NSBundle bundleForClass:[NUXSession class]] pathForResource:@"NUXSession-info" ofType:@"plist"];
    NSDictionary *plistAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:file error:nil];
    NUXRequest *request = [session requestImportFile:file withParent:@"/management"];
    
    [request setCompletionBlock:^(NUXRequest *request) {
        XCTAssertEqual(200, request.responseStatusCode);
        NSDictionary *json = [request responseJSONWithError:nil];
        uid = [json valueForKey:@"uid"];
    }];
    [request startSynchronous];
    
    request = [session requestDownloadBlobFrom:uid inMetadata:@"file:content"];
    [request setCompletionBlock:^(NUXRequest *request) {
        XCTAssertEqual(200, request.responseStatusCode);
        XCTAssertEqual([[plistAttributes valueForKey:NSFileSize] unsignedLongValue], request.responseData.length);
    }];
    
    [request startSynchronous];
}

-(void)testDownloadToFile {
    NSString *__block uid;
    
    // upload file first
    NSString *file = [[NSBundle bundleForClass:[NUXSession class]] pathForResource:@"NUXSession-info" ofType:@"plist"];
    NSDictionary *plistAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:file error:nil];
    NUXRequest *request = [session requestImportFile:file withParent:@"/management"];

    [request setCompletionBlock:^(NUXRequest *request) {
        XCTAssertEqual(200, request.responseStatusCode);
        NSDictionary *json = [request responseJSONWithError:nil];
        uid = [json valueForKey:@"uid"];
    }];
    [request startSynchronous];
    
    NSString *tempFile = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"tempfile%d.tmp", rand()]];
    request = [session requestDownloadBlobFrom:uid inMetadata:@"file:content"];
    request.downloadDestinationPath = tempFile;
    [request setCompletionBlock:^(NUXRequest *request) {
        XCTAssertEqual(200, request.responseStatusCode);
    }];
    
    [request startSynchronous];
    
    XCTAssertTrue([[NSFileManager defaultManager] isReadableFileAtPath:tempFile]);
    NSDictionary *dlAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:tempFile error:nil];
    XCTAssertEqual([plistAttributes valueForKey:NSFileSize], [dlAttributes valueForKey:NSFileSize]);
}

@end
