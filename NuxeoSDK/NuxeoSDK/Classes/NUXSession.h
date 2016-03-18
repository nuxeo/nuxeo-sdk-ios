//
//  NUXSession.h
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

#import <Foundation/Foundation.h>
#import "NUXConstants.h"
#import "NUXRequest.h"
#import "NUXAuthenticator.h"

@class NUXRequest;

@interface NUXSession : NSObject

@property NSURL *url;
@property NSString *apiPrefix;
@property NSString *repository;
@property id<NUXAuthenticator> authenticator;

/**
 *  Convenience init function to create a NUXSession object with url, username and password.
 *  url must contains application name like: http://localhost:8080/nuxeo
 */
- (id)initWithServerURL:(NSURL *)url authenticator:(id<NUXAuthenticator>)authenticator;

/**
 *  Register some schemas that will be added to all requests
 *
 *  @param schemas use @"*" to get all schemas once
 */
- (void)addDefaultSchemas:(NSArray *)schemas;

/**
 *  Register some categories that will be added to all requests
 */
- (void)addDefaultCategories:(NSArray *)categories;

// Cancel current requests
- (void)cancelAllRequests;
- (void)setRequestQueueMaxConcurrentOperationCount:(NSInteger)count;
// Cancel only requests that look like to download a blob
- (void)cancelDownloadsRequests;
- (void)setDownloadQueueMaxConcurrentOperationCount:(NSInteger)count;

/**
 *  Execute a NUXRequest asynchronously using this session and authentication challenge.
 */
- (void)startRequest:(NUXRequest *)request withCompletionBlock:(NUXBasicBlock)completion failureBlock:(NUXBasicBlock)failure;

/**
 *  Execute a NUXRequest synchronously using this session and authentication challenge.
 */
- (void)startRequestSynchronous:(NUXRequest *)request withCompletionBlock:(NUXBasicBlock)completion failureBlock:(NUXBasicBlock)failure;

+ (NUXSession *)sharedSession;
+(BOOL)isNetworkReachable;

@end
