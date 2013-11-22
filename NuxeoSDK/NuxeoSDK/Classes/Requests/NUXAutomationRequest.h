//
// Created by Arnaud Kervern on 20/11/13.
// Copyright (c) 2013 Nuxeo. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "NUXRequest.h"

@interface NUXAutomationRequest : NUXRequest

- (void)addContextValue:(id)value forKey:(NSString *)key;

- (void)setInputFile:(NSString *)filePath;
- (void)setInput:(id)input;

- (NSDictionary *)context;
- (id)fileInput;
- (id)input;

@end