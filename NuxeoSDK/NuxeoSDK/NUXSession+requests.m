//
//  NUXSession+requests.m
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 18/11/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import "NUXSession+requests.h"

@implementation NUXSession (requests)

-(NUXRequest *)request {
    return [[NUXRequest alloc] initWithSession:self];
}

-(NUXRequest *)requestDocument:(NSString *)documentRef {
    return [[[[NUXRequest alloc] initWithSession:self] addURLSegment:[self segmentForDocumentRef:documentRef]] addURLSegment:documentRef];
}

-(NUXRequest *)requestUpdateDocument:(id)document {
    NUXRequest *request = [self request];
    request.method = @"put";
    [request.postData appendData:[NSJSONSerialization dataWithJSONObject:document options:0 error:nil]];
    [[request addURLSegment:@"id"] addURLSegment:[document valueForKey:@"uid"]];
    
    return request;
}

-(NUXRequest *)requestChildren:(NSString *)documentRef {
    return [[self requestDocument:documentRef] addAdaptor:@"children"];
}

-(NUXRequest *)requestOperation:(NSString *)operationId {
    NUXRequest *request = [self request];
    request.contentType = @"application/json+nxrequest";
    request.method = @"POST";
    [[request addURLSegment:@"automation"] addURLSegment:operationId];
    
    return request;
}

-(NUXRequest *)requestQuery:(NSString *)query {
    NUXRequest *request = [self requestOperation:@"Document.Query"];
    
    NSDictionary *params = @{@"params" : @{@"query" : query}};
    [request.postData appendData:[NSJSONSerialization dataWithJSONObject:params options:0 error:nil]];
    
    return  request;
}

-(NSString *)segmentForDocumentRef:(NSString *)docRef {
    return [docRef characterAtIndex:0] == '/' ? @"path" : @"id";
}

@end
