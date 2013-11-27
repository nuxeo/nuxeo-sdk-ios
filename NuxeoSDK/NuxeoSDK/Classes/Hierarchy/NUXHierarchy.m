//
// Created by Arnaud Kervern on 26/11/13.
// Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import "NUXHierarchy.h"

#define kRootKey @"0"

@implementation NUXHierarchy {
    bool _isLoaded;
}

-(id)initWithRequest:(NUXRequest *)request
{
    self = [super init];
    if (self) {
        _isLoaded = NO;
        [self setupWithRequest:request];
    }
    return self;
}

-(NUXDocuments *)childrenOfDocument:(NUXDocument *)document
{
    return nil;
}

-(bool)isLoaded
{
    return _isLoaded;
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
            [self buildHierarchyFromDocuments:docs];
        }
    };
    
    [request setCompletionBlock:appendDocs];
    [request startSynchronous];
}

-(void)buildHierarchyFromDocuments:(NSArray *)documents
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
    
    _isLoaded = YES;
}

-(void)buildHierarchy:(NSArray *)pDocuments {
    if (pDocuments.count == 0) {
        [NSException raise:@"Empty array" format:@"Hierarchy initialized with an empty array."];
    }
    
    NSMutableArray *documents = [NSMutableArray arrayWithArray:pDocuments];
    NSMutableDictionary *__block children = [NSMutableDictionary new];
    NSMutableArray *__block parents = [NSMutableArray new];
    [documents enumerateObjectsUsingBlock:^(NUXDocument *doc, NSUInteger idx, BOOL *stop) {
        if (idx == 0) {
            [parents addObject:doc];
            NSMutableArray *child = [NSMutableArray arrayWithObject:doc];
            [children setObject:child forKey:kRootKey];
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
            child = [children valueForKey:kRootKey];
            [child addObject:doc];
        } else {
            child = [children valueForKey:parent.uid];
            if (child == nil) {
                child = [NSMutableArray new];
            }
            
            [child addObject:doc];
            [children setValue:child forKey:parent.uid];
        }
        [parents addObject:doc];
    }];
    
    NSLog(@"%@", children);
}

@end