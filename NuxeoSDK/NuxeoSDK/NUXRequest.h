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
@property (readonly) NSArray *schemas;
@property (readonly) NSArray *categories;
@property (readonly) NSArray *adaptors;

-(id)initWithSession:(NUXSession *)session;

-(NUXRequest *)addURLSegment:(NSString *)aSegment;

-(NUXRequest *)addAdaptor:(NSString *)adaptor;
-(NUXRequest *)addAdaptor:(NSString *)adaptor withValue:(NSString *)value;
-(NUXRequest *)addCategory:(NSString *)category;
-(NUXRequest *)addCategories:(NSArray *)categories;
-(NUXRequest *)addSchema:(NSString *)schema;
-(NUXRequest *)addSchemas:(NSArray *)schemas;

-(NUXRequest *)addHeaderWithKey:(NSString *)key value:(NSString *)value;

-(NSURL *)URL;
-(NSDictionary *)headers;

-(void)setCompletionBlock:(NUXBasicBlock)aCompletionBlock;
-(void)setFailureBlock:(NUXBasicBlock)aFailureBlock;

-(void)start;
-(void)startSynchronous;
-(void)startWithCompletionBlock:(NUXBasicBlock)completionBlock FailureBlock:(NUXBasicBlock)failureBlock;

-(void)setResponseData:(NSData *)data WithEncoding:(NSStringEncoding)encoding StatusCode:(int)statusCode message:(NSString *)message;
@property (readonly) int responseStatusCode;
@property (readonly) NSString *responseMessage;
-(NSString *)responseString;
-(NSData *)responseData;
-(id)responseJSONWithError:(NSError **)error;

@end
