//
//  NUXAbstractTest.m
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 27/11/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import "NUXAbstractTestCase.h"

@implementation NUXAbstractTestCase

- (void)setUp {
    [super setUp];
    
    NSURL *url = [[NSURL alloc] initWithString:@"http://localhost:8080/nuxeo"];
    session = [[NUXSession alloc] initWithServerURL:url username:@"Administrator" password:@"Administrator"];
    [session addDefaultSchemas:@[@"dublincore"]];
}

- (void)tearDown {
    [super tearDown];
    
    session = Nil;
}

@end
