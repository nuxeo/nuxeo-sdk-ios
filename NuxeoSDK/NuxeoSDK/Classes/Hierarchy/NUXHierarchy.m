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
    NSMutableDictionary *_contents;
}

+(NUXHierarchy *)hierarchyWithName:(NSString *)name {
    static dispatch_once_t pred = 0;
    static NSMutableDictionary *__strong _hierarchies = nil;
    
    dispatch_once(&pred, ^{
        _hierarchies = [NSMutableDictionary new];
    });
    
    if (![_hierarchies objectForKey:name]) {
        [_hierarchies setObject:[NUXHierarchy new] forKey:name];
    }
    
    return [_hierarchies objectForKey:name];
}

-(id)init {
    self = [super init];
    if (self) {
        _isLoaded = NO;
        _isFailure = NO;
        _documents = [NSMutableDictionary new];
        _contents = [NSMutableDictionary new];
    }
    return self;
}

- (void)dealloc
{
    _documents = nil;
    _contents = nil;
    _completionBlock= nil;
    _nodeInvalidationBlock = nil;
    _nodeBlock = nil;
}

-(void)load {
    [self setup];
}

-(NSArray *)childrenOfDocument:(NUXDocument *)document
{
    NSArray *entries = [_documents valueForKey:document.uid];
    if (entries == nil) {
        return nil;
    }
    return [NSArray arrayWithArray:entries];
}

-(NSArray *)contentOfDocument:(NUXDocument *)document {
    NSArray *entries = [_contents valueForKey:document.uid];
    if (entries == nil) {
        return nil;
    }
    return [NSArray arrayWithArray:entries];
}

-(NSArray *)contentOfAllDocuments {
    NSMutableArray *content = [NSMutableArray new];
    [_contents enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [content addObject:obj];
    }];
    return content;
}

-(NSArray *)childrenOfRoot
{
    NSArray *entries = [_documents valueForKey:kRootKey];
    if (entries == nil) {
        [NSException raise:@"Not initialized" format:@"Hierarchy not initialized"];
    }
    return [NSArray arrayWithArray:entries];
}

-(bool)isLoaded
{
    return _isLoaded;
}

-(void)waitUntilLoadingIsDone {
    while (!(_isLoaded || _isFailure) && [[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
}


-(void)setupCompleted
{
    _isLoaded = YES;
    if (self.completionBlock != nil) {
        self.completionBlock();
    }
}

-(void)setup
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
    
    [self.request setCompletionBlock:appendDocs];
    [self.request setFailureBlock:failureBlock];
    [self.request start];
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
        // Try to find if a passed parent exists.
        NUXDocument *parent;
        NUXDebug(@"doc: %@", doc);
        do {
            if (parent != nil) {
                // If we have to test the previous parent; we are in a leaf node
                [parents removeLastObject];
            }
            
            parent = [parents lastObject];
            NUXDebug(@"  parent: %@", parent);
        } while (!(parent == nil || [doc.path hasPrefix:[NSString stringWithFormat:@"%@/", parent.path]]));

        NSString *hKey = [parents count] == 0 ? kRootKey : parent.uid;
        [NUXHierarchy addNodeDocument:doc toHierarchy:_documents key:hKey];
        
        if (_nodeBlock) {
            NSArray *leaf = _nodeBlock(doc, parents.count);
            if ([leaf count] > 0) {
                [NUXHierarchy addNodeDocuments:leaf toHierarchy:_contents key:doc.uid];
            }
        }
        
        [parents addObject:doc];
    }];
    NUXDebug(@"%@", _documents);
    NUXDebug(@"%@", _contents);
}

+(void)addNodeDocument:(NUXDocument *)child toHierarchy:(NSDictionary *)hierarchy key:(NSString *)key {
    [NUXHierarchy addNodeDocuments:@[child] toHierarchy:hierarchy key:key];
}

+(void)addNodeDocuments:(NSArray *)children toHierarchy:(NSDictionary *)hierarchy key:(NSString *)key  {
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