//
//  NUXSession+requests.h
//  NuxeoSDK
//  Created by Arnaud Kervern on 2013-11-18.
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

// Convenience method to query documents in NXQL
- (NUXRequest *)requestDownloadBlobFrom:(NSString *)documentRef inMetadata:(NSString *)metadata;

// Convenience method get a request prepared to execute a Nuxeo Operation
- (NUXAutomationRequest *)requestOperation:(NSString *)operationId;

// Convenience method de import a file
- (NUXAutomationRequest *)requestImportFile:(NSString *)file withParent:(NSString *)documentRef;

// Convenience method to create a request to fetch a parent document associated with this session, documentRef could be an id or a path.
- (NUXAutomationRequest *)requestParent:(NSString *)documentRef;

// Convenience method to create a request to move a document associated with this session, documentSrc and documentDes could be an id or a path.
- (NUXAutomationRequest *)move:(NSString *)documentSrc documentDes:(NSString *)documentDes;

// Convenience method to get acls , using to check document permission.
- (NUXRequest *)requestACL:(NSString *)documentRef ;

@end
