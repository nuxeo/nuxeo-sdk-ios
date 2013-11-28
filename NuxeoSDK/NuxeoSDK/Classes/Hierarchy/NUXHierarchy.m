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
    NUXHierarchyBlock _leafBlock;
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

-(id)initWithRequest:(NUXRequest *)request leafBlock:(NUXHierarchyBlock)leafBlock
{
    self = [self initWithRequest:request];
    if (self) {
        _leafBlock = leafBlock;
    }
    return self;
}

- (void)dealloc
{
    _documents = nil;
    _completion = nil;
    _leafBlock = nil;
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
    if (_isLoaded) {
        completion();
    }
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
            [request addParameterValue:[NSString stringWithFormat:@"%@", @(res.currentPageIndex + 1)] forKey:@"currentPageIndex"];
            [request start];
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
    
    NSLog(@"%@", documents);
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
            [NUXHierarchy addChild:doc toHierarchy:_documents key:kRootKey];
            return;
        }

        // Try to find if a passed parent exists.
        NUXDocument *parent;
        BOOL leafPassed = NO;
        NSLog(@"doc: %@", doc);
        do {
            if (parent != nil) {
                // If we have to test the previous parent; we are in a leaf node
                if (!leafPassed && _leafBlock) {
                    NSArray *leaf = _leafBlock(parent);
                    if ([leaf count] > 0) {
                        NSLog(@"  leaf: %@", parent);
                        [NUXHierarchy addChildren:leaf toHierarchy:_documents key:parent.uid];
                    }
                }
                leafPassed = YES;
                [parents removeLastObject];
            }
            
            parent = [parents lastObject];
            NSLog(@"  parent: %@", parent);
        } while (!(parent == nil || [doc.path hasPrefix:[NSString stringWithFormat:@"%@/", parent.path]]));

        NSString *hKey = parents.count == 0 ? kRootKey : parent.uid;
        [NUXHierarchy addChild:doc toHierarchy:_documents key:hKey];
        [parents addObject:doc];
    }];
    NSLog(@"%@", _documents);
}

+(void)addChild:(NUXDocument *)child toHierarchy:(NSDictionary *)hierarchy key:(NSString *)key {
    [NUXHierarchy addChildren:@[child] toHierarchy:hierarchy key:key];
}

+(void)addChildren:(NSArray *)children toHierarchy:(NSDictionary *)hierarchy key:(NSString *)key  {
    if (!([children count] > 0)) {
        return;
    }
    
    NSMutableArray *hChildren = [hierarchy objectForKey:key];
    if (!hChildren) {
        hChildren = [NSMutableArray new];
        [hierarchy setValue:hChildren forKey:key];
    }
    [hChildren addObjectsFromArray:children];
}

@end