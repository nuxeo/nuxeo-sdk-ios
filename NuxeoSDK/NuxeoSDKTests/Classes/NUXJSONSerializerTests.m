//
//  NUXJSONSerializerTests.m
//  NuxeoSDK
//  Created by Arnaud Kervern on 2013-11-25.
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

#import "NUXJSONMapper.h"
#import "NUXJSONSerializer.h"

@interface NUXJSONSerializerTests : NUXAbstractTestCase

@end

@implementation NUXJSONSerializerTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

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
    XCTAssertEqualObjects(@"Domain", [doc.properties objectForKey:@"dc:title"]);
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

-(void)testDocumentListEntity {
    NUXRequest *request = [session requestQuery:@"select * from document"];
    NUXDocuments * docs;
    [request setCompletionBlock:^(NUXRequest *request) {
        XCTAssertEqual(200, request.responseStatusCode);

    }];
    [request startSynchronous];

    NSLog(@"%@", [request responseJSONWithError:nil]);
    docs = [request responseEntityWithError:nil];
    XCTAssertTrue(docs.entries.count > 4);
    
    NUXDocument *doc = [docs.entries objectAtIndex:0];
    XCTAssertTrue([doc isKindOfClass:[NUXEntity class]]);
    XCTAssertNotNil(doc.uid);
    XCTAssertNotNil(doc.path);
}

-(void)testDocumentEntityCreation {
    NUXDocument *__block doc = [NUXDocument new];
    NSString *name = [NSString stringWithFormat:@"%@", @(arc4random())];
    doc.name = name;
    doc.type = @"Folder";
    doc.properties = [NSMutableDictionary dictionaryWithDictionary:@{@"dc:title" : @"My note",
                                                                     @"dc:description" : @"something"}];
    
    NUXRequest *request = [session requestCreateDocument:doc withParent:@"/default-domain"];
    [request setCompletionBlock:^(NUXRequest *request) {
        XCTAssertEqual(201, request.responseStatusCode);
        doc = [request responseEntityWithError:nil];
    }];
    XCTAssertNil(doc.uid);
    [request startSynchronous];
    
    NSString *path = [NSString stringWithFormat:@"/default-domain/%@", name];
    XCTAssertEqualObjects(path, doc.path);
    XCTAssertNotNil(doc.uid);
}

@end
