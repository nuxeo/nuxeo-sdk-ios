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


-(id)init;
-(id)initWithServerURL: (NSURL *)url username: (NSString *)username password: (NSString *)password;

-(void)addDefaultSchemas: (NSArray *)schemas;
-(void)addDefaultCategories: (NSArray *)categories;

-(void)startRequest: (NUXRequest *)request withCompletionBlock: (NUXBasicBlock)completion failureBlock: (NUXBasicBlock)failure;
-(void)startRequestSynchronous: (NUXRequest *)request withCompletionBlock: (NUXBasicBlock)completion failureBlock: (NUXBasicBlock)failure;

-(NUXRequest *)requestDocument:(NSString *)documentRef;
-(NUXRequest *)requestChildren:(NSString *)documentRef;

@end
