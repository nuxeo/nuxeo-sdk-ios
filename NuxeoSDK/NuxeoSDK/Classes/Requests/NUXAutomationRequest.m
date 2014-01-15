//
//  NUXAutomationRequest.m
//  NuxeoSDK
//  Created by Arnaud Kervern on 2013-11-20.
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

#import "NUXAutomationRequest.h"
#import <ASIFormDataRequest.h>

@implementation NUXAutomationRequest {
    NSString *_inputFile;
    id _input;
    NSMutableDictionary *_context;
}

-(id)init {
    self = [super init];
    if (self) {
        _context = [NSMutableDictionary new];
        
        self.contentType = @"application/json+nxrequest";
        self.method = @"POST";
    }
    return self;
}

-(void)dealloc {
    _inputFile = nil;
    _input = nil;
    _context = nil;
}

- (void)addContextValue:(id)value forKey:(NSString *)key {
    [_context setObject:value forKey:key];
}

// Add post file
- (void)setInputFile:(NSString *)filePath {
    _inputFile = filePath;
}
- (void)setInput:(id)input {
    _input = input;
}

- (NSDictionary *)context {
    return [[NSDictionary alloc] initWithDictionary:_context];
}

- (id)fileInput {
    return [_inputFile copy];
}
- (id)input {
    return [_input copy];
}

-(ASIHTTPRequest *)requestASI {
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:self.url];
    
    NSDictionary *params = @{@"context" : self.context, @"params" : self.parameters};
    [request addData:[NSJSONSerialization dataWithJSONObject:params options:0 error:nil] forKey:@"params"];
    if (self.fileInput != nil) {
        [request addFile:self.fileInput forKey:@"input"];
    } else {
        [request addData:self.input forKey:@"input"];
    }
    return request;
}

@end