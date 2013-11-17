//
//  NUXSession.m
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 13/11/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import "NUXSession.h"
#import <ASIHTTPRequest.h>

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
        if ([url.absoluteString rangeOfString:@"api"].location == NSNotFound) {
            url = [url URLByAppendingPathComponent:@"api/v1"];
        }
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

-(void)startRequest:(NUXRequest *)request withCompletionBlock:(NUXBasicBlock)completion failureBlock:(NUXBasicBlock)failure {
    ASIHTTPRequest *httpReq = [self httpRequestWithRequest:request withCompletionBlock:completion failureBlock:failure];
    [self.queue addOperation:httpReq];
}

-(void)startRequestSynchronous:(NUXRequest *)request withCompletionBlock:(NUXBasicBlock)completion failureBlock:(NUXBasicBlock)failure {
    ASIHTTPRequest *httpReq = [self httpRequestWithRequest:request withCompletionBlock:completion failureBlock:failure];
    [httpReq startSynchronous];
}

-(ASIHTTPRequest *)httpRequestWithRequest:(NUXRequest *)nRequest withCompletionBlock:(NUXBasicBlock)completion failureBlock:(NUXBasicBlock)failure {
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:nRequest.URL];
    [request setRequestMethod:nRequest.method];
    
    [request setCompletionBlock:^{
        [nRequest setResponseData:request.responseData WithEncoding:request.responseEncoding StatusCode:request.responseStatusCode message:request.responseStatusMessage];
        completion();
    }];
    [request setFailedBlock:^{
        [nRequest setResponseData:request.responseData WithEncoding:request.responseEncoding StatusCode:request.responseStatusCode message:request.responseStatusMessage];
        failure();
    }];

    NSArray *schemas = [nRequest.schemas arrayByAddingObjectsFromArray:self.schemas];
    if (schemas.count > 0) {
        NSString *hs = [schemas indexOfObject:@"*"] > 0 ? @"*" : [schemas componentsJoinedByString:@","];
        [request addRequestHeader:@"X-NXDocumentProperties" value:hs];
    }
    
    NSArray *categories = [nRequest.categories arrayByAddingObjectsFromArray:self.categories];
    if (categories.count > 0) {
        [request addRequestHeader:@"X-NXContext-Category" value:[categories componentsJoinedByString:@","]];
    }
    
    for (NSString *header in nRequest.headers.allKeys) {
        NSString *value = [nRequest.headers valueForKey:header];
        [request addRequestHeader:header value:value];
    }
    [request addRequestHeader:@"Content-Type" value:nRequest.contentType];
    
    request.username = self.username;
    request.password = self.password;
    
    return request;
}

-(void)fillRequest:(ASIHTTPRequest *)request {

}

@end