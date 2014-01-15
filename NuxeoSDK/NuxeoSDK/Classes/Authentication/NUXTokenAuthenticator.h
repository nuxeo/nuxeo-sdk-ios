//
//  NUXTokenAuthenticator.h
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 14/01/14.
//  Copyright (c) 2014 Nuxeo. All rights reserved.
//

#import "NUXAuthenticator.h"
#import "NUXRequest.h"

@interface NUXTokenAuthenticator : NSObject <NUXAuthenticator>

@property NSString *applicationName;
@property (readonly) NSString *deviceId;
@property NSString *permission;
@property NSString *deviceDescription;

-(id)initWithTokenName:(NSString *)aTokenName;

-(void)setTokenFromRequest:(NUXRequest *)aRequest withCompletionBlock:(NUXBooleanBlock)aBlock;

@end

#pragma mark -
#pragma mark NUXSession protocol to add token generation request

@interface NUXSession (tokenAuthentication)
-(NUXRequest *)requestTokenAuthentication;
@end

@implementation NUXSession (tokenAuthentication)
-(NUXRequest *)requestTokenAuthentication {
    NUXRequest *request = [[NUXRequest alloc] initWithSession:self];
    
    request.url = [NSURL URLWithString:self.url.absoluteString];
    [[request addURLSegment:@"authentication"] addURLSegment:@"token"];
    
    return request;
}
@end