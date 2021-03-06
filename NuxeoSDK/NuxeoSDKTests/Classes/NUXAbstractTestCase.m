//
//  NUXAbstractTest.m
//  NuxeoSDK
//  Created by Arnaud Kervern on 2013-11-27.
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

#import "NUXAbstractTestCase.h"
#import "NUXSQLiteDatabase.h"
#import "NUXBasicAuthenticator.h"
#import "NUXTokenAuthenticator.h"

#define NUX_XCTEST 1

@interface NUXEntityCache (private)
-(void)createTableIfNotExists;
@end

@implementation NUXAbstractTestCase

-(id)init
{
    self = [super init];
    if (self) {
        self.continueAfterFailure = NO;
    }
    return self;
}

-(NUXDocument *)dummyDocument {
    NUXDocument *doc = [NUXDocument new];
    
    doc.uid = [NSString stringWithFormat:@"%@-%@-%@", @(random()), @(random()), @(random())];
    doc.title = [NSString stringWithFormat:@"Dummy Title %@", @(random())];
    doc.path = [NSString stringWithFormat:@"/%@/%@/%@", @(random()), @(random()), @(random())];
    doc.type = @"File";
    doc.name = [NSString stringWithFormat:@"%@", @(random())];
    doc.properties = [NSMutableDictionary dictionaryWithDictionary:@{@"file:content": @{@"digest": [NSString stringWithFormat:@"dummyDigest%@", @(random())], @"name" : @"dummyFilename.txt"}}];
    
    return doc;
}

- (void)setUp
{
    [super setUp];
    [ASIHTTPRequest clearSession];
    
    NSURL *url = [[NSURL alloc] initWithString:@"http://localhost:8080/nuxeo"];
    NUXBasicAuthenticator *authenticator = [[NUXBasicAuthenticator alloc] initWithUsername:@"Administrator" password:@"Administrator"];
    
    session = [[NUXSession alloc] initWithServerURL:url authenticator:authenticator];
    [session addDefaultSchemas:@[@"dublincore"]];
    
    [[NUXSQLiteDatabase shared] deleteDatabase];
    [[NUXEntityCache instance] createTableIfNotExists];
    
    // Ensure to cleanup the UserDefaults value
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:[NUXTokenAuthenticator settingsUsernameKey]];
    [ud removeObjectForKey:[NUXTokenAuthenticator settingsTokenKey]];
    [NSUserDefaults resetStandardUserDefaults];
}

- (void)tearDown
{
    [super tearDown];
    
    session = Nil;
}

@end
