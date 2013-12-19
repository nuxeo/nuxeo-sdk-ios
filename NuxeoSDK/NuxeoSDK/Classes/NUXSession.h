//
//  NUXSession.h
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 13/11/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NUXConstants.h"
#import "NUXRequest.h"

@class NUXRequest;

@interface NUXSession : NSObject

@property NSURL *url;
@property NSString *apiPrefix;
@property NSString *username;
@property NSString *password;
@property NSString *repository;

// Convenience init function to create a NUXSession object with url, username and password.
// url must contains application name like: http://localhost:8080/nuxeo
- (id)initWithServerURL:(NSURL *)url username:(NSString *)username password:(NSString *)password;

// Register some schemas that will be added to all requests
- (void)addDefaultSchemas:(NSArray *)schemas;

// Register some categories that will be added to all requests
- (void)addDefaultCategories:(NSArray *)categories;

// Cancel current requests
- (void)cancelAllRequests;
- (void)setRequestQueueMaxConcurrentOperationCount:(NSInteger)count;
// Cancel only requests that look like to download a blob
- (void)cancelDownloadsRequests;
- (void)setDownloadQueueMaxConcurrentOperationCount:(NSInteger)count;

// Execute a NUXRequest asynchronously using this session and authentication challenge.
- (void)startRequest:(NUXRequest *)request withCompletionBlock:(NUXBasicBlock)completion failureBlock:(NUXBasicBlock)failure;

// Execute a NUXRequest synchronously using this session and authentication challenge.
- (void)startRequestSynchronous:(NUXRequest *)request withCompletionBlock:(NUXBasicBlock)completion failureBlock:(NUXBasicBlock)failure;

+ (NUXSession *)sharedSession;
+(BOOL)isNetworkReachable;

@end
