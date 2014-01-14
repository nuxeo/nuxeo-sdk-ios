//
//  NUXBasicAuthentication.m
//  NuxeoSDK
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

#import "NUXBasicAuthenticator.h"

NSString *const kUsernameKey = @"Username";
NSString *const kPasswordKey = @"Password";

@implementation NUXBasicAuthenticator {
    NSString *_username;
    NSString *_password;
}

-(id)initWithUsername:(NSString *)aUsername password:(NSString *)aPassword {
    self = [super init];
    if (self) {
        _username = aUsername;
        _password = aPassword;
    }
    return self;
}

-(id)initWithPropertyFile {
    self = [super init];
    if (self) {
        NSString *propertyFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:kPropertyFileName ofType:@"plist"];
        if (propertyFilePath == nil) {
            [NUXException raise:@"Unable to find property file" format:@"Unable to find file: %@ in bundle resources.", kPropertyFileName];
        }
        
        NSDictionary *plist = [[NSDictionary alloc] initWithContentsOfFile:propertyFilePath];
        NSString *value = [plist valueForKey:kUsernameKey];
        if (value != nil) {
            _username = value;
        }
        value = [plist valueForKey:kPasswordKey];
        if (value != nil) {
            _password = value;
        }
    }
    return self;
}

-(BOOL)softAuthentication {
    return NO;
}

-(void)prepareRequest:(ASIHTTPRequest *)request {
    request.username = _username;
    request.password = _password;
}
@end
