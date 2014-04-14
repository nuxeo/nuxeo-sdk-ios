//
//  NUXTokenAuthentication.m
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 14/01/14.
//  Copyright (c) 2014 Nuxeo. All rights reserved.
//

#import "NUXAbstractTestCase.h"
#import "NUXTokenAuthenticator.h"

@interface NUXTokenAuthenticator (private)
-(void)fillRequestWithParameters:(NUXRequest *)aRequest;
-(NSString *)settingsUsernameKey;
-(NSString *)settingsTokenKey;
@end

@interface NUXTokenAuthenticatorTests : NUXAbstractTestCase

@end

@implementation NUXTokenAuthenticatorTests

- (void)setUp
{
    [super setUp];
    NSURL *url = [[NSURL alloc] initWithString:@"http://localhost:8080/nuxeo"];
    session = [[NUXSession alloc] initWithServerURL:url authenticator:nil];
    [session addDefaultSchemas:@[@"dublincore"]];
}

- (void)tearDown
{
    [super tearDown];
}

-(void)testTokenGeneration {
    NUXTokenAuthenticator *auth = [[NUXTokenAuthenticator alloc] init];
    auth.applicationName = @"myTest";
    auth.permission = @"r";
    
    // Check that soft authentication is false and deviceId is generated
    XCTAssertFalse([auth softAuthentication]);
    XCTAssertNotNil(auth.deviceId);
    
    session.authenticator = auth;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    // Ensure that document is not fetchable
    NUXRequest *request = [session requestDocument:@"/default-domain"];
    [request setCompletionBlock:^(NUXRequest *request) {
        NSLog(@"URL: %@", request.url);
        XCTFail(@"Should fail with 401: %d", request.responseStatusCode);
    }];
    [request setFailureBlock:^(NUXRequest *request) {
        XCTAssertEqual(401, request.responseStatusCode);
    }];
    [request startSynchronous];
    
    // Ask for token
    request = [session requestTokenAuthentication];
    request.username = @"Administrator";
    request.password = @"Administrator";
    [auth fillRequestWithParameters:request];
    
    NSLog(@"URL: %@", request.url);
    [request setCompletionBlock:^(NUXRequest *request) {
        NSLog(@"Token: %@", request.responseString);
        XCTAssertTrue([request.url.absoluteString rangeOfString:@"token"].location != NSNotFound);
        XCTAssertEqual(201, request.responseStatusCode);
        XCTAssertNotNil(request.responseString);
        
        // Simulate user default save
        [ud setObject:request.responseString forKey:[auth settingsTokenKey]];
        [ud setObject:request.username forKey:[auth settingsUsernameKey]];
    }];
    [request setFailureBlock:^(NUXRequest *request) {
        XCTFail(@"Fail with status code: %d", request.responseStatusCode);
    }];
    [request startSynchronous];
    
    // Check token is taken into account
    XCTAssertTrue([auth softAuthentication]);
    request = [session requestDocument:@"/default-domain"];
    [request setCompletionBlock:^(NUXRequest *request) {
        XCTAssertEqual(200, request.responseStatusCode);
    }];
    [request setFailureBlock:^(NUXRequest *request) {
        XCTFail(@"Fail with status code: %d", request.responseStatusCode);
    }];
    [request startSynchronous];
}

@end
