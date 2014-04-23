//
//  NUXTokenAuthenticator.h
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 14/01/14.
//  Copyright (c) 2014 Nuxeo. All rights reserved.
//

#import "NUXAuthenticator.h"
#import "NUXRequest.h"

#import "NUXSession+tokenAuthentication.h"

@interface NUXTokenAuthenticator : NSObject <NUXAuthenticator>

@property NSString *applicationName;
@property (readonly) NSString *deviceId;
@property NSString *permission;
@property NSString *deviceDescription;

-(id)initWithTokenName:(NSString *)aTokenName;

-(void)setTokenFromRequest:(NUXRequest *)aRequest withCompletionBlock:(NUXResponseBlock)aBlock;

-(void)resetSettings;

@end
