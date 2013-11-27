//
// Created by Arnaud Kervern on 26/11/13.
// Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import "NUXHierarchy.h"

#define kRootKey @"0"

@implementation NUXHierarchy {
    bool _isLoaded;
    bool _isFailure;
    NSMutableDictionary *_documents;
    
    NUXBasicBlock _completion;
}

-(id)initWithRequest:(NUXRequest *)request
{
    self = [super init];
    if (self) {
        _isLoaded = NO;
        _isFailure = NO;
        _documents = [NSMutableDictionary new];
        [self setupWithRequest:request];
    }
    return self;
}

- (void)dealloc
{
    _documents = nil;
    _completion = nil;
}

-(NUXDocuments *)childrenOfDocument:(NUXDocument *)document
{
    NSArray *entries = [_documents valueForKey:document.uid];
    if (entries == nil) {
        return nil;
    }
    
    NUXDocuments *docs = [NUXDocuments new];
    docs.entries = entries;
    return docs;
}

-(NUXDocuments *)childrenOfRoot
{
    NSArray *entries = [_documents valueForKey:kRootKey];
    if (entries == nil) {
        [NSException raise:@"Hierarchy not initialized" format:@""];
    }
    
    NUXDocuments *docs = [NUXDocuments new];
    docs.entries = entries;
    return docs;
}

-(bool)isLoaded
{
    return _isLoaded;
}

-(void)waitUntilLoadingIsDone {
    while (!(_isLoaded || _isFailure) && [[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
}

-(void)setCompletionBlock:(NUXBasicBlock)completion {
    _completion = completion;
}

-(void)setupCompleted
{
    _isLoaded = YES;
    if (_completion != nil) {
        _completion();
    }
}

-(void)setupWithRequest:(NUXRequest *)request
{
    NSMutableArray *docs = [NSMutableArray new];
    
    // Block passed to request filled with all expected documents
    void (^appendDocs)(NUXRequest *) = ^(NUXRequest *request) {
        NUXDocuments *res = [request responseEntityWithError:nil];
        [docs addObjectsFromArray:res.entries];
        
        if (res.isNextPageAvailable) {
            // XXX Todo build next page query
            [NSException raise:@"Not yet implemented" format:@"This great feature is not yet implemented."];
        } else {
            [self startBuildingHierarchyWithDocuments:docs];
        }
    };
    
    void (^failureBlock)(NUXRequest *) = ^(NUXRequest *request) {
        _isFailure = YES;
    };
    
    [request setCompletionBlock:appendDocs];
    [request setFailureBlock:failureBlock];
    [request start];
}

-(void)startBuildingHierarchyWithDocuments:(NSArray *)documents
{
    documents = [documents sortedArrayUsingComparator:^NSComparisonResult(NUXDocument *doc1, NUXDocument *doc2) {
        return [doc1.path compare:doc2.path];
    }];
    
    NSMutableDictionary *hierarchicalDocs = [NSMutableDictionary new];
    [documents enumerateObjectsUsingBlock:^(NUXDocument *doc, NSUInteger idx, BOOL *stop) {
        NSString *parent = [doc.path stringByDeletingLastPathComponent];
        NSMutableArray *children = [hierarchicalDocs objectForKey:parent];
        if (children == nil) {
            children = [NSMutableArray new];
            [hierarchicalDocs setObject:children forKey:parent];
        }
        [children addObject:doc];
    }];
    
    [self buildHierarchy:documents];
    [self setupCompleted];
}

-(void)buildHierarchy:(NSArray *)pDocuments {
    if (pDocuments.count == 0) {
        [NSException raise:@"Empty array" format:@"Hierarchy initialized with an empty array."];
    }
    
    NSMutableArray *documents = [NSMutableArray arrayWithArray:pDocuments];
    NSMutableArray *__block parents = [NSMutableArray new];
    [documents enumerateObjectsUsingBlock:^(NUXDocument *doc, NSUInteger idx, BOOL *stop) {
        if (idx == 0) {
            [parents addObject:doc];
            NSMutableArray *child = [NSMutableArray arrayWithObject:doc];
            [_documents setObject:child forKey:kRootKey];
            return;
        }

        NUXDocument *parent;
        do {
            if (parent != nil) {
                [parents removeLastObject];
            }
            
            parent = [parents lastObject];
        } while (!(parent == nil || [doc.path hasPrefix:[NSString stringWithFormat:@"%@/", parent.path]]));
        
        NSMutableArray *child;
        if (parents.count == 0) {
            child = [_documents valueForKey:kRootKey];
            [child addObject:doc];
        } else {
            child = [_documents valueForKey:parent.uid];
            if (child == nil) {
                child = [NSMutableArray new];
            }
            
            [child addObject:doc];
            [_documents setValue:child forKey:parent.uid];
        }
        [parents addObject:doc];
    }];
}

@end