//
//  NUXJSONSerializerTests.m
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 25/11/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import <XCTest/XCTest.h>
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
                               @"isCheckedOut" : @true,
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

@end
