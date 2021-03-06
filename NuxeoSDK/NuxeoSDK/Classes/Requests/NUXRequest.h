//
//  NUXRequest.h
//  NuxeoSDK
//  Created by Arnaud Kervern on 2013-11-14.
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
#import "NUXSession.h"
#import "NUXEntity.h"

@class NUXSession;

/**
 *  Base class that handle request to a Nuxeo Server
 */
@interface NUXRequest : NSObject

/**
 *  Allow request to try to continue to download while the application is in background
 */
@property BOOL shouldContinueWhenAppEntersBackground;
@property NSURL *url;
@property NSString *method;
@property NSString *contentType;
@property NSString *repository;
@property NSString *username;
@property NSString *password;
@property NSString *downloadDestinationPath;
@property NSMutableData *postData;
@property(readonly) NSArray *schemas;
@property(readonly) NSArray *categories;
@property(readonly) NSArray *adaptors;
@property(strong,nonatomic) NSError *error;

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
- (NUXRequest *)addHeaderValue:(NSString *)value forKey:(NSString *)key;

// Add parameters to the request
- (NUXRequest *)addParameterValue:(NSString *)value forKey:(NSString *)key;

// Read access to registered headers
- (NSDictionary *)headers;

// Read access to registered parameters
- (NSDictionary *)parameters;

- (void)setCompletionBlock:(NUXResponseBlock)aCompletionBlock;

- (void)setFailureBlock:(NUXResponseBlock)aFailureBlock;

- (void)start;

- (void)startSynchronous;

- (void)startWithCompletionBlock:(NUXResponseBlock)completionBlock FailureBlock:(NUXResponseBlock)failureBlock;

- (void)setResponseData:(NSData *)data WithEncoding:(NSStringEncoding)encoding StatusCode:(int)statusCode message:(NSString *)message error:(NSError *)error;

/**
 *  HTTP Response Status Code
 */
@property(readonly) int responseStatusCode;
/**
 *  HTTP Reponse Message
 */
@property(readonly) NSString *responseMessage;

/**
 *  After completion, read response body as NSString
 *
 *  @return returns the response body in a NSString
 */
- (NSString *)responseString;

/**
 *  After completion, read response body as NSData object
 *
 *  @return returns the response body in a NSData object
 */
- (NSData *)responseData;

/**
 *  After completion, try to read response as JSON and convert it to the corresponding NUXEntity
 *
 *  @return corresponding object, or nil.
 */
- (id)responseEntityWithError:(NSError **)error;

/**
 *  After completion, try to read response as JSON
 *
 *  @return a NSDictionnary of the response, or nil.
 */
- (id)responseJSONWithError:(NSError **)error;

@end
