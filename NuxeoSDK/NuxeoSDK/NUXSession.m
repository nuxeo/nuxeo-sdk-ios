//
//  NUXSession.m
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 13/11/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import "NUXSession.h"

@interface NUXSession () {
    
}

@property NSOperationQueue *queue;
@property NSMutableArray *schemas;
@property NSMutableArray *categories;

@end

@implementation NUXSession

-(id)init {
    self = [super init];
    if (self) {
        self.queue = [NSOperationQueue mainQueue];
        self.schemas = [NSMutableArray new];
        self.categories = [NSMutableArray new];
        
        self.repository = @"default";
    }
    return self;
}

-(void)dealloc {
    [self setQueue:Nil];
    [self setSchemas:Nil];
    [self setUsername:Nil];
    [self setUrl:Nil];
    [self setPassword:Nil];
    [self setRepository:Nil];
}

-(id)initWithServerURL:(NSURL *)url username:(NSString *)username password:(NSString *)password {
    self = [[NUXSession alloc] init];
    if (self) {
        [self setUrl:url];
        [self setUsername:username];
        [self setPassword:password];
    }
    return self;
}

-(void)addDefaultSchemas: (NSArray *)schemas {
    [self.schemas addObjectsFromArray:schemas];
}

-(void)addDefaultCategories: (NSArray *)categories {
    [self.categories addObjectsFromArray:categories];
}

-(void)startRequest: (ASIHTTPRequest *)request withCompletionBlock:(ASIBasicBlock)completion failureBlock:(ASIBasicBlock)failure {
    [self fillRequest:request];
    [request setCompletionBlock:completion];
    [request setFailedBlock:failure];
    [self.queue addOperation:request];
}

-(void)startRequestSynchronous: (ASIHTTPRequest *)request withCompletionBlock:(ASIBasicBlock)completion failureBlock:(ASIBasicBlock)failure {
    [self fillRequest:request];
    [request setCompletionBlock:completion];
    [request setFailedBlock:failure];
    [request startSynchronous];
}

-(void)fillRequest:(ASIHTTPRequest *)request {
    if (self.schemas.count > 0) {
        [request addRequestHeader:@"X-NXDocumentProperties" value:[self.schemas componentsJoinedByString:@","]];
    }

    if (self.categories.count > 0) {
        [request addRequestHeader:@"X-NXContext-Category" value:[self.categories componentsJoinedByString:@","]];
    }

    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    
    request.username = self.username;
    request.password = self.password;
}

@end
