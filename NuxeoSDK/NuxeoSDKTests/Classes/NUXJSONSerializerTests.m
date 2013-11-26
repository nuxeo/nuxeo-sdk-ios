//
//  NUXJSONSerializerTests.m
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 25/11/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NUXSession+requests.h"
#import "NUXJSONMapper.h"
#import "NUXJSONSerializer.h"
#import "NUXDocument.h"

@interface NUXJSONSerializerTests : XCTestCase

@end

@implementation NUXJSONSerializerTests

- (void)testDocumentJSONMapper {
    NSDictionary *document = @{@"entity-type" : @"document",
                               @"name" : @"myNewDoc",
                               @"type" : @"File",
                               @"state" : @"project",
                               @"title" : @"my Title",
                               @"isCheckedOut" : @(true),
                               @"lastModified" : @"2013-11-22T10:01:45.40Z",
                               @"properties" : @{@"dc:title" : @"my Title",
                                                 @"dc:description" : @"Description is cool"}};
    NSError *error;
    NUXDocument *entity = [NUXJSONSerializer entityWithData:[NSJSONSerialization dataWithJSONObject:document options:0 error:nil] error:&error];
    
    if (error) {
        NSLog(@"%@", error);
    }
    
    XCTAssertEqualObjects(entity.title, @"my Title");
    XCTAssertTrue(entity.isCheckedOut);
    XCTAssertNotNil(entity.lastModified);
    XCTAssertEqualObjects(@"project", entity.state);
    
    NSDateFormatter *df = [NSDateFormatter new];
    df.dateFormat = @"yyyy-MM-dd";
    XCTAssertEqualObjects(@"2013-11-22", [df stringFromDate:entity.lastModified]);
    NSLog(@"%@", entity.lastModified.description);
}

-(void)testEntityToData {
    NUXDocument *doc = [NUXDocument new];
    XCTAssertEqualObjects(@"document", doc.entityType);
    doc.uid = @"53-345-435-345";
    doc.title = @"Salut";
    doc.lastModified = [NSDate new];
    doc.properties = [NSMutableDictionary dictionaryWithDictionary:@{@"dc:description" : @"blabla"}];
    doc.isCheckedOut = true;
    
    NSError *error;
    NSData *data = [NUXJSONSerializer dataWithEntity:doc error:&error];
    NSDictionary *dJson = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSLog(@"%@", dJson);
    XCTAssertEqualObjects(@"Salut", [dJson objectForKey:@"title"]);
}

-(void)testUpdateDocument {
    NUXSession *session = [[NUXSession alloc] initWithServerURL:[NSURL URLWithString:@"http://localhost:8080/nuxeo"] username:@"Administrator" password:@"Administrator"];
    [session addDefaultSchemas:@[@"dublincore"]];
    
    NUXRequest *request = [session requestDocument:@"/default-domain"];
    
    NSData *__block response;
    [request setCompletionBlock:^(NUXRequest *request) {
        XCTAssertEqual(200, request.responseStatusCode);
        response = request.responseData;
    }];
    [request setFailureBlock:^(NUXRequest *request) {
        XCTFail(@"%d : %@", request.responseStatusCode, request.responseMessage);
    }];
    [request startSynchronous];
    
    NUXDocument *doc = [NUXJSONSerializer entityWithData:response error:nil];
    XCTAssertEqualObjects(@"/default-domain", doc.path);
    XCTAssertEqualObjects(@"Default domain", [doc.properties objectForKey:@"dc:title"]);
    XCTAssertEqualObjects(@"document", doc.entityType);
    NSDate *lastModified = doc.lastModified;
    
    NSString *description = [NSString stringWithFormat:@"Description Changed %@", @(random())];
    [doc.properties setObject:description forKey:@"dc:description"];
    
    request = [session requestUpdateDocument:doc];
    [request setCompletionBlock:^(NUXRequest *request) {
        XCTAssertEqual(200, request.responseStatusCode);
        response = request.responseData;
    }];
    [request startSynchronous];
    
    NUXDocument *docNd = [NUXJSONSerializer entityWithData:response error:nil];
    
    XCTAssertEqualObjects(description, [docNd.properties valueForKey:@"dc:description"]);
    XCTAssertTrue([lastModified compare:docNd.lastModified] == NSOrderedAscending);
}

@end
