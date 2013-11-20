//
//  NUXSession+requests.h
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 18/11/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import "NUXSession.h"
#import "NUXAutomationRequest.h"

@interface NUXSession (requests)

// Convenience method to create a request associated with this session.
- (NUXRequest *)request;

// Convenience method to create a request to fetch a document associated with this session, documentRef could be an id or a path.
- (NUXRequest *)requestDocument:(NSString *)documentRef;

// Convenience method to create a request that update a document
- (NUXRequest *)requestUpdateDocument:(id)document;

// Convenience method to create a request that will create a new document
- (NUXRequest *)requestCreateDocument:(id)document withParent:(NSString *)documentRef;

// Convenience method to create a request that will delete a known document
- (NUXRequest *)requestDeleteDocument:(NSString *)documentRef;

// Convenience method to create a request to fetch document's childen associated with this session, documentRef could be an id or a path.
- (NUXRequest *)requestChildren:(NSString *)documentRef;

// Convenience method to query documents in NXQL
- (NUXRequest *)requestQuery:(NSString *)query;

// Convenience method get a request prepared to execute a Nuxeo Operation
- (NUXAutomationRequest *)requestOperation:(NSString *)operationId;

// Convenience method de import a file
- (NUXAutomationRequest *)requestImportFile:(NSString *)file withParent:(NSString *)documentRef;

@end
