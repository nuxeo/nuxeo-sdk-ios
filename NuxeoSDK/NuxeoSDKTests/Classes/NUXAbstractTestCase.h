//
//  NUXAbstractTest.m
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 27/11/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import <XCTest/XCTest.h>
#include <stdlib.h>

#import "NUXSession+requests.h"
#import "NUXDocument.h"
#import "NUXDocuments.h"

@interface NUXAbstractTestCase : XCTestCase {
    NUXSession *session;
}

-(NUXDocument *)dummyDocument;

@end