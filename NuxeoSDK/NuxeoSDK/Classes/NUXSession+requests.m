//
//  NUXSession+requests.m
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 18/11/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import "NUXSession+requests.h"

@implementation NUXSession (requests)

#pragma mark Internal methods

- (NSString *)segmentForDocumentRef:(NSString *)docRef {
    return [docRef characterAtIndex:0] == '/' ? @"path" : @"id";
}

#pragma mark -
#pragma mark NUXRequest convenience methods

- (NUXRequest *)request {
    return [[NUXRequest alloc] initWithSession:self];
}

- (NUXRequest *)requestDocument:(NSString *)documentRef {
    return [[[[NUXRequest alloc] initWithSession:self] addURLSegment:[self segmentForDocumentRef:documentRef]] addURLSegment:documentRef];
}

- (NUXRequest *)requestUpdateDocument:(id)document {
    NUXRequest *request = [self request];
    request.method = @"put";
    [request.postData appendData:[NSJSONSerialization dataWithJSONObject:document options:0 error:nil]];
    [[request addURLSegment:@"id"] addURLSegment:[document valueForKey:@"uid"]];

    return request;
}

- (NUXRequest *)requestCreateDocument:(id)document withParent:(NSString *)documentRef {
    NUXRequest *request = [self requestDocument:documentRef];
    request.method = @"post";
    [request.postData appendData:[NSJSONSerialization dataWithJSONObject:document options:0 error:nil]];
    return request;
}

- (NUXRequest *)requestDeleteDocument:(NSString *)documentRef {
    NUXRequest *request = [self requestDocument:documentRef];
    request.method = @"delete";
    return request;
}

- (NUXRequest *)requestChildren:(NSString *)documentRef {
    return [[self requestDocument:documentRef] addAdaptor:@"children"];
}

- (NUXRequest *)requestQuery:(NSString *)query {
    NUXAutomationRequest *request = [self requestOperation:@"Document.Query"];
    [request addParameterValue:query forKey:@"query"];

    return request;
}

#pragma mark -
#pragma mark NUXAutomationRequest convenience methods

- (NUXAutomationRequest *)requestOperation:(NSString *)operationId {
    NUXAutomationRequest *request = [[NUXAutomationRequest alloc] initWithSession:self];
    [[request addURLSegment:@"automation"] addURLSegment:operationId];
    return request;
}

-(NUXAutomationRequest *)requestImportFile:(NSString *)file withParent:(NSString *)documentRef {
    NUXAutomationRequest *request = [self requestOperation:@"FileManager.Import"];
    
    [request addContextValue:documentRef forKey:@"currentDocument"];
    [request setInputFile:file];
    
    return request;
}

@end
