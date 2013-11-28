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

// leafBlock is executed on each tree leaf. LeafBlock is executed synchronously in
// the hierarchy generation thread which is async.
// Leaf block could be used to fill leaf with a specific request, like calling a pageProvider
-(id)initWithRequest:(NUXRequest *)request leafBlock:(NUXHierarchyBlock)leafBlock;

// Returns a lightweight NUXDocuments object with only entries property filled.
-(NUXDocuments *)childrenOfDocument:(NUXDocument *)document;

// Returns a lightweight NUXDocuments object form the root entry point.
-(NUXDocuments *)childrenOfRoot;

-(bool)isLoaded;
-(void)waitUntilLoadingIsDone;
-(void)setCompletionBlock:(NUXBasicBlock)completion;

@end