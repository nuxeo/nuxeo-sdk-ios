//
//  NUXSession.h
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 13/11/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NUXRequest.h"

@class NUXRequest;

@interface NUXSession : NSObject

@property NSURL *url;
@property NSString *username;
@property NSString *password;
@property NSString *repository;


// Convenience init function to create a NUXSession object with url, username and password.
// url must contains application name like: http://localhost:8080/nuxeo
-(id)initWithServerURL: (NSURL *)url username: (NSString *)username password: (NSString *)password;

// Register some schemas that will be added to all requests
-(void)addDefaultSchemas: (NSArray *)schemas;
// Register some categories that will be added to all requests
-(void)addDefaultCategories: (NSArray *)categories;

// Execute a NUXRequest asynchronously using this session and authentication challenge.
-(void)startRequest: (NUXRequest *)request withCompletionBlock: (NUXBasicBlock)completion failureBlock: (NUXBasicBlock)failure;
// Execute a NUXRequest synchronously using this session and authentication challenge.
-(void)startRequestSynchronous: (NUXRequest *)request withCompletionBlock: (NUXBasicBlock)completion failureBlock: (NUXBasicBlock)failure;

// Convenience method to create a request associated with this session.
-(NUXRequest *)request;
// Convenience method to create a request to fetch a document associated with this session, documentRef could be an id or a path.
-(NUXRequest *)requestDocument:(NSString *)documentRef;
// Convenience method to create a request to fetch document's childen associated with this session, documentRef could be an id or a path.
-(NUXRequest *)requestChildren:(NSString *)documentRef;
// Convenience method get a request prepared to execute a Nuxeo Operation
-(NUXRequest *)requestOperation:(NSString *)operationId;
// Convenience method to query documents in NXQL
-(NUXRequest *)requestQuery:(NSString *)query;

@end
