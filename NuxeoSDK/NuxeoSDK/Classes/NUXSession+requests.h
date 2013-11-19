//
//  NUXSession+requests.h
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 18/11/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import "NUXSession.h"

@interface NUXSession (requests)

// Convenience method to create a request associated with this session.
- (NUXRequest *)request;

// Convenience method to create a request to fetch a document associated with this session, documentRef could be an id or a path.
- (NUXRequest *)requestDocument:(NSString *)documentRef;

// Convenience method to create a request that update a document
- (NUXRequest *)requestUpdateDocument:(id)document;

// Convenience method to create a request that will create a new document
- (NUXRequest *)requestCreateDocument:(id)document withParent:(NSString *)documentRef;

// Convenience method to create a request to fetch document's childen associated with this session, documentRef could be an id or a path.
- (NUXRequest *)requestChildren:(NSString *)documentRef;

// Convenience method get a request prepared to execute a Nuxeo Operation
- (NUXRequest *)requestOperation:(NSString *)operationId;

// Convenience method to query documents in NXQL
- (NUXRequest *)requestQuery:(NSString *)query;

@end
