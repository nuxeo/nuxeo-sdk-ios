//
// Created by Arnaud Kervern on 26/11/13.
// Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import "NUXHierarchy.h"
#import "NUXHierarchyDB.h"

@interface NUXHierarchy (private)

-(void)setName:(NSString *)name;

@end

@implementation NUXHierarchy {
    bool _isLoaded;
    bool _isFailure;
    bool _isLoading;
    NSString *_name;
    
    NSMutableDictionary *_nodeHasDepperContent;
}

+(NUXHierarchy *)hierarchyWithName:(NSString *)name {
    static dispatch_once_t pred = 0;
    static NSMutableDictionary *__strong _hierarchies = nil;
    
    dispatch_once(&pred, ^{
        _hierarchies = [NSMutableDictionary new];
    });
    
    if (![_hierarchies objectForKey:name]) {
        NUXHierarchy *hierarchy = [NUXHierarchy new];
        [hierarchy setName:name];
        [hierarchy invalidateIfNotComplete];
        
        [_hierarchies setObject:hierarchy forKey:name];
    }
    
    return [_hierarchies objectForKey:name];
}

-(id)init {
    self = [super init];
    if (self) {
        _isLoaded = NO;
        _isFailure = NO;
        _isLoading = NO;
        _nodeHasDepperContent = [NSMutableDictionary new];
    }
    return self;
}

- (void)dealloc
{
    _completionBlock= nil;
    _nodeInvalidationBlock = nil;
    _nodeBlock = nil;
    _nodeHasDepperContent = nil;
}

-(void)invalidateIfNotComplete {
    if (![[NUXHierarchyDB shared] isHierarchyLoaded:_name]) {
        [[NUXHierarchyDB shared] deleteNodesFromHierarchy:_name];
    }
}

-(void)setName:(NSString *)name {
    _name = name;
}

-(void)loadWithRequest:(NUXRequest *)request {
    _request = request;
    if ([[self childrenOfRoot] count] <= 0) {
        [self setup];
    } else {
        [self setupCompleted];
    }
}

-(void)resetCache {
    [[NUXHierarchyDB shared] deleteNodesFromHierarchy:_name];
    _nodeHasDepperContent = [NSMutableDictionary new];
}

-(NSArray *)childrenOfDocument:(NSString *)documentRef
{
    NSArray *entries = [[NUXHierarchyDB shared] selectNodesFromParent:documentRef hierarchy:_name];
    if (entries == nil) {
        return nil;
    }
    return [NSArray arrayWithArray:entries];
}

-(NSArray *)contentOfDocument:(NUXDocument *)document {
    if ((_nodeInvalidationBlock && _nodeInvalidationBlock(document)) || [NUXSession isNetworkReachable]) {
        NSInteger depth = [[NUXHierarchyDB shared] selectDepthForDocument:document.uid hierarchy:_name];
        return [self updateLeafContentForDocument:document andDepth:depth];
    }
    return [[NUXHierarchyDB shared] selectContentFromNode:document.uid hierarchy:_name];
}

-(NSArray *)contentOfAllDocuments {
    return [[NUXHierarchyDB shared] selectAllContentFromHierarchy:_name];
}

-(NSArray *)childrenOfRoot
{
    NSArray *entries = [[NUXHierarchyDB shared] selectNodesFromParent:kRootKey hierarchy:_name];
    return entries == nil ? nil : [NSArray arrayWithArray:entries];
}

-(NUXDocument *)nodeWithRef:(NSString *)nodeRef {
    return [[NUXHierarchyDB shared] selectNode:nodeRef hierarchy:_name];
}

-(BOOL)hasContentUnderNode:(NSString *)nodeRef {
    // Fetch whole document to ensure to have his ids.
    NUXDocument *root = [[NUXHierarchyDB shared] selectNode:nodeRef hierarchy:_name];
    if (!root) {
        return NO;
    }
    
    NSMutableArray *childs = [NSMutableArray new];
    [childs addObject:root.uid];
    [childs addObjectsFromArray:[[NUXHierarchyDB shared] selectIdsFromParent:nodeRef hierarchy:_name]];
    
    return [self hasContentForDocIds:childs];
}

-(bool)hasContentForDocIds:(NSArray *)docIds {
    BOOL __block hasContent = NO;
    [docIds enumerateObjectsUsingBlock:^(NSString *docRef, NSUInteger idx, BOOL *stop) {
        if ([_nodeHasDepperContent valueForKey:docRef] != nil) {
            *stop = YES;
            hasContent = [[_nodeHasDepperContent valueForKey:docRef] boolValue];
        }
        
        BOOL iHasContent = [[NUXHierarchyDB shared] hasContentForNode:docRef hierarchy:_name];
        if (!iHasContent) {
            NSArray *iChilds = [[NUXHierarchyDB shared] selectIdsFromParent:docRef hierarchy:_name];
            iHasContent = [self hasContentForDocIds:iChilds];
        }
        
        if (iHasContent) {
            hasContent = YES;
            *stop = YES;
            [_nodeHasDepperContent setValue:@(YES) forKey:docRef];
        } else {
            [_nodeHasDepperContent setValue:@(NO) forKey:docRef];
        }
    }];
    return hasContent;
}

-(bool)isLoaded
{
    return _isLoaded;
}

-(void)waitUntilLoadingIsDone {
    while (!(_isLoaded || _isFailure) && [[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
}


-(void)failed
{
    _isLoading = NO;
    _isFailure = YES;
    
    if (self.failureBlock != nil) {
        self.failureBlock();
    }
}

-(void)setupCompleted
{
    _isLoading = NO;
    if (_isFailure) {
        [self failed];
    } else {
        _isLoaded = YES;
        [[NUXHierarchyDB shared] saveHierarchyLoaded:_name];
        if (self.completionBlock != nil) {
            self.completionBlock();
        }
    }
}

-(void)setup
{
    _isLoading = YES;
    NSMutableArray *docs = [NSMutableArray new];
    
    // Block passed to request filled with all expected documents
    void (^appendDocs)(NUXRequest *) = ^(NUXRequest *request) {
        NUXDocuments *res = [request responseEntityWithError:nil];
        [docs addObjectsFromArray:res.entries];
        if (res.isNextPageAvailable) {
            [request addParameterValue:[NSString stringWithFormat:@"%@", @(res.currentPageIndex + 1)] forKey:@"currentPageIndex"];
            [request start];
        } else {
            [self performSelectorInBackground:@selector(startBuildingHierarchyWithDocuments:) withObject:docs];
        }
    };
    
    void (^failureBlock)(NUXRequest *) = ^(NUXRequest *request) {
        [self failed];
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
    
    SEL finishSelector = @selector(failed);
    if ([documents count] > 0) {
        [self buildHierarchy:documents];
        finishSelector = @selector(setupCompleted);
    }
    else {
        NSLog(@"Load failed because request do not returns any documents.");
    }
    [self performSelectorOnMainThread:finishSelector withObject:nil waitUntilDone:[NSThread isMainThread]];
}

-(void)buildHierarchy:(NSArray *)pDocuments {
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
        
        //        NSString *hKey = parent == nil ? kRootKey : parent.uid;
        [[NUXHierarchyDB shared] insertNodes:@[doc] fromHierarchy:_name withParent:parent andDepth:parents.count];
        //[NUXHierarchy addNodeDocument:doc toHierarchy:_documents key:hKey];
        
        [self updateLeafContentForDocument:doc andDepth:parents.count];
        
        [parents addObject:doc];
    }];
}

-(NSArray *)updateLeafContentForDocument:(NUXDocument *)document andDepth:(NSUInteger)depth {
    NSArray *content;
    if (_nodeBlock) {
        content = _nodeBlock(document, depth);
        
        [[NUXHierarchyDB shared] deleteContentForDocument:document fromHierarchy:_name];
        if ([content count] > 0) {
            [[NUXHierarchyDB shared] insertcontent:content fromHierarchy:_name forNode:document.uid];
        }
    }
    return content;
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