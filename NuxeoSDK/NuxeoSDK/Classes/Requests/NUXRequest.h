//
//  NUXRequest.h
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 14/11/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NUXSession.h"

@class NUXSession;

@interface NUXRequest : NSObject

@property NSString *method;
@property NSString *contentType;
@property NSString *repository;
@property NSString *downloadDestinationPath;
@property NSMutableData *postData;
@property(readonly) NSArray *schemas;
@property(readonly) NSArray *categories;
@property(readonly) NSArray *adaptors;

// Create a request object
- (id)initWithSession:(NUXSession *)session;

// Append a segment to the target url
- (NUXRequest *)addURLSegment:(NSString *)aSegment;

// Add an Adaptor to the target url
- (NUXRequest *)addAdaptor:(NSString *)adaptor;

// Add an Adaptor and a value to the target url
- (NUXRequest *)addAdaptor:(NSString *)adaptor withValue:(NSString *)value;

// Add a category to the request headers
- (NUXRequest *)addCategory:(NSString *)category;

// Add some categories to the request headers
- (NUXRequest *)addCategories:(NSArray *)categories;

// Add a schema to the request headers
- (NUXRequest *)addSchema:(NSString *)schema;

// Add multiple schemas to the request headers
- (NUXRequest *)addSchemas:(NSArray *)schemas;

// Add custom header to the request
- (NUXRequest *)addHeaderWithKey:(NSString *)key value:(NSString *)value;

// Read access to the complete URL
- (NSURL *)URL;

// Read access to registered headers
- (NSDictionary *)headers;

- (void)setCompletionBlock:(NUXResponseBlock)aCompletionBlock;

- (void)setFailureBlock:(NUXResponseBlock)aFailureBlock;

- (void)start;

- (void)startSynchronous;

- (void)startWithCompletionBlock:(NUXResponseBlock)completionBlock FailureBlock:(NUXResponseBlock)failureBlock;

- (void)setResponseData:(NSData *)data WithEncoding:(NSStringEncoding)encoding StatusCode:(int)statusCode message:(NSString *)message;

@property(readonly) int responseStatusCode;
@property(readonly) NSString *responseMessage;

- (NSString *)responseString;

- (NSData *)responseData;

- (id)responseJSONWithError:(NSError **)error;

@end
