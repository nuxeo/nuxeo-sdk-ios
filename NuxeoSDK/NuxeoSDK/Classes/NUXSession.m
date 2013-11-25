//
//  NUXSession.m
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 13/11/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import <ASIHTTPRequest.h>
#import <ASIFormDataRequest.h>
#import "NUXSession.h"
#import "NUXAutomationRequest.h"

@interface NUXRequest (session)
-(ASIHTTPRequest *)requestASI;
@end

@interface NUXSession ()

@property NSOperationQueue *queue;
@property NSMutableArray *schemas;
@property NSMutableArray *categories;

@end

@implementation NUXSession

NSString *const kPropertyFileName = @"NUXSession-info";
NSString *const kURLKey = @"URL";
NSString *const kUsernameKey = @"Username";
NSString *const kPasswordKey = @"Password";
NSString *const kRepositoryKey = @"Repository";
NSString *const kApiPrefix = @"ApiPrefix";

- (id)init {
    self = [super init];
    if (self) {
        self.queue = [NSOperationQueue mainQueue];
        self.schemas = [NSMutableArray new];
        self.categories = [NSMutableArray new];

        self.repository = @"default";
        self.apiPrefix = @"api/v1";
    }
    return self;
}

- (void)dealloc {
    [self setQueue:Nil];
    [self setSchemas:Nil];
    [self setUsername:Nil];
    [self setUrl:Nil];
    [self setPassword:Nil];
    [self setRepository:Nil];
}

- (id)initWithServerURL:(NSURL *)url username:(NSString *)username password:(NSString *)password {
    self = [[NUXSession alloc] init];
    if (self) {
        [self setUrl:url];
        [self setUsername:username];
        [self setPassword:password];
    }
    return self;
}

- (void)addDefaultSchemas:(NSArray *)schemas {
    [self.schemas addObjectsFromArray:schemas];
}

- (void)addDefaultCategories:(NSArray *)categories {
    [self.categories addObjectsFromArray:categories];
}

- (void)startRequest:(NUXRequest *)request withCompletionBlock:(NUXBasicBlock)completion failureBlock:(NUXBasicBlock)failure {
    ASIHTTPRequest *httpReq = [self httpRequestWithRequest:request withCompletionBlock:completion failureBlock:failure];
    [self.queue addOperation:httpReq];
}

- (void)startRequestSynchronous:(NUXRequest *)request withCompletionBlock:(NUXBasicBlock)completion failureBlock:(NUXBasicBlock)failure {
    ASIHTTPRequest *httpReq = [self httpRequestWithRequest:request withCompletionBlock:completion failureBlock:failure];
    [httpReq startSynchronous];
}

- (ASIHTTPRequest *)httpRequestWithRequest:(NUXRequest *)nRequest withCompletionBlock:(NUXBasicBlock)completion failureBlock:(NUXBasicBlock)failure {
    ASIHTTPRequest *request = [nRequest requestASI];
    
    [request setRequestMethod:nRequest.method];

    ASIHTTPRequest *__weak wRequest = request;
    [request setCompletionBlock:^{
        [nRequest setResponseData:wRequest.responseData WithEncoding:wRequest.responseEncoding StatusCode:wRequest.responseStatusCode message:wRequest.responseStatusMessage];
        completion();
    }];
    [request setFailedBlock:^{
        [nRequest setResponseData:wRequest.responseData WithEncoding:wRequest.responseEncoding StatusCode:wRequest.responseStatusCode message:wRequest.responseStatusMessage];
        failure();
    }];
    
    if (nRequest.downloadDestinationPath != nil) {
        request.downloadDestinationPath = nRequest.downloadDestinationPath;
    }

    NSArray *schemas = [nRequest.schemas arrayByAddingObjectsFromArray:self.schemas];
    if (schemas.count > 0) {
        NSString *hs = [schemas indexOfObject:@"*"] == NSNotFound ? [schemas componentsJoinedByString:@","] : @"*";
        [request addRequestHeader:@"X-NXDocumentProperties" value:hs];
    }

    NSArray *categories = [nRequest.categories arrayByAddingObjectsFromArray:self.categories];
    if (categories.count > 0) {
        [request addRequestHeader:@"X-NXContext-Category" value:[categories componentsJoinedByString:@","]];
    }

    [nRequest.headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [request addRequestHeader:key value:obj];
    }];
    [request addRequestHeader:@"Content-Type" value:nRequest.contentType];

    request.username = self.username;
    request.password = self.password;

    return request;
}

- (void)setupWithFile:(NSString *)filePath {
    NSDictionary *plist = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    NSString *value = [plist valueForKey:kUsernameKey];
    if (value != nil) {
        self.username = value;
    }
    value = [plist valueForKey:kPasswordKey];
    if (value != nil) {
        self.password = value;
    }
    value = [plist valueForKey:kRepositoryKey];
    if (value != nil) {
        self.repository = value;
    }
    value = [plist valueForKey:kURLKey];
    if (value != nil) {
        self.url = [NSURL URLWithString:value];
    }
    value = [plist valueForKey:kApiPrefix];
    if (value != nil) {
        self.apiPrefix = value;
    }
}

+ (NUXSession *)sharedSession {
    static dispatch_once_t pred = 0;
    static NUXSession *__strong _shared = nil;

    dispatch_once(&pred, ^{
        _shared = [NUXSession new];
        NSString *properties = [[NSBundle bundleForClass:[_shared class]] pathForResource:kPropertyFileName ofType:@"plist"];
        if (properties != nil) {
            [_shared setupWithFile:properties];
        }
    });

    return _shared;
}

@end
