//
// Created by Arnaud Kervern on 26/11/13.
// Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NUXRequest.h"
#import "NUXDocument.h"
#import "NUXDocuments.h"

@interface NUXHierarchy : NSObject

// Initiate a hierarchy with a request. Request must returns a documents typed response.
-(id)initWithRequest:(NUXRequest *)request;

// Returns a lightweight NUXDocuments object with only entries property filled.
-(NUXDocuments *)childrenOfDocument:(NUXDocument *)document;

// Returns a lightweight NUXDocuments object form the root entry point.
-(NUXDocuments *)childrenOfRoot;

-(bool)isLoaded;
-(void)waitUntilLoadingIsDone;
-(void)setCompletionBlock:(NUXBasicBlock)completion;

@end