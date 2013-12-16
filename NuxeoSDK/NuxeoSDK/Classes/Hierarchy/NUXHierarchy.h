//
// Created by Arnaud Kervern on 26/11/13.
// Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NUXRequest.h"
#import "NUXDocument.h"
#import "NUXDocuments.h"

@interface NUXHierarchy : NSObject

@property (strong) NUXHierarchyBlock nodeBlock;
@property (strong) NUXInvalidationBlock nodeInvalidationBlock;
@property (strong) NUXBasicBlock completionBlock;
@property (strong) NUXBasicBlock failureBlock;
@property (readonly) NUXRequest *request;
@property BOOL *disableAutomaticContentRefresh;

-(NUXDocument *)nodeWithRef:(NSString *)nodeRef;
// Returns an array of NUXEntity corresponding to the document children.
-(NSArray *)childrenOfDocument:(NSString *)documentRef;
// Returns an array of NUXEntity corresponding to content of the document node.
-(NSArray *)contentOfDocument:(NUXDocument *)document;
// Returns an array of NUXEntity corresponding to the whole hierarchy nodes content
-(NSArray *)contentOfAllDocuments;
// Returns a lightweight NUXDocuments object form the root entry point.
-(NSArray *)childrenOfRoot;
-(BOOL)hasContentUnderNode:(NSString *)nodeRef;

-(void)loadWithRequest:(NUXRequest *)request;
-(void)resetCache;
-(bool)isLoaded;
-(void)waitUntilLoadingIsDone;

+(NUXHierarchy *)hierarchyWithName:(NSString *)name;

@end