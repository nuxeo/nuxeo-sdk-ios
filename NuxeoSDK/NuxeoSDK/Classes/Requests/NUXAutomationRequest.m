//
// Created by Arnaud Kervern on 20/11/13.
// Copyright (c) 2013 Nuxeo. All rights reserved.
//


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
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:self.URL];
    
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