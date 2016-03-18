//
//  NUXBlobStore.h
//  NuxeoSDK
//  Created by Arnaud Kervern on 2013-12-04.
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

#import <Foundation/Foundation.h>
#import "NUXDocument.h"

/**
 *  NUXBlobStore is providing a LRU cache to easily store your blob with an API-oriented NUXEntity or digest.
 *  It doesn't handle the blob download request, it helps to store files from a digest / or document metadata
 *  and provide an automatic cleanup system, depending of the size, by deleting less used files.
 
 *  You can change the maximum size and maximum items in cache. Size is defined in bytes.
 */
@interface NUXBlobStore : NSObject

@property NSNumber *countLimit;
@property NSNumber *sizeLimit;

@property NSString *filenameProperty;
@property NSString *digestProperty;

/**
 *  This method lookup in the BlobStore to return a path of an existing Blob; identified with a digest.
 *
 *  @See https://doc.nuxeo.com/x/igOIAQ
 *
 *  @param digest Blob digest got from a Document Metadata.
 *
 *  @return Blob path or NULL if the blob is not present in the Store
 */
-(NSString *)blob:(NSString *)digest;
/**
 *  This method lookup in the BlobStore to return a path of an existing Blob; identified from a property in a Document object.
 *
 *  @param document object where a blob can be found
 *  @param xpath    of the metatdata storing the blob. To get the main file attached to a doc: 'file:content'
 *
 *  @return Blob path or NULL if the blob is not present in the Store
 */
-(NSString *)blobFromDocument:(NUXDocument *)document metadataXPath:(NSString *)xpath;

/**
 *  Lookup to the store to check the blob is handled by the store; identified with a digest.
 *
 *  @param digest Blob digest got from a Document Metadata.
 *
 *  @return TRUE if the blob exists, FALSE otherwise.
 */
-(BOOL)hasBlob:(NSString *)digest;
/**
 *  Lookup to the store to check the blob is handled by the store; identified from a property in a Document object.
 *
 *  @param document object where a blob can be found
 *  @param xpath    of the metatdata storing the blob. To get the main file attached to a doc: 'file:content'
 *
 *  @return TRUE if the blob exists, FALSE otherwise.
 */
-(BOOL)hasBlobFromDocument:(NUXDocument *)document metadataXPath:(NSString *)xpath;

/**
 *  Remove a blob from the store; identified with a digest.
 *
 *  @param digest Blob digest got from a Document Metadata.
 *
 *  @return TRUE if the blob was delete, FALSE if not found.
 */
-(BOOL)removeBlob:(NSString *)digest;
/**
 *  Remove a blob from the store; identified with a digest.
 *
 *  @param document object where a blob can be found
 *  @param xpath    of the metatdata storing the blob. To get the main file attached to a doc: 'file:content'
 *
 *  @return TRUE if the blob was delete, FALSE if not found.
 */
-(BOOL)removeBlobFromDocument:(NUXDocument *)document metadataXPath:(NSString *)xpath;

/**
 *  Save a file in the Store; it needs temporary file path (got from the request response) and the NUXDocument property to
 *  ease access after.
 *
 *  @param path     Downloaded file path, got form the request response
 *  @param document NUXDocument of the corresponding blob
 *  @param xpath    Metadata xpath in which the blob is stored in the NUXDocument
 *  @param error    Error object in case something went wrong.
 *
 *  @return File path inside the BlobStore.
 */
-(NSString *)saveBlobFromPath:(NSString *)path withDocument:(NUXDocument *)document metadataXPath:(NSString *)xpath error:(NSError **)error;

/**
 *  Remove all files present in the store
 */
-(void)reset;
/**
 *  Get the number of handled blobs
 *
 *  @return the number of blobs handled by the store
 */
-(NSInteger)count;

+(id)instance;
@end
