//
//  NUXTokenAuthenticator.m
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 14/01/14.
//  Copyright (c) 2014 Nuxeo. All rights reserved.
//

#import "NUXTokenAuthenticator.h"
#import "NUXSession+requests.h"

#define kDefaultTokenName @"defaultToken"
#define kTokenUUID @"nux.token.uuid"

#define kTokenApplicationName @"applicationName"
#define kTokenDeviceId @"deviceId"
#define kTokenPermission @"permission"
#define kTokenDeviceDescription @"deviceDescription"

#define kHeaderToken @"X-Authentication-Token"
#define kHeaderUsername @"X-User-Id"
#define kHeaderApplicationName @"X-Application-Name"
#define kHeaderDeviceId @"X-Device-Id"

@implementation NUXTokenAuthenticator {
    NSString *_tokenName;
}

-(id)init {
    self = [super init];
    if (self) {
        _tokenName = kDefaultTokenName;
        _deviceId = [self UUID];
    }
    return self;
}

-(id)initWithTokenName:(NSString *)aTokenName {
    self = [self init];
    if (self) {
        _tokenName = aTokenName;
    }
    return self;
}

-(void)setTokenFromRequest:(NUXRequest *)aRequest withCompletionBlock:(NUXBooleanBlock)aBlock {
    [self fillRequestWithParameters:aRequest];
    
    [aRequest startWithCompletionBlock:^(NUXRequest *request) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:request.username forKey:[self settingsUsernameKey]];
        [ud setObject:request.responseString forKey:[self settingsTokenKey]];
        
        NUXDebug(@"New token (%@) saved for %@", [ud objectForKey:[self settingsTokenKey]], [ud objectForKey:[self settingsUsernameKey]]);
        
        if (aBlock != nil) {
            aBlock(YES);
        }
    } FailureBlock:^(NUXRequest *request) {
        [self resetSettings];
        if (aBlock != nil) {
            aBlock(NO);
        }
    }];
    
    [self setTokenFromRequest:nil withCompletionBlock:^(BOOL success) {
        //
    }];
}

#pragma mark -
#pragma mark Internal methods

-(void)fillRequestWithParameters:(NUXRequest *)aRequest {
    if (self.applicationName == nil || self.permission == nil) {
        [NUXException raise:@"ApplicationName or Permission cannot be nil" format:@"You have to fill a applicationName and permission properties."];
    }
    
    [aRequest addParameterValue:self.applicationName forKey:kTokenApplicationName];
    [aRequest addParameterValue:self.deviceId forKey:kTokenDeviceId];
    [aRequest addParameterValue:self.permission forKey:kTokenPermission];
    
    if (self.deviceDescription != nil) {
        [aRequest addParameterValue:self.deviceDescription forKey:kTokenDeviceDescription];
    }
}

-(void)resetSettings {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:[self settingsUsernameKey]];
    [ud removeObjectForKey:[self settingsTokenKey]];
}

-(NSString *)settingsUsernameKey {
    return [NSString stringWithFormat:@"%@%@", [self settingsPrefix], @"username"];
}

-(NSString *)settingsTokenKey {
    return [NSString stringWithFormat:@"%@%@", [self settingsPrefix], @"token"];
}

-(NSString *)settingsPrefix {
    return [NSString stringWithFormat:@"%@.%@.", @"nuxeo", _tokenName];
}

-(NSString *)UUID {
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    if (![settings objectForKey:kTokenUUID]) {
        CFUUIDRef theUUID = CFUUIDCreate(NULL);
        CFStringRef uuidStrRef = CFUUIDCreateString(NULL, theUUID);
        NSString* theUUIDstr = [NSString stringWithString:(__bridge  NSString*) uuidStrRef];
        CFRelease(uuidStrRef);
        CFRelease(theUUID);
        [settings setValue:theUUIDstr forKey:kTokenUUID];
        NUXDebug(@"New DeviceID generation: %@", theUUIDstr);
    }
    return [settings stringForKey:kTokenUUID];
}

#pragma mark -
#pragma mark NUXAuthenticator protocol methods

-(BOOL)softAuthentication {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return ([ud objectForKey:[self settingsUsernameKey]] && [ud objectForKey:[self settingsTokenKey]]);
}

-(void)prepareRequest:(ASIHTTPRequest *)request {
    // Bypass request preparation in case soft authentication isn't done
    if (![self softAuthentication]) {
        return;
    }
    
    request.username = nil;
    request.password = nil;

    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [request addRequestHeader:kHeaderUsername value:[ud objectForKey:[self settingsUsernameKey]]];
    [request addRequestHeader:kHeaderToken value:[ud objectForKey:[self settingsTokenKey]]];
    
    [request addRequestHeader:kHeaderDeviceId value:self.deviceId];
    [request addRequestHeader:kHeaderApplicationName value:self.applicationName];
}

@end
