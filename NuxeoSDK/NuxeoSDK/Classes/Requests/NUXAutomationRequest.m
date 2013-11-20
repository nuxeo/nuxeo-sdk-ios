//
// Created by Arnaud Kervern on 20/11/13.
// Copyright (c) 2013 Nuxeo. All rights reserved.
//


#import "NUXAutomationRequest.h"

@implementation NUXAutomationRequest {
    NSString *_inputFile;
    id _input;
    NSMutableDictionary *_context;
    NSMutableDictionary *_params;
}

-(id)init {
    self = [super init];
    if (self) {
        _context = [NSMutableDictionary new];
        _params = [NSMutableDictionary new];
        
        self.contentType = @"application/json+nxrequest";
        self.method = @"POST";
    }
    return self;
}

-(void)dealloc {
    _inputFile = nil;
    _input = nil;
    _context = nil;
    _params = nil;
}

- (void)addContextValue:(id)value forKey:(NSString *)key {
    [_context setObject:value forKey:key];
}
- (void)addParameterValue:(id)value forKey:(NSString *)key {
    [_params setObject:value forKey:key];
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

- (NSDictionary *)parameters {
    return [[NSDictionary alloc] initWithDictionary:_params];
}

- (id)fileInput {
    return [_inputFile copy];
}
- (id)input {
    return [_input copy];
}

@end