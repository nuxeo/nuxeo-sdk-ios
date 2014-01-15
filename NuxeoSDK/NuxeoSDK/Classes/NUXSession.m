//
//  NUXSession.m
//  NuxeoSDK
//  Created by Arnaud Kervern on 2013-11-13.
//
/* (C) Copyright 2013-2014 Nuxeo SA (http://nuxeo.com/) and contributors.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the GNU Lesser General Public License
 * (LGPL) version 2.1 which accompanies this distribution, and is available at
 * http://www.gnu.org/licenses/lgpl-2.1.html
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * Contributors:
 *     Arnaud Kervern
 */

#import <ASIHTTPRequest.h>
#import <ASIFormDataRequest.h>
#import <Reachability.h>
#import "NUXSession.h"
#import "NUXAutomationRequest.h"

@interface NUXRequest (session)
-(ASIHTTPRequest *)requestASI;
@end

@interface NUXSession ()

@property NSOperationQueue *queue;
@property NSOperationQueue *downloadQueue;
@property NSMutableArray *schemas;
@property NSMutableArray *categories;

@end

@implementation NUXSession

NSString *const kURLKey = @"URL";
NSString *const kRepositoryKey = @"Repository";
NSString *const kApiPrefix = @"ApiPrefix";

- (id)init {
    self = [super init];
    if (self) {
        self.queue = [NSOperationQueue new];
        self.downloadQueue = [NSOperationQueue new];
        self.schemas = [NSMutableArray new];
        self.categories = [NSMutableArray new];

        self.repository = @"default";
        self.apiPrefix = @"api/v1";
    }
    return self;
}

- (void)dealloc {
    [self setQueue:Nil];
    [self setDownloadQueue:nil];
    [self setSchemas:Nil];
    [self setUrl:Nil];
    [self setRepository:Nil];
    [self setAuthenticator:nil];
}

- (id)initWithServerURL:(NSURL *)url authenticator:(id<NUXAuthenticator>)authenticator {
    self = [[NUXSession alloc] init];
    if (self) {
        [self setUrl:url];
        [self setAuthenticator:authenticator];
    }
    return self;
}

- (void)cancelAllRequests {
    [self.queue cancelAllOperations];
    [self.downloadQueue cancelAllOperations];
}

- (void)cancelDownloadsRequests {
    [self.downloadQueue cancelAllOperations];
}

-(void)setDownloadQueueMaxConcurrentOperationCount:(NSInteger)count {
    self.downloadQueue.maxConcurrentOperationCount = count;
}

-(void)setRequestQueueMaxConcurrentOperationCount:(NSInteger)count {
    self.queue.maxConcurrentOperationCount = count;
}

- (void)addDefaultSchemas:(NSArray *)schemas {
    [self.schemas addObjectsFromArray:schemas];
}

- (void)addDefaultCategories:(NSArray *)categories {
    [self.categories addObjectsFromArray:categories];
}

- (void)startRequest:(NUXRequest *)request withCompletionBlock:(NUXBasicBlock)completion failureBlock:(NUXBasicBlock)failure {
    ASIHTTPRequest *httpReq = [self httpRequestWithRequest:request withCompletionBlock:completion failureBlock:failure];
    if (httpReq.downloadDestinationPath) {
        [self.downloadQueue addOperation:httpReq];
    } else {
        [self.queue addOperation:httpReq];
    }
}

- (void)startRequestSynchronous:(NUXRequest *)request withCompletionBlock:(NUXBasicBlock)completion failureBlock:(NUXBasicBlock)failure {
    ASIHTTPRequest *httpReq = [self httpRequestWithRequest:request withCompletionBlock:completion failureBlock:failure];
    [httpReq startSynchronous];
}

- (ASIHTTPRequest *)httpRequestWithRequest:(NUXRequest *)nRequest withCompletionBlock:(NUXBasicBlock)completion failureBlock:(NUXBasicBlock)failure {
    ASIHTTPRequest *request = [nRequest requestASI];
    request.shouldContinueWhenAppEntersBackground = nRequest.shouldContinueWhenAppEntersBackground;

    [request setRequestMethod:nRequest.method];
    request.username = nRequest.username;
    request.password = nRequest.password;
    if (request.username && request.password) {
        request.authenticationScheme = (NSString *)kCFHTTPAuthenticationSchemeBasic; // Force basic auth if credentials setted in NUXRequest
    }

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
    
    if (self.authenticator != nil) {
        [self.authenticator prepareRequest:request];
    }
    
    return request;
}

- (void)setupWithFile:(NSString *)filePath {
    NSDictionary *plist = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    NSString *value = [plist valueForKey:kRepositoryKey];
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

+(BOOL)isNetworkReachable {
    return [[Reachability reachabilityForInternetConnection] isReachable];
}

@end
